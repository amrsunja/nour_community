import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/src/tokens/colors/ui_colors_token.dart';

class UISliderProgressBar extends StatelessWidget {
  const UISliderProgressBar({
    super.key,
    required this.totalCount,
    required this.currentIndex,
  });

  final int totalCount;
  final int currentIndex;

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
            color: UIColorsToken.yellow.withValues(alpha: isCurrent ? 1 : 0.4),
            borderRadius: .circular(100)
          ),
        );
      }),
    );
  }
}


