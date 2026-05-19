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

  /// Persists the chosen [level] to the user's Supabase profile.
  /// Returns true on success so the caller can advance the page.
  Future<bool> selectLevel(LevelType level) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.selectLevel(level);

    return response.when(
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }
}
