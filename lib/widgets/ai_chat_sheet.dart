import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../services/tool_executor.dart';
import '../theme/miaoji_theme.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';

/// 显示全局 AI 聊天 BottomSheet，返回 Future 用于关闭后回调
Future<void> showAiChatSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => const _AiChatSheetContent(),
  );
}

class _AiChatSheetContent extends StatefulWidget {
  const _AiChatSheetContent();

  @override
  State<_AiChatSheetContent> createState() => _AiChatSheetContentState();
}

class _AiChatSheetContentState extends State<_AiChatSheetContent> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final AiService _aiService = AiService();
  final ToolExecutor _toolExecutor = ToolExecutor();
  final DatabaseService _dbService = DatabaseService();

  bool _isSending = false;
  bool _isInitialized = false;
  StreamSubscription<StreamEvent>? _streamSub;

  /// 完整对话历史（包含 system 消息，用于发送给后端）
  final List<ChatMessage> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _initSystemMessage();
  }

  /// 初始化 system message，包含本地已有小本的信息
  Future<void> _initSystemMessage() async {
    final notebooks = await _dbService.getAllNotebooks();

    final buffer = StringBuffer();

    if (notebooks.isNotEmpty) {
      buffer.writeln(
          'The user already has the following notebooks (schemas) in the local database:');
      for (final nb in notebooks) {
        final fields = nb.schema
            .map((f) => '${f.field}(${f.type})')
            .join(', ');
        buffer.writeln(
            '- "${nb.name}" (id: ${nb.id}): $fields');
        if (nb.description.isNotEmpty) {
          buffer.writeln('  Description: ${nb.description}');
        }
      }
      buffer.writeln();
    } else {
      buffer.writeln(
          'The user has no notebooks yet. Help them create one if they want to start recording data.');
    }

    if (!mounted) return;
    setState(() {
      _chatHistory.insert(0, ChatMessage.system(buffer.toString()));
      _isInitialized = true;
    });
  }

  /// 刷新 system message 中的小本信息（新建小本后调用）
  Future<void> _refreshSystemMessage() async {
    final notebooks = await _dbService.getAllNotebooks();
    final buffer = StringBuffer();

    if (notebooks.isNotEmpty) {
      buffer.writeln(
          'The user already has the following notebooks (schemas) in the local database:');
      for (final nb in notebooks) {
        final fields =
            nb.schema.map((f) => '${f.field}(${f.type})').join(', ');
        buffer.writeln('- "${nb.name}" (id: ${nb.id}): $fields');
        if (nb.description.isNotEmpty) {
          buffer.writeln('  Description: ${nb.description}');
        }
      }
    } else {
      buffer.writeln(
          'The user has no notebooks yet. Help them create one if they want to start recording data.');
    }

    if (!mounted) return;
    setState(() {
      // 替换第一条 system 消息
      if (_chatHistory.isNotEmpty && _chatHistory.first.isSystem) {
        _chatHistory.first.content = buffer.toString();
      }
    });
  }

  /// UI 显示的消息列表（不包含 system 和 tool response）
  List<ChatMessage> get _displayMessages =>
      _chatHistory.where((m) => !m.isSystem && !m.isTool).toList();

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _aiService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ── 发送消息入口 ──────────────────────────────

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending || !_isInitialized) return;

    HapticFeedback.lightImpact();

    // 在发给 AI 的消息前附上当前时间，但 UI 只显示原始文本
    final now = DateTime.now();
    final timePrefix =
        '[当前时间: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}]\n';

    final userMsg = ChatMessage(
      role: 'user',
      content: '$timePrefix$text',   // 发给 AI（带时间）
      displayContent: text,           // UI 显示（原始文本）
    );

    setState(() {
      _chatHistory.add(userMsg);
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 开始对话循环
    await _streamAiResponse();
  }

  // ── AI 流式响应 + tool call 执行循环 ───────────

  /// 发送当前 chatHistory 给 AI，处理流式响应
  /// 如果 AI 返回 tool calls，则执行后自动再次调用 AI
  Future<void> _streamAiResponse() async {
    // 创建空的 assistant 占位消息
    final assistantMsg = ChatMessage.assistantStreaming();
    setState(() => _chatHistory.add(assistantMsg));
    _scrollToBottom();

    // 收集本次流中的所有 tool calls
    final pendingToolCalls = <(String id, String name, String args)>[];

    final completer = Completer<void>();

    _streamSub = _aiService.sendMessage(_chatHistory).listen(
      (event) {
        if (!mounted) return;

        switch (event) {
          case TextEvent(:final text):
            setState(() => assistantMsg.content += text);
            _scrollToBottom();

          case ToolCallStartEvent():
            break;

          case ToolCallEvent(:final name, :final args):
            final toolCallId =
                'call_${DateTime.now().microsecondsSinceEpoch}';
            pendingToolCalls.add((toolCallId, name, args));

            // 在 assistant 消息上记录 tool calls（用于序列化给 AI）
            setState(() {
              assistantMsg.toolCalls ??= [];
              assistantMsg.toolCalls!.add(
                ToolCallInfo(
                  id: toolCallId,
                  function: ToolCallFunction(name: name, arguments: args),
                ),
              );
            });
            _scrollToBottom();

          case StreamDoneEvent():
            setState(() => assistantMsg.isStreaming = false);
            if (!completer.isCompleted) completer.complete();

          case StreamErrorEvent(:final message):
            setState(() {
              if (assistantMsg.content.isEmpty) {
                assistantMsg.content = '抱歉，出错了：$message';
              }
              assistantMsg.isStreaming = false;
              _isSending = false;
            });
            _scrollToBottom();
            if (!completer.isCompleted) completer.complete();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          assistantMsg.content = '请求失败：$error';
          assistantMsg.isStreaming = false;
          _isSending = false;
        });
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );

    // 等待流结束
    await completer.future;

    if (!mounted) return;

    // 如果有 pending tool calls，逐个执行，然后继续对话
    if (pendingToolCalls.isNotEmpty) {
      await _executeToolCalls(assistantMsg, pendingToolCalls);
    } else {
      // 没有 tool calls，对话结束
      setState(() => _isSending = false);
    }
  }

  /// 执行所有 pending tool calls，添加 tool response，然后继续对话
  Future<void> _executeToolCalls(
    ChatMessage assistantMsg,
    List<(String id, String name, String args)> toolCalls,
  ) async {
    final results = <ToolResult>[];

    for (final (callId, name, args) in toolCalls) {
      // 执行 tool
      final result = await _toolExecutor.execute(name, args);
      results.add(result);

      // 把 tool response 添加到 history（AI 协议要求）
      _chatHistory.add(ChatMessage.tool(
        content: result.responseForAi,
        toolCallId: callId,
      ));
    }

    if (!mounted) return;

    // 把执行结果挂到 assistant 消息上（给 UI 渲染卡片用）
    setState(() {
      assistantMsg.toolResults = results;
    });
    _scrollToBottom();

    // 如果有 schema 变动（创建/更新/删除），刷新 system message
    const schemaTools = {
      'create_data_schema',
      'update_data_schema',
      'delete_data_schema',
    };
    final hasSchemaChange =
        results.any((r) => schemaTools.contains(r.toolName) && r.success);
    if (hasSchemaChange) {
      await _refreshSystemMessage();
    }

    // 继续对话：让 AI 基于 tool 结果生成后续回复
    await _streamAiResponse();
  }

  // ── UI Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final displayMessages = _displayMessages;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: MiaojiColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: displayMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: displayMessages.length,
                    itemBuilder: (_, i) =>
                        ChatMessageBubble(message: displayMessages[i]),
                  ),
          ),
          ChatInputBar(
            controller: _controller,
            focusNode: _focusNode,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(
            color: MiaojiColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MiaojiColors.textHint.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 墨水瓶头像
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A4532), Color(0xFF8B6914)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A4532).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFD4A24C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 助手',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MiaojiColors.textPrimary,
                      ),
                    ),
                    Text(
                      _isSending ? '正在书写...' : '随时准备帮助你',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isSending
                            ? MiaojiColors.primary
                            : MiaojiColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: MiaojiColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: MiaojiColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: MiaojiColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 空白信纸图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: MiaojiColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MiaojiColors.borderLight,
                width: 1.5,
              ),
              boxShadow: MiaojiShadows.paper,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              size: 32,
              color: MiaojiColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '开始和 AI 对话吧',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: MiaojiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试说「我要创建一个读书记录小本」',
            style: TextStyle(
              fontSize: 13,
              color: MiaojiColors.textTertiary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
