import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';

/// One day cell of the Hijri month grid: large Hijri day number with the
/// Gregorian "MMM d" beneath, a white-day marker dot and a today highlight.
class HijriDayCellWidget extends StatelessWidget {
  const HijriDayCellWidget({
    super.key,
    required this.cell,
    required this.languageCode,
  });

  final HijriDayCell cell;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    final dayColor = cell.inMonth
        ? UIColorsToken.white
        : UIColorsToken.white.withValues(alpha: 0.4);
    final gregorianColor = cell.inMonth
        ? UIColorsToken.textYellow.withValues(alpha: 0.8)
        : UIColorsToken.textYellow.withValues(alpha: 0.4);

    final gregorianLabel =
        DateFormat('MMM d', languageCode).format(cell.gregorian);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cell.isToday ? UIColorsToken.yellow.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: cell.isToday ? UIColorsToken.textYellow: Colors.transparent,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (cell.isWhiteDay)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: UIColorsToken.textYellow,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${cell.hijri.day}',
                  style: theme.typo.inter.bodyLarge.copyWith(
                    color: dayColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gregorianLabel,
                  style: theme.typo.inter.smallCaption.copyWith(
                    color: gregorianColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
