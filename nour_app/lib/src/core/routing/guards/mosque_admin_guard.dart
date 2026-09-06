import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../app_router.gr.dart';

/// Guards the mosque admin shell: only an authenticated mosque account whose
/// mosque is approved may enter. Everything else is bounced to the right
/// place (§3.1).
class MosqueAdminGuard extends AutoRouteGuard {
  final Ref ref;

  MosqueAdminGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      router.replaceAll([const WelcomeRoute()]);
      return;
    }
    final profile = ref.read(profileProvider).profile;
    if (profile == null || !profile.isMosqueAccount) {
      router.replaceAll([HomeRouterRoute()]);
      return;
    }
    if (!ref.read(myMosqueProvider).isApproved) {
      router.replaceAll([const MosqueReviewRoute()]);
      return;
    }
    resolver.next();
  }
}
