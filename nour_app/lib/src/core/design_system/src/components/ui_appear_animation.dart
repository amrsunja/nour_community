import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Fluid entrance animation used across the app — fades in, slides up,
/// and softly scales the child. Compose with [delay] to stagger siblings.
///
/// ```dart
/// UIAppearAnimation(
///   delay: const Duration(milliseconds: 150),
///   child: Text('hello'),
/// );
/// ```
class UIAppearAnimation extends StatelessWidget {
  const UIAppearAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.offsetY = 24,
    this.beginScale = 0.96,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Pixels the child slides up from.
  final double offsetY;

  /// Initial scale (1.0 = no scaling).
  final double beginScale;

  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .moveY(
          begin: offsetY,
          end: 0,
          duration: duration,
          curve: curve,
        )
        .scaleXY(
          begin: beginScale,
          end: 1.0,
          duration: duration,
          curve: curve,
        );
  }
}
