import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/notebook.dart';
import '../theme/miaoji_theme.dart';

/// 聊天消息气泡组件
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // 不显示 system 消息
    if (message.isSystem) return const SizedBox.shrink();

    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 文本内容气泡
                if (message.content.isNotEmpty || message.isStreaming)
                  _buildTextBubble(isUser),

                // 小本创建成功卡片 or 通用 tool call
                if (message.toolCalls != null && message.toolCalls!.isNotEmpty)
                  _buildToolCallArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
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
    );
  }

  Widget _buildTextBubble(bool isUser) {
    final showCursor = message.isStreaming && message.content.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  color: MiaojiColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : MiaojiShadows.sm,
        border: isUser
            ? null
            : Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: message.content.isEmpty && message.isStreaming
          ? _buildTypingIndicator()
          : RichText(
              text: TextSpan(
                text: message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : MiaojiColors.textPrimary,
                  height: 1.5,
                ),
                children: showCursor
                    ? [
                        TextSpan(
                          text: ' ●',
                          style: TextStyle(
                            color: isUser
                                ? Colors.white.withValues(alpha: 0.6)
                                : MiaojiColors.primary.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ]
                    : null,
              ),
            ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(delay: 0),
        const SizedBox(width: 4),
        _Dot(delay: 1),
        const SizedBox(width: 4),
        _Dot(delay: 2),
      ],
    );
  }

  /// tool call 区域：优先展示「小本创建成功」卡片
  Widget _buildToolCallArea() {
    // 如果有创建的笔记本，展示成功卡片
    if (message.createdNotebook != null) {
      return _NotebookCreatedCard(notebook: message.createdNotebook!);
    }

    // 否则尝试从 tool call args 中解析出笔记本信息
    for (final tc in message.toolCalls!) {
      if (tc.function.name == 'create_data_schema') {
        try {
          final notebook = Notebook.fromToolCallArgs(tc.function.arguments);
          return _NotebookCreatedCard(notebook: notebook);
        } catch (_) {}
      }
    }

    // 其他 tool call 显示简单标签
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: message.toolCalls!.map(_buildGenericToolCallChip).toList(),
    );
  }

  /// 非 create_data_schema 的通用 tool call 标签
  Widget _buildGenericToolCallChip(ToolCallInfo toolCall) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.build_rounded,
                size: 12,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '执行: ${toolCall.function.name}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 小本创建成功卡片
class _NotebookCreatedCard extends StatelessWidget {
  final Notebook notebook;

  const _NotebookCreatedCard({required this.notebook});

  /// 根据笔记本名称生成图标/颜色
  static const _iconSets = [
    (Icons.auto_stories_rounded, Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    (Icons.fitness_center_rounded, Color(0xFFEF4444), Color(0xFFFEE2E2)),
    (Icons.restaurant_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    (Icons.medication_rounded, Color(0xFF10B981), Color(0xFFD1FAE5)),
    (Icons.payments_rounded, Color(0xFF3B82F6), Color(0xFFDBEAFE)),
    (Icons.school_rounded, Color(0xFFEC4899), Color(0xFFFCE7F3)),
    (Icons.flight_rounded, Color(0xFF06B6D4), Color(0xFFCFFAFE)),
  ];

  (IconData, Color, Color) _getIconStyle() {
    final hash = notebook.name.hashCode.abs();
    return _iconSets[hash % _iconSets.length];
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, iconBg) = _getIconStyle();
    final fieldCount = notebook.schema.length;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MiaojiColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: MiaojiColors.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部成功提示条
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.1),
                    const Color(0xFF10B981).withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '小本创建成功',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            // 笔记本信息
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标 + 名称
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notebook.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: MiaojiColors.textPrimary,
                              ),
                            ),
                            if (notebook.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  notebook.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: MiaojiColors.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 字段标签
                  if (notebook.schema.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: notebook.schema
                          .take(6) // 最多展示 6 个字段标签
                          .map(_buildFieldTag)
                          .toList(),
                    ),
                    if (fieldCount > 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '还有 ${fieldCount - 6} 个字段...',
                          style: const TextStyle(
                            fontSize: 11,
                            color: MiaojiColors.textHint,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldTag(SchemaField field) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MiaojiColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: MiaojiColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypeIcon(field.type),
          const SizedBox(width: 4),
          Text(
            field.field,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: MiaojiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    final (iconData, color) = switch (type) {
      'string' => (Icons.text_fields_rounded, const Color(0xFF3B82F6)),
      'number' => (Icons.tag_rounded, const Color(0xFFF59E0B)),
      'date' => (Icons.calendar_today_rounded, const Color(0xFF8B5CF6)),
      'boolean' => (Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
      _ => (Icons.data_object_rounded, const Color(0xFF6B7280)),
    };
    return Icon(iconData, size: 11, color: color);
  }
}

/// 打字指示器动画圆点
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay * 200), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: MiaojiColors.primary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
