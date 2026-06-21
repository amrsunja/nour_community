import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Overlays a field of softly twinkling, glowing stars on top of [child].
///
/// Each star fades + scales in/out on its own loop, producing a continuous
/// shimmering night-sky effect. Purely decorative: ignores pointer events.
class UiRepeatingStarsAnimation extends HookWidget {
  const UiRepeatingStarsAnimation({
    super.key,
    required this.child,
    this.starCount = 18,
    this.color = UIColorsToken.yellow,
    this.minSize = 1.5,
    this.maxSize = 4.0,
    this.seed = 7,
  });

  final Widget child;
  final int starCount;
  final Color color;
  final double minSize;
  final double maxSize;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 6),
    );

    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, const []);

    final stars = useMemoized(
      () => _generateStars(starCount, seed, minSize, maxSize),
      [starCount, seed, minSize, maxSize],
    );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => CustomPaint(
                painter: _StarsPainter(
                  stars: stars,
                  progress: controller.value,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<_Star> _generateStars(int count, int seed, double min, double max) {
    final rnd = math.Random(seed);
    return List.generate(count, (_) {
      return _Star(
        dx: rnd.nextDouble(),
        dy: rnd.nextDouble(),
        size: min + rnd.nextDouble() * (max - min),
        phase: rnd.nextDouble(),
        speed: 0.6 + rnd.nextDouble() * 0.8,
      );
    });
  }
}

class _Star {
  const _Star({
    required this.dx,
    required this.dy,
    required this.size,
    required this.phase,
    required this.speed,
  });

  final double dx;
  final double dy;
  final double size;
  final double phase;
  final double speed;
}

class _StarsPainter extends CustomPainter {
  _StarsPainter({
    required this.stars,
    required this.progress,
    required this.color,
  });

  final List<_Star> stars;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Per-star twinkle: smooth 0..1..0 loop offset by its phase.
      final t = (progress * star.speed + star.phase) % 1.0;
      final twinkle = (math.sin(t * 2 * math.pi) + 1) / 2;
      final opacity = 0.15 + twinkle * 0.85;
      final radius = star.size * (0.6 + twinkle * 0.6);

      final center = Offset(star.dx * size.width, star.dy * size.height);

      // Glow halo.
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 1.6);
      canvas.drawCircle(center, radius * 1.8, glowPaint);

      // Core.
      final corePaint = Paint()..color = color.withValues(alpha: opacity);
      _drawSparkle(canvas, center, radius, corePaint);
    }
  }

  /// Draws a 4-point sparkle (plus-shaped star).
  void _drawSparkle(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    final long = r;
    final short = r * 0.28;
    path
      ..moveTo(c.dx, c.dy - long)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + short, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + long, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + short)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + long)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - short, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - long, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - short)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - long)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}
