import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/dhikr_remote_datasource.dart';
import 'models/dhikr_model.dart';
import 'models/dhikr_progress_model.dart';

final dhikrRepoProvider = Provider(
  (ref) => DhikrRepo(
    remoteDatasource: ref.read(dhikrRemoteDataProvider),
  ),
);

class DhikrRepo {
  final DhikrRemoteDatasource remoteDatasource;

  DhikrRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<DhikrModel>>> getDhikrs() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getDhikrs();
    });
  }

  Future<SuccessOrError<List<DhikrProgressModel>>> getTodayProgress() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getTodayProgress();
    });
  }

  Future<SuccessOrError<Map<int, int>>> getTodayDhikrAjr() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getTodayDhikrAjr();
    });
  }

  Future<SuccessOrError<DhikrProgressModel>> saveProgress({
    required int dhikrId,
    required int count,
  }) async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.upsertProgress(dhikrId: dhikrId, count: count);
    });
  }
}
