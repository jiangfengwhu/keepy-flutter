import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

/// 水平滚动分类标签栏 — 纸质标签风格
class CategoryTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CategoryTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? MiaojiColors.primary
                    : MiaojiColors.card,
                borderRadius: BorderRadius.circular(MiaojiRadius.full),
                border: isSelected
                    ? null
                    : Border.all(
                        color: MiaojiColors.borderLight, width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MiaojiColors.primary
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : MiaojiShadows.sm,
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : MiaojiColors.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
