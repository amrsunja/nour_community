import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/statistics_remote_datasource.dart';
import 'models/statistics_models.dart';

final statisticsRepoProvider = Provider(
  (ref) => StatisticsRepo(
    remoteDatasource: ref.read(statisticsRemoteDataProvider),
  ),
);

class StatisticsRepo {
  final StatisticsRemoteDatasource remoteDatasource;

  StatisticsRepo({required this.remoteDatasource});

  /// Aggregated profile counters for [range].
  Future<SuccessOrError<UserStatistics>> fetchStatistics(StatRange range) async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.fetchStatistics(range);
    });
  }
}
