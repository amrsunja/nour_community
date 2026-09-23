import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'ui_space.dart';

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

/// A [Column] whose children appear one after another with
/// [UIAppearAnimation] — the staggered entrance used by content pages.
///
/// Pure spacers ([SizedBox], [UISpace], [Spacer]) pass through untouched and
/// do not consume a stagger step, so separators keep the rhythm readable.
/// Delays are capped at [maxSteps] so long lists never end up waiting seconds.
///
/// ```dart
/// UIStaggerColumn(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     const _Header(),
///     const SizedBox(height: 12),
///     for (final item in items) _Row(item),
///   ],
/// );
/// ```
class UIStaggerColumn extends StatelessWidget {
  const UIStaggerColumn({
    super.key,
    required this.children,
    this.initialDelay = Duration.zero,
    this.step = const Duration(milliseconds: 70),
    this.maxSteps = 12,
    this.duration = const Duration(milliseconds: 550),
    this.offsetY = 20,
    this.beginScale = 0.98,
    this.curve = Curves.easeOutCubic,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;

  /// Delay before the first child starts.
  final Duration initialDelay;

  /// Delay added per animated child.
  final Duration step;

  /// Highest stagger index; children past it share the last delay.
  final int maxSteps;

  final Duration duration;
  final double offsetY;
  final double beginScale;
  final Curve curve;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  static bool _isSpacer(Widget w) => w is SizedBox || w is UISpace || w is Spacer;

  @override
  Widget build(BuildContext context) {
    var index = 0;
    final animated = <Widget>[];
    for (final child in children) {
      if (_isSpacer(child)) {
        animated.add(child);
        continue;
      }
      animated.add(
        UIAppearAnimation(
          delay: initialDelay + step * (index < maxSteps ? index : maxSteps),
          duration: duration,
          offsetY: offsetY,
          beginScale: beginScale,
          curve: curve,
          child: child,
        ),
      );
      index++;
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: animated,
    );
  }
}
