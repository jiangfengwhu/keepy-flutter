import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../theme/miaoji_theme.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';

/// 显示全局 AI 聊天 BottomSheet
void showAiChatSheet(BuildContext context) {
  showModalBottomSheet(
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

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '你好！我是 Miaoji AI 助手，可以帮你创建小本、整理数据结构，或者回答任何问题。试试告诉我你想记录什么吧！',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    });
    _controller.clear();
    _scrollToBottom();

    // 模拟 AI 回复
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: '收到！让我想想怎么帮你处理「$text」...',
          isUser: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) =>
                        ChatMessageBubble(message: _messages[i]),
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
          // 拖拽把手
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 助手',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MiaojiColors.textPrimary,
                      ),
                    ),
                    Text(
                      '随时准备帮助你',
                      style: TextStyle(
                        fontSize: 12,
                        color: MiaojiColors.textTertiary,
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
        ],
      ),
    );
  }
}
