import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

/// 聊天输入栏组件
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safePadding = MediaQuery.of(context).padding;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        bottomInset > 0 ? bottomInset + 8 : safePadding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: MiaojiColors.surface,
        border: Border(
          top: BorderSide(
            color: MiaojiColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 输入框
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: MiaojiColors.surfaceVariant,
                borderRadius: BorderRadius.circular(MiaojiRadius.xl),
                border: Border.all(
                  color: MiaojiColors.borderLight,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 15,
                  color: MiaojiColors.textPrimary,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(
                    color: MiaojiColors.textHint,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(18, 12, 12, 12),
                  isDense: true,
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 发送按钮
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MiaojiColors.primary, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: MiaojiColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
