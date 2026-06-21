import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/reward_remote_datasource.dart';
import 'models/reward_models.dart';

final rewardRepoProvider = Provider(
  (ref) => RewardRepo(
    remoteDatasource: ref.read(rewardRemoteDataProvider),
  ),
);

class RewardRepo {
  final RewardRemoteDatasource remoteDatasource;

  RewardRepo({required this.remoteDatasource});

  /// Live today's `daily_activity` row (or null until it exists). Errors
  /// surface via the stream's `onError`.
  Stream<DailyActivityModel?> watchTodayActivity() =>
      remoteDatasource.watchTodayActivity();

  /// Authoritative streak day to display at claim time.
  Future<SuccessOrError<int>> fetchCurrentStreak() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.fetchCurrentStreak();
    });
  }

  /// True when this call won the once-per-day claim for the streak reward.
  Future<SuccessOrError<bool>> claimStreakReward() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.claimStreakReward();
    });
  }

  /// True when this call won the once-per-day claim for the daily-dhikr reward.
  Future<SuccessOrError<bool>> claimDhikrReward() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.claimDhikrReward();
    });
  }
}
