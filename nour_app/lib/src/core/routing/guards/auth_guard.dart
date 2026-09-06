import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../app_router.gr.dart';

/// Guards the worshipper area (`HomeRouterRoute`).
///
/// * no session            → Welcome (profile type selection)
/// * mosque account        → admin shell (approved) / review page (otherwise)
/// * worshipper, onboarding not completed → onboarding
class AuthGuard extends AutoRouteGuard {
  final Ref ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final state = ref.read(authProvider);

    if (!state.isAuthenticated) {
      router.replaceAll([const WelcomeRoute()]);
      return;
    }

    final profile = ref.read(profileProvider).profile;
    if (profile == null) {
      router.replaceAll([const WelcomeRoute()]);
      return;
    }

    if (profile.isMosqueAccount) {
      final my = ref.read(myMosqueProvider);
      router.replaceAll([
        my.isApproved ? const MosqueAdminShellRoute() : const MosqueReviewRoute(),
      ]);
      return;
    }

    if (!profile.onboardingCompleted) {
      router.replaceAll([OnboardingRoute()]);
      return;
    }
    resolver.next();
  }
}
