import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../../data/onboarding_repo.dart';
import 'onboarding_state.dart';

final onboardingProvider = StateNotifierProvider(
	(ref) => OnboardingPresenter(
		repo: ref.read(onboardingRepoProvider),
		ref: ref,
		appEvents: ref.read(appEventProvider),
	)
);

class OnboardingPresenter extends Presenter<OnboardingState> {
	final OnboardingRepo repo;
	final Ref ref;
	final AppEvents appEvents;

	OnboardingPresenter({
		required this.repo,
		required this.ref,
		required this.appEvents
	}) : super(
		OnboardingState(
      isLoading: false,
    )
	);

  void changePage(int page) async {
    ref.read(analyticsRepoProvider).trackOnboardingPage(page);
    await ref.read(profileProvider.notifier).updateLastOnboardingScreen(page);
  }

  void goToPreviousPage() async {
    final lastOnboardingScreen = ref.read(profileProvider).profile?.lastOnboardingScreen ?? 0;
    final previousPage = lastOnboardingScreen - 1;

    await ref.read(profileProvider.notifier).updateLastOnboardingScreen(previousPage > 0 ? previousPage : 0);
  }
}
