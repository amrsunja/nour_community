import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/tools/data/datasources/zakat_remote_datasource.dart';

import 'models/zakat_api_result.dart';

final zakatRepoProvider = Provider(
  (ref) => ZakatRepo(
    localDatasource: ref.read(zakatRemoteDataProvider),
  ),
);

class ZakatRepo {
  final ZakatRemoteDatasource localDatasource;

  ZakatRepo({required this.localDatasource});

  Future<SuccessOrError<ZakatApiResult>> calculateMoneyZakat(double amount) {
    return Failure.exceptionsCatcher(() async => await localDatasource.calculateMoneyZakat(amount));
  }
}
