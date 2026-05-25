import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_strings.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';

import '../widgets/hijri_calendar_widget.dart';
import '../widgets/hijri_event_card_widget.dart';
import '../widgets/hijri_today_card_widget.dart';

@RoutePage()
class CalendarPage extends HookConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;

    final today = useMemoized(() => HijriTool.today());
    final events = useMemoized(() => HijriTool.upcomingEvents(max: 5));

    final year = useState<int>(today.year);
    final month = useState<int>(today.month);

    final view = useMemoized(
      () => HijriTool.monthView(year.value, month.value),
      [year.value, month.value],
    );

    void goPrev() {
      final (y, m) = HijriTool.previousMonth(year.value, month.value);
      year.value = y;
      month.value = m;
    }

    void goNext() {
      final (y, m) = HijriTool.nextMonth(year.value, month.value);
      year.value = y;
      month.value = m;
    }

    return UIGradientLinedScaffold(
      bgArabicText: '',
      appBar: UIAppBar(
        title: l10n.tools_hijri_calendar,
        onBack: context.pop,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIAppearAnimation(
                child: HijriTodayCardWidget(
                  today: today,
                  todayLabel: l10n.hijri_today,
                  whiteDayLabel: l10n.hijri_white_day,
                ),
              ),
              const SizedBox(height: 24),
              UIAppearAnimation(
                delay: Duration(milliseconds: 300),
                child: HijriCalendarWidget(
                  view: view,
                  onPrev: goPrev,
                  onNext: goNext,
                ),
              ),
              const SizedBox(height: 28),
              UIAppearAnimation(
                delay: Duration(milliseconds: 600),
                child: Text(
                  l10n.hijri_coming_up,
                  style: theme.typo.inter.title.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < events.length; i++) ...[
                UIAppearAnimation(
                  delay: Duration(milliseconds: 600 + (i * 300)),
                  child: HijriEventCardWidget(
                    name: HijriStrings.eventName(events[i].event.id, lang),
                    relative: l10n.hijri_in_days(events[i].daysUntil),
                    highlighted: i == 0,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
