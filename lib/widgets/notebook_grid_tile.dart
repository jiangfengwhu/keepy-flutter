import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../models/notebook_item.dart';

/// 妙记本磁贴 — 精致拟物笔记本造型，带皮革质感封面
class NotebookGridTile extends StatelessWidget {
  final NotebookItem item;
  final VoidCallback? onTap;

  const NotebookGridTile({
    super.key,
    required this.item,
    this.onTap,
  });

  /// 根据主题色生成封面的深色版本（用于皮质渐变）
  Color _coverDark(Color c) =>
      HSLColor.fromColor(c).withLightness(0.22).withSaturation(0.45).toColor();

  Color _coverMid(Color c) =>
      HSLColor.fromColor(c).withLightness(0.32).withSaturation(0.38).toColor();

  Color _coverLight(Color c) =>
      HSLColor.fromColor(c).withLightness(0.40).withSaturation(0.32).toColor();

  @override
  Widget build(BuildContext context) {
    final baseColor = item.iconColor;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── 多层纸叠（笔记本厚度感） ──
          Positioned(
            left: 3,
            right: -3,
            top: 3,
            bottom: -3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8DFC8),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            left: 1.5,
            right: -1.5,
            top: 1.5,
            bottom: -1.5,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0E8D2),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // ── 笔记本主体 ──
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: _coverDark(baseColor).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(2, 5),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 书脊（立体感装订） ──
                  _buildSpine(baseColor),
                  // ── 封面 ──
                  Expanded(child: _buildCover(context, baseColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 书脊 — 带渐变、缝线和装订边阴影
  Widget _buildSpine(Color baseColor) {
    return SizedBox(
      width: 14,
      child: Stack(
        children: [
          // 书脊底色渐变
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _coverDark(baseColor),
                  _coverMid(baseColor),
                  _coverDark(baseColor).withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 缝线纹理
          CustomPaint(
            painter: _SpinePainter(
              color: Colors.white.withValues(alpha: 0.22),
            ),
            size: Size.infinite,
          ),
          // 书脊右侧光泽高光线
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),
          // 书脊左侧暗边
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  /// 封面 — 皮革质感渐变 + 装饰边框 + 内容
  Widget _buildCover(BuildContext context, Color baseColor) {
    return Stack(
      children: [
        // ── 封面皮革质感底色 ──
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _coverLight(baseColor),
                _coverMid(baseColor),
                _coverDark(baseColor),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(14),
            ),
          ),
        ),

        // ── 皮面细微纹理（噪点层） ──
        Positioned.fill(
          child: CustomPaint(
            painter: _LeatherTexturePainter(
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ),
        ),

        // ── 从书脊出来的装订内阴影 ──
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── 装饰性烫金边框 ──
        Positioned(
          left: 14,
          right: 8,
          top: 12,
          bottom: 12,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
            ),
          ),
        ),

        // ── 封面右下角高光（光泽感） ──
        Positioned(
          right: -20,
          bottom: -20,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── 书签丝带 ──
        Positioned(
          right: 18,
          top: -1,
          child: CustomPaint(
            painter: _BookmarkRibbonPainter(
              color: _ribbonColor(baseColor),
            ),
            size: const Size(10, 22),
          ),
        ),

        // ── 前景内容 ──
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 封面图标 — 烫金风格容器
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _buildCoverIcon(),
              ),
              const SizedBox(height: 12),
              // 标题 — 烫金书名
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.92),
                  letterSpacing: 0.3,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // 记录数 — 浮雕效果
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.l10n.recordCount(item.recordCount),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          ),
        ),
      ],
    );
  }

  /// 根据封面色计算丝带颜色（取互补暖色）
  Color _ribbonColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    // 丝带取暖金色偏移
    return hsl
        .withHue((hsl.hue + 30) % 360)
        .withSaturation(0.6)
        .withLightness(0.45)
        .toColor();
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
                color: Colors.white.withValues(alpha: 0.88),
                size: 30,
              );
            },
          ),
        ),
      );
    }
    return Icon(
      item.icon,
      color: Colors.white.withValues(alpha: 0.88),
      size: 30,
    );
  }
}

/// 书脊缝线绘制器 — 虚线装订痕迹
class _SpinePainter extends CustomPainter {
  final Color color;
  _SpinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const dashLen = 4.0;
    const gapLen = 4.5;
    final x = size.width * 0.45;
    double y = 8.0;
    while (y < size.height - 6) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashLen), paint);
      y += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 皮革纹理绘制器 — 封面微纹理
class _LeatherTexturePainter extends CustomPainter {
  final Color color;
  _LeatherTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // 固定种子，保证一致
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制细微噪点
    for (int i = 0; i < 120; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.3 + rng.nextDouble() * 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // 绘制细纹路线条（模拟皮革纹理）
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 15; i++) {
      final startX = rng.nextDouble() * size.width;
      final startY = rng.nextDouble() * size.height;
      final endX = startX + (rng.nextDouble() - 0.5) * 30;
      final endY = startY + (rng.nextDouble() - 0.5) * 20;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 书签丝带绘制器 — 从顶部垂下的小丝带
class _BookmarkRibbonPainter extends CustomPainter {
  final Color color;
  _BookmarkRibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 丝带主体渐变
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        color.withValues(alpha: 0.85),
      ],
    ).createShader(rect);

    // 绘制丝带形状（底部V型切口）
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 4)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // 丝带高光
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final highlightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.35, size.height - 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
