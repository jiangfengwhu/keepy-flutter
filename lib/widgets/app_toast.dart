import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';
import 'confetti_overlay.dart';

/// 基于根 Overlay 的 Toast 组件。
/// 不受 BottomSheet / Dialog 遮挡，始终显示在最上层。
class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;

  /// 显示一条 toast 消息（默认 2 秒后自动消失）。
  static void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    // 先移除上一条
    _dismiss();

    final overlay = ConfettiOverlay.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        message: message,
        duration: duration,
        onDismiss: () {
          if (_currentEntry == entry) {
            _currentEntry = null;
            entry.remove();
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// 手动关闭当前 toast
  static void _dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _controller.forward();
    Future.delayed(widget.duration, _animateOut);
  }

  void _animateOut() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomPadding + 72,
      child: IgnorePointer(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: MiaojiColors.textPrimary,
                  borderRadius: BorderRadius.circular(MiaojiRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
