import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
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
    final profile = ref.watch(profileProvider).profile;
    final streak = profile?.currentStreak ?? 0;
    final ajr = profile?.earnedAjrCount ?? 0;
    const ajrGoal = 33;

    return Scaffold(
      appBar: UIProfileAppBar(
        name: profile?.name ?? 'Undefined',
        trailing: UIStreakCard(current: streak, total: 7),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              UIStreakWeek(
                states: _weekStates(streak),
                streakCount: streak + 2,
              ),
              const UISpace.vert(16),
              UIDailyAdhkarCard(
                title: 'Daily Ajr Goal',
                subtitle: '$ajr/$ajrGoal dikr per day',
                currentCount: ajr,
                totalCount: ajrGoal,
                buttonTitle: 'Start dikr',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
