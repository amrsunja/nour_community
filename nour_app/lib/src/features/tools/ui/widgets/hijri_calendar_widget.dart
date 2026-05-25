import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_strings.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';

import 'hijri_day_cell_widget.dart';

/// Month calendar widget: a header with prev/next month controls and the
/// Hijri month name + Gregorian span, a weekday row, and the weekday-aligned
/// grid of [HijriDayCellWidget]s.
class HijriCalendarWidget extends StatelessWidget {
  const HijriCalendarWidget({
    super.key,
    required this.view,
    required this.onPrev,
    required this.onNext,
  });

  final HijriMonthView view;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  String _gregorianSpan(String lang) {
    final start = view.firstDayGregorian;
    final end = view.firstDayGregorian.add(
      Duration(days: view.daysInMonth - 1),
    );
    final startMonth = DateFormat('MMMM', lang).format(start);
    final endMonth = DateFormat('MMMM', lang).format(end);
    if (start.year == end.year && start.month == end.month) {
      return '$startMonth ${end.year}';
    }
    if (start.year == end.year) {
      return '$startMonth - $endMonth ${end.year}';
    }
    return '$startMonth ${start.year} - $endMonth ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final materialL10n = MaterialLocalizations.of(context);
    // narrowWeekdays is Sunday-first; the grid is also built Sunday-first.
    final weekdays = materialL10n.narrowWeekdays;

    return Column(
      children: [
        // Header
        Row(
          children: [
            _NavButton(icon: Icons.chevron_left, onTap: onPrev),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${HijriStrings.monthName(view.month, lang)} ${view.year}',
                    style: theme.typo.inter.headline.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _gregorianSpan(lang),
                    style: theme.typo.inter.bodySmall.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                ],
              ),
            ),
            _NavButton(icon: Icons.chevron_right, onTap: onNext),
          ],
        ),
        const SizedBox(height: 16),
        // Weekday labels (Sunday-first).
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    weekdays[i],
                    style: theme.typo.inter.bodyMedium.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Day grid.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.9,
          ),
          itemCount: view.cells.length,
          itemBuilder: (context, index) => HijriDayCellWidget(
            cell: view.cells[index],
            languageCode: lang,
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: UIColorsToken.yellow, size: 28),
      ),
    );
  }
}
