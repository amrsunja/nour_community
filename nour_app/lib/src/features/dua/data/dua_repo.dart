import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/dua_remote_datasource.dart';
import 'models/daily_dua_status_model.dart';
import 'models/dua_model.dart';
import 'models/dua_progress_model.dart';

final duaRepoProvider = Provider(
  (ref) => DuaRepo(
    remoteDatasource: ref.read(duaRemoteDataProvider),
  ),
);

class DuaRepo {
  final DuaRemoteDatasource remoteDatasource;

  DuaRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<DuaModel>>> getDuas() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getDuas());
  }

  Future<SuccessOrError<DuaProgressModel>> getProgress() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getProgress());
  }

  Future<SuccessOrError<DuaProgressModel>> saveProgress({
    required int duaId,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.saveProgress(duaId: duaId),
    );
  }

  Future<SuccessOrError<void>> awardDuaAjr({required int duaId}) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.awardDuaAjr(duaId: duaId),
    );
  }

  Future<SuccessOrError<DailyDuaStatusModel>> getDailyDuaStatus() async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getDailyDuaStatus(),
    );
  }

  Future<SuccessOrError<int>> awardDailyDuaAjr({int ajr = 5}) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.awardDailyDuaAjr(ajr: ajr),
    );
  }

  Future<SuccessOrError<Set<int>>> getLikedDuas() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getLikedDuas());
  }

  Future<SuccessOrError<void>> likeDua(int duaId) async {
    return Failure.exceptionsCatcher(() => remoteDatasource.likeDua(duaId));
  }

  Future<SuccessOrError<void>> unlikeDua(int duaId) async {
    return Failure.exceptionsCatcher(() => remoteDatasource.unlikeDua(duaId));
  }
}
