import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../widgets/reward_scaffold.dart';
import '../widgets/reward_streak_flame.dart';
import '../widgets/reward_week_row.dart';

/// Reward shown each time the user banks a new streak day. Pushed by the
/// realtime reward coordinator; displays "Day N" with the week progress.
@RoutePage()
class RewardStreakPage extends ConsumerWidget {
  const RewardStreakPage({
    super.key,
    @QueryParam('streakDay') this.streakDay = 1,
  });

  final int streakDay;

  /// Mon→Sun states. Past days inside the streak (and today, just banked) are
  /// validated; earlier ones missed; future ones upcoming. A completed 7-day
  /// streak fills the whole week. Mirrors the dashboard logic.
  List<UIStreakDayState> _weekStates() {
    if (streakDay >= 7) {
      return List.filled(7, UIStreakDayState.validated);
    }
    final todayIdx = DateTime.now().weekday - 1; // 0 = Monday
    return List.generate(7, (i) {
      if (i > todayIdx) return UIStreakDayState.upcoming;
      if (i == todayIdx) return UIStreakDayState.validated; // today: done
      final daysAgo = todayIdx - i;
      return daysAgo < streakDay
          ? UIStreakDayState.validated
          : UIStreakDayState.missed;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);

    return RewardScaffold(
      badge: RewardStreakFlame(streakDay: streakDay),
      title: l10n.reward_streak_day_title(streakDay),
      subtitle: l10n.reward_streak_congrats(streakDay),
      content: RewardWeekRow(states: _weekStates()),
      primaryLabel: l10n.reward_alhamdulilah,
      secondaryLabel: l10n.reward_go_further,
      onPrimary: context.pop,
      onSecondary: () {
        context.pop();
        nav.toDhikrsList();
      },
    );
  }
}
