import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_strings.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/features/tools/ui/widgets/prayer_extra_times_widget.dart';
import 'package:nour/src/features/tools/ui/widgets/prayer_time_widget.dart';

import '../../data/models/mosque_prayer_day_model.dart';
import 'mosque_format.dart';

/// "Today's prayer times" of a mosque (public profile, Prayers tab).
/// [day] = mosque schedule (null → [fallback] computed times are shown with a
/// caption).
class MosquePrayersTab extends StatelessWidget {
  const MosquePrayersTab({
    super.key,
    required this.l10n,
    required this.day,
    required this.fallback,
    required this.todayDate,
    this.footer,
  });

  final AppLocale l10n;
  final MosquePrayerDayModel? day;
  final DailyPrayerTimes? fallback;
  final DateTime todayDate;
  final Widget? footer;

  static String slotTitle(AppLocale l10n, PrayerSlot slot) => switch (slot) {
        PrayerSlot.fajr => l10n.notifications_prayer_fajr,
        PrayerSlot.dhuhr => l10n.notifications_prayer_dhuhr,
        PrayerSlot.asr => l10n.notifications_prayer_asr,
        PrayerSlot.maghrib => l10n.notifications_prayer_maghrib,
        PrayerSlot.isha => l10n.notifications_prayer_isha,
      };

  static AssetGenImage slotImage(PrayerSlot slot) => switch (slot) {
        PrayerSlot.fajr => Assets.images.prayerTimeFajr,
        PrayerSlot.dhuhr => Assets.images.prayerTimeDuhr,
        PrayerSlot.asr => Assets.images.prayerTimeAsr,
        PrayerSlot.maghrib => Assets.images.prayerTimeMaghrib,
        PrayerSlot.isha => Assets.images.prayerTimeIsha,
      };

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final times = day != null && !day!.isEmpty ? day!.toDailyPrayerTimes(fallback: fallback) : fallback;

    final hijri = HijriTool.fromGregorian(todayDate);
    final hijriText = '${hijri.day} ${HijriStrings.monthName(hijri.month, lang)} ${hijri.year}';
    final gregorian = DateFormat('EEE d MMM', lang).format(todayDate);

    PrayerSlot? next;
    DateTime? nextTime;
    if (times != null) {
      final now = DateTime.now();
      for (final s in IslamicTools.orderedSlots) {
        if (times.forSlot(s).isAfter(now)) {
          next = s;
          nextTime = times.forSlot(s);
          break;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.mosque_today_prayer_times,
                    style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
              ),
              Text('$hijriText  |  $gregorian',
                  style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
            ],
          ),
          if (times == null) ...[
            const SizedBox(height: 24),
            Center(
              child: Text(l10n.mosque_prayer_times_unavailable,
                  textAlign: TextAlign.center,
                  style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
            ),
          ] else ...[
            if (day == null || day!.isEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.mosque_prayer_times_computed_hint,
                  style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
            ],
            const SizedBox(height: 16),
            for (final slot in IslamicTools.orderedSlots) ...[
              PrayerTimeWidget(
                title: slotTitle(l10n, slot),
                time: times.forSlot(slot),
                offsetMinutes: day?.offsetFor(slot) ?? MosquePrayerDayModel.defaultOffsets[slot] ?? 0,
                notify: false,
                hideNotify: true,
                onToggleNotify: () {},
                isNext: next == slot,
                backgroundImage: next == slot ? slotImage(slot) : null,
                countdownTarget: next == slot ? nextTime : null,
              ),
              const SizedBox(height: 16),
            ],
            PrayerExtraTimesWidget(
              chouroukLabel: l10n.prayer_times_chourouk,
              chouroukTime: MosqueFormat.hhmmDate(times.sunrise),
              jumuaLabel: l10n.prayer_times_jumua,
              jumuaTime: day?.jumua != null ? MosqueFormat.hhmm(day!.jumua) : '--:--',
            ),
          ],
          if (footer != null) ...[const SizedBox(height: 20), footer!],
        ],
      ),
    );
  }
}
