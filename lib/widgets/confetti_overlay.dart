import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// 基于三方库 `confetti` 的庆祝动画。
/// 采用串行队列，确保每次触发都完整播放，不被后续触发打断。
class ConfettiOverlay {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isPlaying = false;
  static int _pendingBursts = 0;

  static void show(
    BuildContext? context, {
    int particleCount = 32,
    Duration duration = const Duration(milliseconds: 1100),
  }) {
    _pendingBursts += 1;
    _drainQueue(
      context: context,
      particleCount: particleCount,
      duration: duration,
    );
  }

  static void showMultiple(
    int count, {
    BuildContext? context,
    int particleCount = 32,
    Duration duration = const Duration(milliseconds: 1100),
  }) {
    if (count <= 0) return;
    _pendingBursts += count;
    _drainQueue(
      context: context,
      particleCount: particleCount,
      duration: duration,
    );
  }

  static void _drainQueue({
    BuildContext? context,
    required int particleCount,
    required Duration duration,
  }) {
    if (_isPlaying || _pendingBursts <= 0) return;
    _isPlaying = true;
    _pendingBursts -= 1;
    _playOnce(
      context: context,
      particleCount: particleCount,
      duration: duration,
    ).whenComplete(() {
      _isPlaying = false;
      _drainQueue(
        context: context,
        particleCount: particleCount,
        duration: duration,
      );
    });
  }

  static Future<void> _playOnce({
    BuildContext? context,
    required int particleCount,
    required Duration duration,
  }) async {
    final overlay =
        navigatorKey.currentState?.overlay ??
        _tryGetOverlayFromContext(context);
    if (overlay == null) return;
    final controller = ConfettiController(duration: duration);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: controller,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.035,
                numberOfParticles: particleCount,
                maxBlastForce: 32,
                minBlastForce: 18,
                gravity: 0.22,
                colors: const [
                  Color(0xFFD4A24C),
                  Color(0xFFE07B63),
                  Color(0xFF7FA5C8),
                  Color(0xFF7DB87C),
                  Color(0xFFB896D6),
                  Color(0xFFE8BD6A),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    controller.play();
    await Future.delayed(duration + const Duration(milliseconds: 260));
    entry.remove();
    controller.dispose();
  }

  static OverlayState? _tryGetOverlayFromContext(BuildContext? context) {
    if (context == null) return null;
    return Overlay.of(context, rootOverlay: true);
  }
}
