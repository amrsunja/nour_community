import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/src/tokens/colors/ui_colors_token.dart';

class UISliderProgressBar extends StatelessWidget {
  const UISliderProgressBar({
    super.key,
    required this.totalCount,
    required this.currentIndex,
    this.color = UIColorsToken.yellow,
  });

  final int totalCount;
  final int currentIndex;

  /// Pill color — the active pill is opaque, the others at 40%.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: 2,
      children: List.generate(totalCount, (ind) {
        final isCurrent = currentIndex == ind;
        return AnimatedContainer(
          duration: Durations.medium2,
          width: isCurrent ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isCurrent ? 1 : 0.4),
            borderRadius: .circular(100)
          ),
        );
      }),
    );
  }
}


