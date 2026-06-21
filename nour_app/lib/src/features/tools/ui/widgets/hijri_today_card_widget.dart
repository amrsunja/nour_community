import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_strings.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';

/// Green hero card at the top of the Hijri calendar page: "Today" label, an
/// optional "White day" badge, the Hijri date and the Gregorian date.
class HijriTodayCardWidget extends StatelessWidget {
  const HijriTodayCardWidget({
    super.key,
    required this.today,
    required this.todayLabel,
    required this.whiteDayLabel,
  });

  final HijriDate today;
  final String todayLabel;
  final String whiteDayLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final isWhiteDay = HijriTool.isWhiteDay(today.day);

    final hijriText =
        '${today.day} ${HijriStrings.monthName(today.month, lang)} ${today.year}';
    final gregorianText =
        DateFormat('EEEE, MMMM d, yyyy', lang).format(today.gregorian);

    return UICard(
      disableBorder: true,
      borderRadius: 12,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xff45513F), Color(0xff2B3326)],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  todayLabel,
                  style: theme.typo.inter.title.copyWith(
                    color: UIColorsToken.textYellow
                  ),
                ),
              ),
              if (isWhiteDay) _WhiteDayBadge(label: whiteDayLabel),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hijriText,
            style: theme.typo.inter.largeTitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gregorianText,
            style: theme.typo.inter.title.copyWith(
              color: UIColorsToken.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteDayBadge extends StatelessWidget {
  const _WhiteDayBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UIColorsToken.yellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UIColorsToken.textYellow, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: UIColorsToken.textYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.textYellow,
            ),
          ),
        ],
      ),
    );
  }
}
