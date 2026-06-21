import 'dart:async';
import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../../data/models/reward_models.dart';
import '../../data/reward_repo.dart';
import 'reward_event.dart';
import 'reward_state.dart';

/// Coordinator that watches the user's realtime `daily_activity` row and emits
/// a single event the first time each reward becomes due — once per day,
/// claimed atomically server-side.
final rewardProvider =
    StateNotifierProvider<RewardPresenter, RewardState>((ref) {
  return RewardPresenter(repo: ref.read(rewardRepoProvider));
});

/// Listens to [RewardPresenter] single events and pushes the matching reward
/// page. Mounted (watched) from the authenticated `HomePage`.
final rewardListenerProvider = Provider<void>((ref) {
  final nav = ref.read(navigationServicesProvider);

  final sub = ref.read(rewardProvider.notifier).singleEvents.listen((event) {
    if (event is ShowStreakRewardEvent) {
      nav.toStreakReward(streakDay: event.streakDay);
    } else if (event is ShowDailyDhikrRewardEvent) {
      nav.toDailyDhikrReward(
        dhikrCompleted: event.dhikrCompleted,
        ajrEarned: event.ajrEarned,
      );
    }
  });

  ref.onDispose(sub.cancel);
});

class RewardPresenter extends EventPresenter<RewardState, RewardEvent> {
  final RewardRepo repo;

  RewardPresenter({required this.repo}) : super(const RewardState());

  /// Total daily dhikr goal — matches the dashboard goal.
  static const int dailyDhikrGoal = 33;

  /// Streak is capped at 7 days by the backend.
  static const int maxStreakDay = 7;

  StreamSubscription<DailyActivityModel?>? _sub;

  /// In-flight guards: a claim's `seen` flip only echoes back via realtime
  /// after a round-trip, so we mute re-evaluation until then to avoid double
  /// claims.
  bool _streakClaiming = false;
  bool _dhikrClaiming = false;

  /// Idempotent — safe to call on every `HomePage` mount.
  void init() {
    _sub?.cancel();
    _sub = repo.watchTodayActivity().listen(
      _onActivity,
      onError: (Object e) => talker.error('reward realtime: $e'),
    );
  }

  void _onActivity(DailyActivityModel? activity) {
    if (activity == null) return;
    state = state.copyWith(activity: activity);
    _maybeStreakReward(activity);
    _maybeDhikrReward(activity);
  }

  Future<void> _maybeStreakReward(DailyActivityModel a) async {
    if (!a.streakCounted || a.streakRewardSeen || _streakClaiming) return;

    _streakClaiming = true;
    try {
      final claim = await repo.claimStreakReward();
      final won = claim.when((w) => w, (_) => false);
      if (!won) return;

      final streakRes = await repo.fetchCurrentStreak();
      final day = streakRes.when(
        (s) => s,
        (_) => a.streakCounted ? 1 : 0,
      );
      final clamped = math.max(1, math.min(maxStreakDay, day));
      send(ShowStreakRewardEvent(clamped));
    } finally {
      _streakClaiming = false;
    }
  }

  Future<void> _maybeDhikrReward(DailyActivityModel a) async {
    if (a.dhikrCount < dailyDhikrGoal || a.dhikrRewardSeen || _dhikrClaiming) {
      return;
    }

    _dhikrClaiming = true;
    try {
      final claim = await repo.claimDhikrReward();
      final won = claim.when((w) => w, (_) => false);
      if (!won) return;

      send(ShowDailyDhikrRewardEvent(
        dhikrCompleted: a.dhikrCount,
        ajrEarned: a.dhikrAjr,
      ));
    } finally {
      _dhikrClaiming = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
