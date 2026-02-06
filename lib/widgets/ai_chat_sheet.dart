import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../models/notebook.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
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
  final DatabaseService _dbService = DatabaseService();

  bool _isSending = false;
  StreamSubscription<StreamEvent>? _streamSub;

  /// 完整对话历史（包含 system 消息，用于发送给后端）
  final List<ChatMessage> _chatHistory = [
    ChatMessage.system(
      'You are a helpful assistant for Miaoji note-taking app. '
      'You can help users create data schemas (notebooks) and manage records. '
      'Respond in the same language the user uses.',
    ),
  ];

  /// UI 显示的消息列表（不包含 system）
  List<ChatMessage> get _displayMessages =>
      _chatHistory.where((m) => !m.isSystem).toList();

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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    HapticFeedback.lightImpact();

    // 1. 添加用户消息
    setState(() {
      _chatHistory.add(ChatMessage.user(text));
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 2. 添加空的 assistant 占位消息（流式填充）
    final assistantMsg = ChatMessage.assistantStreaming();
    setState(() {
      _chatHistory.add(assistantMsg);
    });
    _scrollToBottom();

    // 3. 发送请求并处理流式响应
    _streamSub = _aiService.sendMessage(_chatHistory).listen(
      (event) {
        if (!mounted) return;

        switch (event) {
          case TextEvent(:final text):
            setState(() {
              assistantMsg.content += text;
            });
            _scrollToBottom();

          case ToolCallStartEvent():
            // tool call 开始，等待完整数据
            break;

          case ToolCallEvent(:final name, :final args):
            // 拦截 create_data_schema，存入本地数据库
            if (name == 'create_data_schema') {
              _handleCreateSchema(assistantMsg, args);
            } else {
              setState(() {
                assistantMsg.toolCalls ??= [];
                assistantMsg.toolCalls!.add(
                  ToolCallInfo(
                    id: 'call_${DateTime.now().microsecondsSinceEpoch}',
                    function: ToolCallFunction(name: name, arguments: args),
                  ),
                );
              });
            }
            _scrollToBottom();

          case StreamDoneEvent():
            setState(() {
              assistantMsg.isStreaming = false;
              _isSending = false;
            });

          case StreamErrorEvent(:final message):
            setState(() {
              if (assistantMsg.content.isEmpty) {
                assistantMsg.content = '抱歉，出错了：$message';
              }
              assistantMsg.isStreaming = false;
              _isSending = false;
            });
            _scrollToBottom();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          assistantMsg.content = '请求失败：$error';
          assistantMsg.isStreaming = false;
          _isSending = false;
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          assistantMsg.isStreaming = false;
          _isSending = false;
        });
      },
    );
  }

  /// 处理 create_data_schema tool call：解析 args → 存 DB → 更新 UI
  Future<void> _handleCreateSchema(
      ChatMessage assistantMsg, String argsJson) async {
    try {
      final notebook = Notebook.fromToolCallArgs(argsJson);
      final insertedId = await _dbService.createNotebook(notebook);
      final savedNotebook = await _dbService.getNotebook(insertedId);

      if (!mounted) return;
      setState(() {
        assistantMsg.createdNotebook = savedNotebook ?? notebook;
        assistantMsg.toolCalls ??= [];
        assistantMsg.toolCalls!.add(
          ToolCallInfo(
            id: 'call_${DateTime.now().microsecondsSinceEpoch}',
            function: ToolCallFunction(
                name: 'create_data_schema', arguments: argsJson),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        assistantMsg.toolCalls ??= [];
        assistantMsg.toolCalls!.add(
          ToolCallInfo(
            id: 'call_${DateTime.now().microsecondsSinceEpoch}',
            function: ToolCallFunction(
                name: 'create_data_schema', arguments: argsJson),
          ),
        );
      });
    }
  }

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
        color: MiaojiColors.background,
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [MiaojiColors.primary, Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
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
                      _isSending ? '正在思考...' : '随时准备帮助你',
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: MiaojiColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 28,
              color: MiaojiColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '开始和 AI 对话吧',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: MiaojiColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '试试说「我要创建一个读书记录小本」',
            style: TextStyle(
              fontSize: 13,
              color: MiaojiColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
