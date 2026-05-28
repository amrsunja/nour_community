import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';
import 'package:nour/src/features/dhikr/ui/state_management/dhikr_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/reward_provider.dart';

@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhikrP= ref.read(dhikrProvider.notifier);

    // Reward coordinator: pushes the streak / daily-dhikr reward pages off the
    // realtime daily_activity stream (once per day, claimed server-side).
    ref.watch(rewardListenerProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await dhikrP.init();
          // Keep the streak live + start watching for reward triggers.
          ref.read(profileProvider.notifier).subscribeRealtime();
          ref.read(rewardProvider.notifier).init();
        }
      );
      return null;
    }, const []);

    return Scaffold(
			body: AutoTabsRouter(
				lazyLoad: true,
		    duration: const Duration(milliseconds: 300),
				routes: const [
					DashboardRouterRoute(),
					SourceRouterRoute(),
					ImpactRouterRoute(),
					ToolsRouterRoute(),
				],
				transitionBuilder: (context, child, animation) {
					final tabsRouter = context.tabsRouter;

					return Scaffold(
						extendBody: true,
						body: Stack(
            alignment: .bottomCenter,
						  children: [
						    SafeArea(
                  bottom: false,
						      child: FadeTransition(
						      	alwaysIncludeSemantics: true,
						      	opacity: animation,
						      	child: child,
						      ),
						    ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Theme(
                  							    // for removing splash effect on icon tap
                    data: ThemeData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: UINavBar(
                      currentPage: tabsRouter.activeIndex,
                      onPageChange: (index) {
                        AppVibrations.buttonClick();
                        if (index == tabsRouter.activeIndex) {
                          tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
                        }
                        tabsRouter.setActiveIndex(index);
                      },
                      onDhikrTap: () {
                        AppVibrations.buttonClick();
                        ref.read(navigationServicesProvider).toDhikrsList();
                      },
                    )
                  ),
                )
						  ],
						)
					).animate(effects: [FadeEffect(duration: Durations.long3)]);
				},
			)
		);

  }
}


