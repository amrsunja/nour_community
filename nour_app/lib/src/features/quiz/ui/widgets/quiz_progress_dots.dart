
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// The row of step dots at the top of the quiz. The dot at [currentIndex]
/// grows into a yellow pill; answered dots stay solid yellow, upcoming dots
/// are dimmed.
class QuizProgressDots extends StatelessWidget {
  const QuizProgressDots({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: ListView.separated(
      shrinkWrap: true,
        scrollDirection: .horizontal,
        itemCount: total,
        separatorBuilder: (context, ind) {
          return SizedBox(
            width: 35,
            child: Divider(
              color: UIColorsToken.yellow.withValues(alpha: .5),
              thickness: 0.4,
            ),
          );
        },
        itemBuilder: (context, i) {
          final done = i <= currentIndex;
          final isCurrent = i == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isCurrent
                ? UIColorsToken.textYellow
                : UIColorsToken.yellow.withValues(alpha: done ? 0.4 : 0.15),
              borderRadius: BorderRadius.circular(100),
              boxShadow: done ? UIShadowToken.sliderBull : null
            ),
          );

        },
      ),
    );
  }
}
