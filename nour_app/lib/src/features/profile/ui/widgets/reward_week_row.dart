import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Bordered Mon→Sun row of streak chips shown on the streak reward, mirroring
/// the dashboard's week states. Each chip pops in with a short stagger.
class RewardWeekRow extends StatelessWidget {
  const RewardWeekRow({
    super.key,
    required this.states,
    this.dayTags = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.baseDelay = const Duration(milliseconds: 650),
  });

  final List<UIStreakDayState> states;
  final List<String> dayTags;
  final Duration baseDelay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: UIColorsToken.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dayTags.length, (i) {
          final chip = UIStreakDay(
            day: dayTags[i],
            state: i < states.length ? states[i] : UIStreakDayState.upcoming,
            size: 30,
          );

          return chip
              .animate(delay: baseDelay + Duration(milliseconds: 70 * i))
              .scaleXY(
                begin: 0.4,
                end: 1,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: const Duration(milliseconds: 300));
        }),
      ),
    );
  }
}
