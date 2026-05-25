import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/dhikr/ui/state_management/dhikr_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

@RoutePage()
class DashboardPage extends HookConsumerWidget {
  const DashboardPage({super.key});

  /// Builds Mon→Sun day states from the profile streak count: past days within
  /// the streak are validated, earlier ones missed, today is the actual day,
  /// and future days are upcoming.
  List<UIStreakDayState> _weekStates(int streak) {
    final todayIdx = DateTime.now().weekday - 1; // 0 = Monday
    return List.generate(7, (i) {
      if (i > todayIdx) return UIStreakDayState.upcoming;
      if (i == todayIdx) return UIStreakDayState.actual;
      final daysAgo = todayIdx - i;
      return daysAgo < streak
          ? UIStreakDayState.validated
          : UIStreakDayState.missed;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final dhikrState = ref.watch(dhikrProvider);
    final profile = ref.watch(profileProvider).profile;
    final streak = profile?.currentStreak ?? 0;
    final dhikrsCount = dhikrState.dhikrs.fold(0, (count, d) => count + dhikrState.currentCountOf(d.id));
    final dhikrGoal = 33;

    return Scaffold(
      appBar: UIProfileAppBar(
        name: profile?.name ?? l10n.profile_guest,
        onAvatarTap: () => ref.read(navigationServicesProvider).toProfile(),
        trailing: UIStreakCard(current: streak, total: 7),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              UIStreakWeek(
                states: _weekStates(streak),
                streakCount: streak,
              ),
              const UISpace.vert(16),
              UIAppearAnimation(
                child: UIDailyAjrCard(
                  title: 'Daily Dhikr Goal',
                  subtitle: '$dhikrsCount/$dhikrGoal  dikr per day',
                  currentCount: dhikrsCount,
                  totalCount: dhikrGoal,
                  buttonTitle: 'Start dikr',
                  onTap: () => ref.read(navigationServicesProvider).toDhikrsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
