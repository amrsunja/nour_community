
import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/src/components/animations/ui_repeat_shimer_animation.dart';

/// Hero glyph for the quiz reward screen: a gold check medallion sitting on a
/// scalloped green halo with a thin gold filigree ring — painted (no asset) so
/// it scales crisply and carries the yellow glow.
class QuizRewardBadge extends StatelessWidget {
  const QuizRewardBadge({super.key, this.size = 250});

  final double size;

  @override
  Widget build(BuildContext context) {

    return UiRepeatShimerAnimation(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          Assets.images.illustration4.path
        )
      ),
    );
  }
}
