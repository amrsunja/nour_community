import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'datasources/onboarding_local_datasource.dart';

final onboardingRepoProvider = Provider(
  (ref) => OnboardingRepo(
    localDatasource: ref.read(onboardingLocalDataProvider)
  ),
);

class OnboardingRepo {
  final OnboardingLocalDatasource localDatasource;

  OnboardingRepo({
    required this.localDatasource
  });
}
