import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

import '../widgets/mosque_admin_navbar.dart';

/// Root of the mosque-manager experience: nested tabs router + admin navbar.
/// Guarded by [MosqueAdminGuard] (approved mosque accounts only).
@RoutePage()
class MosqueAdminShellPage extends ConsumerWidget {
  const MosqueAdminShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    // Keep the managed mosque fresh while the shell is alive.
    ref.watch(myMosqueProvider.select((s) => s.mosque?.id));

    return AutoTabsRouter(
      routes: const [
        MosqueAdminDashboardRoute(),
        MosqueAdminCommunityRoute(),
        MosqueAdminMosqueRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: child,
          bottomNavigationBar: MosqueAdminNavBar(
            currentIndex: tabsRouter.activeIndex,
            onChanged: tabsRouter.setActiveIndex,
            onPost: () => context.router.push(const MosqueAdminCreatePostRoute()),
            labels: [
              l10n.mosque_admin_tab_dashboard,
              l10n.mosque_admin_tab_community,
              l10n.mosque_admin_tab_mosque,
            ],
            postLabel: l10n.mosque_admin_tab_post,
          ),
        );
      },
    );
  }
}
