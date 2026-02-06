import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

/// 首页 AI 助手入口卡片 — 手写信封风格
class AiAssistantCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AiAssistantCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3D3124),
              Color(0xFF5A4532),
              Color(0xFF6B5540),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(MiaojiRadius.xl),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D3124).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          // 纸质纹理边框
          border: Border.all(
            color: const Color(0xFF8B7355).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI 标签 — 蜡封章风格
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A24C).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(MiaojiRadius.full),
                      border: Border.all(
                        color: const Color(0xFFD4A24C).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFD4A24C),
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'AI 助手',
                          style: TextStyle(
                            color: Color(0xFFD4A24C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '创建新的记录本',
                    style: TextStyle(
                      color: Color(0xFFF5EFE0),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '描述你想记录的内容，让 AI 帮你自动构建数据结构',
                    style: TextStyle(
                      color: const Color(0xFFF5EFE0).withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 右侧墨水瓶图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A24C).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD4A24C).withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFFD4A24C),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
