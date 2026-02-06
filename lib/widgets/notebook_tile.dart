import 'package:flutter/material.dart';
import '../models/notebook_item.dart';
import '../theme/miaoji_theme.dart';

/// 首页笔记本列表项组件
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MiaojiColors.surface,
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
          boxShadow: MiaojiShadows.sm,
          border: Border.all(
            color: MiaojiColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 24,
              ),
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
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: MiaojiColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 箭头
            const Icon(
              Icons.chevron_right_rounded,
              color: MiaojiColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
