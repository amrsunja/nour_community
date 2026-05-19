import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/onboarding_local_datasource.dart';
import 'datasources/onboarding_remote_datasource.dart';

final onboardingRepoProvider = Provider(
  (ref) => OnboardingRepo(
    localDatasource: ref.read(onboardingLocalDataProvider),
    remoteDatasource: ref.read(onboardingRemoteDataProvider),
  ),
);

class OnboardingRepo {
  final OnboardingLocalDatasource localDatasource;
  final OnboardingRemoteDatasource remoteDatasource;

  OnboardingRepo({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  Future<SuccessOrError<void>> selectLevel(LevelType level) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateLevel(level);
    });
  }
}
