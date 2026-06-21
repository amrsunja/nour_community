/// Single (fire-once) events emitted by [RewardPresenter] when a reward becomes
/// due. The listener provider turns these into a push navigation.
abstract class RewardEvent {
  const RewardEvent();
}

/// Show the streak-day reward for [streakDay] (1..7).
class ShowStreakRewardEvent extends RewardEvent {
  final int streakDay;
  const ShowStreakRewardEvent(this.streakDay);
}

/// Show the daily-dhikr reward with today's live totals.
class ShowDailyDhikrRewardEvent extends RewardEvent {
  final int dhikrCompleted;
  final int ajrEarned;

  const ShowDailyDhikrRewardEvent({
    required this.dhikrCompleted,
    required this.ajrEarned,
  });
}
