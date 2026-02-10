import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../models/notebook_item.dart';
import '../theme/miaoji_theme.dart';

/// 首页笔记本列表项组件 — 拟物纸质小本风格
class NotebookTile extends StatelessWidget {
  final NotebookItem item;
  final VoidCallback? onTap;

  const NotebookTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 底层纸张（微偏移产生纸叠感，无阴影避免四角溢出）
          Positioned(
            left: 3,
            right: -3,
            top: 3,
            bottom: -3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECCA),
                borderRadius: BorderRadius.circular(MiaojiRadius.lg),
              ),
            ),
          ),

          // 主纸张
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MiaojiColors.card,
              borderRadius: BorderRadius.circular(MiaojiRadius.lg),
              boxShadow: MiaojiShadows.paper,
              border: Border.all(
                color: MiaojiColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 左侧装订线
                Container(
                  width: 3,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 14),

                // 图标（印章风格）
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.iconBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.iconColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: _buildCoverIcon(),
                ),
                const SizedBox(width: 14),

                // 标题 + 描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MiaojiColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: MiaojiColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: MiaojiColors.textHint.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            context.l10n.recordCount(item.recordCount),
                            style: TextStyle(
                              fontSize: 12,
                              color: item.iconColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 翻页箭头
                Icon(
                  Icons.chevron_right_rounded,
                  color: MiaojiColors.textHint.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ),

          // 右上角书签
          Positioned(
            right: 16,
            top: -2,
            child: CustomPaint(
              size: const Size(14, 22),
              painter: _BookmarkPainter(color: item.iconColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverIcon() {
    if (item.iconImagePath != null && item.iconImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(item.iconImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Icon(
              item.icon,
              color: item.iconColor,
              size: 22,
            );
          },
        ),
      );
    }
    return Icon(
      item.icon,
      color: item.iconColor,
      size: 22,
    );
  }
}

/// 书签绘制器
class _BookmarkPainter extends CustomPainter {
  final Color color;
  _BookmarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 5)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
