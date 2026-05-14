import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';

import '../../data/onboarding_repo.dart';
import 'onboarding_state.dart';

final onboardingProvider = StateNotifierProvider(
	(ref) => OnboardingPresenter(
		repo: ref.read(onboardingRepoProvider),
		appEvents: ref.read(appEventProvider),
	)
);

class OnboardingPresenter extends Presenter<OnboardingState> {
	final OnboardingRepo repo;
	final AppEvents appEvents;

	OnboardingPresenter({
		required this.repo,
		required this.appEvents
	}) : super(
		OnboardingState(isLoading: false)
	);

	Future<void> onboardingCompeleted() async {
		state = state.copyWith(isLoading: true);
		state = state.copyWith(isLoading: false);
	}
}
