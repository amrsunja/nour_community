import 'package:hooks_riverpod/hooks_riverpod.dart';

final onboardingLocalDataProvider = Provider(
  (ref) => OnboardingLocalDatasource(),
);

class OnboardingLocalDatasource {}
