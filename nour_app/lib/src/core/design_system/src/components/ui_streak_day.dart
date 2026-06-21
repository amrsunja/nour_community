import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Visual state of a single day in a streak row.
///
/// - [upcoming]: default, neutral gray outline.
/// - [actual]: the current day, filled yellow with a halo ring.
/// - [missed]: a skipped day, red outline.
/// - [validated]: a completed day, filled green with a halo ring.
enum UIStreakDayState { upcoming, actual, missed, validated }

/// A single streak day chip: a circular badge with a one-letter [day] tag,
/// styled by [state].
///
/// ```dart
/// UIStreakDay(day: 'M', state: UIStreakDayState.validated)
/// ```
class UIStreakDay extends StatelessWidget {
  const UIStreakDay({
    super.key,
    required this.day,
    this.state = UIStreakDayState.upcoming,
    this.size = 56,
    this.onTap,
  });

  /// One-letter day tag (e.g. `M`, `T`).
  final String day;
  final UIStreakDayState state;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    final label = Text(
      day,
      maxLines: 1,
      style: typo.inter.caption.copyWith(color: UIColorsToken.white),
    );

    final inner = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _fillColor,
        border: _innerBorder,
      ),
      child: label,
    );

    return UITap(
      onTap: onTap,
      child: _ringColor == null
          ? inner
          : Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _ringColor!, width: 1),
              ),
              child: inner,
            ),
    );
  }

  Color get _fillColor => switch (state) {
        UIStreakDayState.actual => UIColorsToken.yellow,
        UIStreakDayState.validated => UIColorsToken.green,
        _ => const Color(0x00000000),
      };

  Border? get _innerBorder => switch (state) {
        UIStreakDayState.upcoming =>
          Border.all(color: UIColorsToken.stroke, width: 1),
        UIStreakDayState.missed =>
          Border.all(color: UIColorsToken.red, width: 1),
        _ => null,
      };

  /// Outer halo ring color, or null when the state has no ring.
  Color? get _ringColor => switch (state) {
        UIStreakDayState.actual => UIColorsToken.yellow,
        UIStreakDayState.validated => UIColorsToken.green,
        _ => null,
      };
}
