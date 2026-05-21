import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// A single horizontal progress line. The yellow fill represents
/// `current / total` and animates whenever that fraction changes.
///
/// ```dart
/// UIProgressLine(current: 10, total: 50)
/// ```
class UIProgressLine extends StatelessWidget {
  const UIProgressLine({
    super.key,
    required this.current,
    required this.total,
    this.height = 8,
    this.trackColor,
    this.fillColor,
    this.duration = const Duration(milliseconds: 450),
  });

  final double current;
  final double total;
  final double height;
  final Color? trackColor;
  final Color? fillColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final percent = (total <= 0 ? 0.0 : current / total).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Container(
                height: height,
                width: constraints.maxWidth,
                color: trackColor ?? UIColorsToken.white.withValues(alpha: 0.3),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent),
                duration: duration,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Container(
                    height: height,
                    width: constraints.maxWidth * value,
                    decoration: BoxDecoration(
                      color: fillColor ?? UIColorsToken.yellow,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
