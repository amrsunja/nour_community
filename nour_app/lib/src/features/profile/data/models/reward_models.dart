import 'package:equatable/equatable.dart';

import 'package:nour/src/core/utils/typedefs.dart';

/// The two daily rewards surfaced by the realtime coordinator.
enum RewardType { streakDay, dailyDhikr }

/// Mirrors a `public.daily_activity` row (one per user per day).
///
/// This is the single realtime source of truth for both rewards:
///   * [streakCounted] + [streakRewardSeen] gate the streak-day reward.
///   * [dhikrCount] (vs the daily goal) + [dhikrRewardSeen] gate the
///     daily-dhikr reward.
class DailyActivityModel extends Equatable {
  final DateTime activityDate;
  final bool dhikrDone;
  final bool quickActionDone;
  final bool streakCounted;

  /// Live sum of today's `dhikr_progress.current_count` (kept in sync by the
  /// `fn_dhikr_progress_after_change` trigger). True total even past the goal.
  final int dhikrCount;

  /// Live sum of today's dhikr ajr (from `ajr_log`).
  final int dhikrAjr;

  final bool streakRewardSeen;
  final bool dhikrRewardSeen;

  const DailyActivityModel({
    required this.activityDate,
    required this.dhikrDone,
    required this.quickActionDone,
    required this.streakCounted,
    required this.dhikrCount,
    required this.dhikrAjr,
    required this.streakRewardSeen,
    required this.dhikrRewardSeen,
  });

  factory DailyActivityModel.fromJson(Json json) => DailyActivityModel(
        activityDate:
            DateTime.tryParse(json['activity_date'] ?? '') ?? DateTime.now(),
        dhikrDone: json['dhikr_done'] ?? false,
        quickActionDone: json['quick_action_done'] ?? false,
        streakCounted: json['streak_counted'] ?? false,
        dhikrCount: json['dhikr_count'] ?? 0,
        dhikrAjr: json['dhikr_ajr'] ?? 0,
        streakRewardSeen: json['streak_reward_seen'] ?? false,
        dhikrRewardSeen: json['dhikr_reward_seen'] ?? false,
      );

  @override
  List<Object?> get props => [
        activityDate,
        dhikrDone,
        quickActionDone,
        streakCounted,
        dhikrCount,
        dhikrAjr,
        streakRewardSeen,
        dhikrRewardSeen,
      ];
}
