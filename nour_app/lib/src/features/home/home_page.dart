import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';

@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
						bottomNavigationBar: Theme(
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
								},
							)
						),
						body: SafeArea(
						  child: FadeTransition(
						  	alwaysIncludeSemantics: true,
						  	opacity: animation,
						  	child: child,
						  ),
						)
					).animate(effects: [FadeEffect(duration: Durations.long3)]);
				},
			)
		);

  }
}


