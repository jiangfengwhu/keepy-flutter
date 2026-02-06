import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/miaoji_theme.dart';

/// 聊天消息气泡组件
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI 头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MiaojiColors.primary, Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? MiaojiColors.primary : MiaojiColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 18 : 4),
                  topRight: Radius.circular(isUser ? 4 : 18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color:
                              MiaojiColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : MiaojiShadows.sm,
                border: isUser
                    ? null
                    : Border.all(
                        color: MiaojiColors.borderLight,
                        width: 1,
                      ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isUser ? Colors.white : MiaojiColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 42),
        ],
      ),
    );
  }
}
