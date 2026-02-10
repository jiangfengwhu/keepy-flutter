import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/l10n_ext.dart';
import '../models/chat_message.dart';
import '../models/notebook.dart';
import '../services/ai_service.dart';
import '../services/assistant_persona_service.dart';
import '../services/database_service.dart';
import '../services/tool_executor.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';
import 'confetti_overlay.dart';

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
  final FocusNode _focusNode = FocusNode();

  /// 由 DraggableScrollableSheet 提供的 ScrollController
  ScrollController? _sheetScrollController;
  final AiService _aiService = AiService();
  final AssistantPersonaService _personaService = AssistantPersonaService();
  final ToolExecutor _toolExecutor = ToolExecutor();
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();

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
    final systemMessage = await _buildSystemMessage(notebooks);

    if (!mounted) return;
    setState(() {
      _chatHistory.insert(0, ChatMessage.system(systemMessage));
      _isInitialized = true;
    });
  }

  /// 刷新 system message 中的小本信息（新建小本后调用）
  Future<void> _refreshSystemMessage() async {
    final notebooks = await _dbService.getAllNotebooks();
    final systemMessage = await _buildSystemMessage(notebooks);

    if (!mounted) return;
    setState(() {
      // 替换第一条 system 消息
      if (_chatHistory.isNotEmpty && _chatHistory.first.isSystem) {
        _chatHistory.first.content = systemMessage;
      }
    });
  }

  Future<String> _buildSystemMessage(List<Notebook> notebooks) async {
    final persona = await _personaService.getPersona();
    final buffer = StringBuffer();

    if (persona.isNotEmpty) {
      buffer.writeln(persona);
      buffer.writeln();
    }

    if (notebooks.isNotEmpty) {
      buffer.writeln(
        'The user already has the following notebooks (schemas) in the local database:',
      );
      for (final nb in notebooks) {
        final fields = nb.schema.map((f) => '${f.field}(${f.type})').join(', ');
        buffer.writeln('- "${nb.name}" (id: ${nb.id}): $fields');
        if (nb.description.isNotEmpty) {
          buffer.writeln('  Description: ${nb.description}');
        }
      }
    } else {
      buffer.writeln(
        'The user has no notebooks yet. Help them create one if they want to start recording data.',
      );
    }
    return buffer.toString();
  }

  /// UI 显示的消息列表（不包含 system 和 tool response）
  List<ChatMessage> get _displayMessages =>
      _chatHistory.where((m) => !m.isSystem && !m.isTool).toList();

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _aiService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      final ctrl = _sheetScrollController;
      if (ctrl != null && ctrl.hasClients) {
        ctrl.animateTo(
          ctrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ── 图片选择 ──────────────────────────────────

  /// 显示图片来源选择弹窗
  void _showImageSourcePicker() {
    if (_isSending) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF3D3124),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽把手
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A24C).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: context.l10n.aiImageSourceCamera,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: context.l10n.aiImageSourceGallery,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Icon(icon, color: const Color(0xFFD4A24C), size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 从指定来源选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null || !mounted) return;

      // 读取文件并转为 base64
      final bytes = await File(pickedFile.path).readAsBytes();
      final rawBase64 = base64Encode(bytes);

      // 推断 MIME 类型
      final ext = pickedFile.path.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'bmp' => 'image/bmp',
        _ => 'image/jpeg',
      };

      // 带前缀的 base64 数据
      final base64Data = 'data:$mimeType;base64,$rawBase64';

      // 创建图片消息并添加到历史
      final imageMsg = ChatMessage.userImage(
        base64Data: base64Data,
        mimeType: mimeType,
      );

      setState(() {
        _chatHistory.add(imageMsg);
      });
      _scrollToBottom();

      // 判断是否触发对话：历史中有非图片的用户/助手消息则触发
      final hasTextConversation = _chatHistory.any(
        (m) => (m.isUser || m.isAssistant) && !m.isImageOnly,
      );
      if (hasTextConversation && !_isSending) {
        setState(() => _isSending = true);
        await _streamAiResponse();
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('图片选择失败: $e');
    }
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
      content: '$timePrefix$text', // 发给 AI（带时间）
      displayContent: text, // UI 显示（原始文本）
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

    _streamSub = _aiService
        .sendMessage(_chatHistory)
        .listen(
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
                    assistantMsg.content = context.l10n.aiErrorMessage(message);
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
              assistantMsg.content = context.l10n.aiRequestFailed(error);
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
      _chatHistory.add(
        ChatMessage.tool(content: result.responseForAi, toolCallId: callId),
      );
    }

    if (!mounted) return;

    // 把执行结果挂到 assistant 消息上（给 UI 渲染卡片用）
    setState(() {
      assistantMsg.toolResults = results;
    });
    _scrollToBottom();

    // 仅 AI 创建成功时播放庆祝动画（创建小本 / 创建记录）
    const celebrateTools = {'create_data_schema', 'add_data_record'};
    final shouldCelebrate = results.any(
      (r) => r.success && celebrateTools.contains(r.toolName),
    );
    if (shouldCelebrate) {
      ConfettiOverlay.show(context);
    }

    // 如果有 schema 变动（创建/更新/删除），刷新 system message
    const schemaTools = {
      'create_data_schema',
      'update_data_schema',
      'delete_data_schema',
    };
    final hasSchemaChange = results.any(
      (r) => schemaTools.contains(r.toolName) && r.success,
    );
    if (hasSchemaChange) {
      await _refreshSystemMessage();
    }

    // 继续对话：让 AI 基于 tool 结果生成后续回复
    await _streamAiResponse();
  }

  // ── UI Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayMessages = _displayMessages;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          _sheetScrollController = scrollController;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3D3124), Color(0xFF4E3F2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: displayMessages.isEmpty
                      ? CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: scrollController,
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
                  onPickImage: _showImageSourcePicker,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 14),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A24C).withValues(alpha: 0.3),
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
                  color: const Color(0xFFD4A24C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFFD4A24C).withValues(alpha: 0.25),
                    width: 1,
                  ),
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
                    Text(
                      context.l10n.aiAssistantTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5EFE0),
                      ),
                    ),
                    Text(
                      _isSending
                          ? context.l10n.aiAssistantWriting
                          : context.l10n.aiAssistantReady,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isSending
                            ? const Color(0xFFD4A24C)
                            : const Color(0xFFF5EFE0).withValues(alpha: 0.5),
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
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: const Color(0xFFF5EFE0).withValues(alpha: 0.6),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: 32,
              color: const Color(0xFFD4A24C).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.aiEmptyTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.aiEmptyHint,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFFF5EFE0).withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
