import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../models/notebook_item.dart';
import '../theme/miaoji_theme.dart';

/// 妙记本磁贴 — 拟物笔记本造型，带纹理
class NotebookGridTile extends StatelessWidget {
  final NotebookItem item;
  final VoidCallback? onTap;

  const NotebookGridTile({
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
          // 底层纸叠（笔记本厚度感）
          Positioned(
            left: 2,
            right: -2,
            top: 2,
            bottom: -2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECCA),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // 笔记本主体
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B6914).withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 书脊 / 装订线（带缝线纹理）
                  CustomPaint(
                    painter: _SpinePainter(
                      color: item.iconColor.withValues(alpha: 0.6),
                    ),
                    child: Container(
                      width: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            item.iconColor.withValues(alpha: 0.5),
                            item.iconColor.withValues(alpha: 0.65),
                            item.iconColor.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 封面内容区
                  Expanded(
                    child: Stack(
                      children: [
                        // 封面底色
                        Container(
                          decoration: BoxDecoration(
                            color: MiaojiColors.card,
                            border: Border(
                              top: BorderSide(
                                color: MiaojiColors.borderLight,
                                width: 1,
                              ),
                              right: BorderSide(
                                color: MiaojiColors.borderLight,
                                width: 1,
                              ),
                              bottom: BorderSide(
                                color: MiaojiColors.borderLight,
                                width: 1,
                              ),
                            ),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(15),
                            ),
                          ),
                        ),
                        // 横线纹理（笔记本横格）
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RuledLinesPainter(
                              lineColor: MiaojiColors.borderLight
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        // 前景内容
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 封面图标
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: item.iconBg.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        item.iconColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: _buildCoverIcon(),
                              ),
                              const SizedBox(height: 12),
                              // 标题（封面书名）
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: MiaojiColors.textPrimary,
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              // 记录数
                              Text(
                                context.l10n.recordCount(item.recordCount),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      item.iconColor.withValues(alpha: 0.85),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverIcon() {
    if (item.iconImagePath != null && item.iconImagePath!.isNotEmpty) {
      return SizedBox.expand(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(item.iconImagePath!),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Icon(
                item.icon,
                color: item.iconColor,
                size: 26,
              );
            },
          ),
        ),
      );
    }
    return Icon(
      item.icon,
      color: item.iconColor,
      size: 26,
    );
  }
}

/// 书脊缝线绘制器 — 书脊上的虚线装订痕迹
class _SpinePainter extends CustomPainter {
  final Color color;
  _SpinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 缝线：沿书脊中线画虚线
    const dashLen = 4.0;
    const gapLen = 5.0;
    final x = size.width / 2;
    double y = 6.0;
    while (y < size.height - 4) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashLen), paint);
      y += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 横格线绘制器 — 笔记本内页横线
class _RuledLinesPainter extends CustomPainter {
  final Color lineColor;
  _RuledLinesPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 16.0;
    // 从顶部开始画横线
    double y = spacing + 6;
    while (y < size.height - 8) {
      canvas.drawLine(Offset(6, y), Offset(size.width - 6, y), paint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

