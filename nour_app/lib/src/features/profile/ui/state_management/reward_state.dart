import 'package:equatable/equatable.dart';

import '../../data/models/reward_models.dart';

/// Hand-written immutable state (no freezed codegen) holding the latest
/// realtime `daily_activity` snapshot. Reward delivery itself is done through
/// single events, not state.
class RewardState extends Equatable {
  final DailyActivityModel? activity;

  const RewardState({this.activity});

  RewardState copyWith({DailyActivityModel? activity}) =>
      RewardState(activity: activity ?? this.activity);

  @override
  List<Object?> get props => [activity];
}
