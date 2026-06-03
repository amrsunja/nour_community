import 'package:equatable/equatable.dart';

import '../../data/models/statistics_models.dart';

/// Hand-written immutable state (no freezed codegen) for the profile
/// statistics page. Holds the active [range], the last loaded [stats], and a
/// [isLoading] flag while a range is fetched.
class StatisticsState extends Equatable {
  final bool isLoading;
  final StatRange range;
  final UserStatistics? stats;

  const StatisticsState({
    this.isLoading = false,
    this.range = StatRange.all,
    this.stats,
  });

  StatisticsState copyWith({
    bool? isLoading,
    StatRange? range,
    UserStatistics? stats,
  }) =>
      StatisticsState(
        isLoading: isLoading ?? this.isLoading,
        range: range ?? this.range,
        stats: stats ?? this.stats,
      );

  @override
  List<Object?> get props => [isLoading, range, stats];
}
