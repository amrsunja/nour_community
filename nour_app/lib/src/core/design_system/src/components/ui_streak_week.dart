import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Weekly streak progress card.
///
/// Shows a row of seven [UIStreakDay] chips. When [streakCount] > 0, tapping
/// the card flips it — with a short fade/scale animation — to an info state
/// that frames a streak message between two flame illustrations. Tapping again
/// flips back.
///
/// ```dart
/// UIStreakWeek(
///   states: [
///     UIStreakDayState.validated,
///     UIStreakDayState.actual,
///     UIStreakDayState.upcoming,
///     ...
///   ],
///   streakCount: 2,
/// )
/// ```
class UIStreakWeek extends StatefulWidget {
  const UIStreakWeek({
    super.key,
    required this.states,
    this.dayTags = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.streakCount = 0,
    this.message,
  });

  /// Per-day states, one entry per day in [dayTags].
  final List<UIStreakDayState> states;

  /// One-letter tag for each day.
  final List<String> dayTags;

  /// Number of streak days; drives the info message and whether tapping
  /// reveals the info state.
  final int streakCount;

  /// Overrides the default info message.
  final String? message;

  @override
  State<UIStreakWeek> createState() => _UIStreakWeekState();
}

class _UIStreakWeekState extends State<UIStreakWeek> {
  bool _showInfo = false;

  bool get _canShowInfo => widget.streakCount > 0;

  void _toggle() {
    if (!_canShowInfo) return;
    setState(() => _showInfo = !_showInfo);
  }

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UITap(
      onTap: _toggle,
      child: Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: UIColorsToken.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: _showInfo
              ? _InfoState(
                  key: const ValueKey('info'),
                  message: widget.message ??
                      "You're on the ${widget.streakCount} days streak !",
                  typo: typo,
                )
              : _DaysState(
                  key: const ValueKey('days'),
                  states: widget.states,
                  dayTags: widget.dayTags,
                ),
        ),
      ),
    );
  }
}

class _DaysState extends StatelessWidget {
  const _DaysState({
    super.key,
    required this.states,
    required this.dayTags,
  });

  final List<UIStreakDayState> states;
  final List<String> dayTags;

  @override
  Widget build(BuildContext context) {
    final count = dayTags.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (i) {
        return UIStreakDay(
          day: dayTags[i],
          state: i < states.length ? states[i] : UIStreakDayState.upcoming,
          size: 31,
        );
      }),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    super.key,
    required this.message,
    required this.typo,
  });

  final String message;
  final UITypographyToken typo;

  @override
  Widget build(BuildContext context) {
    final flame = Assets.images.illustration10.image(
      fit: BoxFit.contain,
    );

    return Row(
      children: [
        flame,
        Expanded(
          child: Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typo.inter.title.copyWith(color: UIColorsToken.white),
          ),
        ),
        flame,
      ],
    );
  }
}
