import 'package:hooks_riverpod/hooks_riverpod.dart';

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
}
