import 'package:hooks_riverpod/hooks_riverpod.dart';

final onboardingRemoteDataProvider = Provider(
  (ref) => OnboardingRemoteDatasource(),
);

class OnboardingRemoteDatasource {
}
