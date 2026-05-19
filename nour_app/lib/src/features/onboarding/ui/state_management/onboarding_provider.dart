import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

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
		OnboardingState(
      isLoading: false,
      currentPage: 0
    )
	);

  void changePage(int page) async {
    state = state.copyWith(currentPage: page);
  }

  void goToPreviousPage() async {
    final previousPage = state.currentPage - 1;

    state = state.copyWith(currentPage: previousPage > 0 ? previousPage : 0);
  }
}
