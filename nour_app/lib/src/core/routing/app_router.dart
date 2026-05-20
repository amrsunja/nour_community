import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_router.gr.dart';
import 'guards/auth_guard.dart';
import 'route_paths.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final Ref ref;

  AppRouter(this.ref);


	/// General we use this route builder to enable opaque value wich is setted like true by default 
	CustomRoute customRoute({
		required PageInfo page,
		String? path,
		Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionsBuilder = TransitionsBuilders.slideLeftWithFade,
		int durationInMilliseconds = 300,
		bool initial = false,
	}) => CustomRoute(
		page: page,
		path: path,
		initial: initial,
		transitionsBuilder: transitionsBuilder,
		duration: Duration(milliseconds: durationInMilliseconds)
	);

  late final authGuard = AuthGuard(ref);

	final generalSubPages = [
	];


  @override
  List<AutoRoute> get routes => [

    /// ROOT
    AutoRoute(
      path: '/',
      page: RootRoute.page,
      initial: true,
      children: [

        /// AUTH
        AutoRoute(
          path: RoutePaths.signIn,
          page: SignInRoute.page,
        ),
        AutoRoute(
          path: RoutePaths.signUp,
          page: SignUpRoute.page,
        ),

        AutoRoute(
          path: RoutePaths.onboarding,
          page: OnboardingRoute.page,
        ),

        /// Home (protected)
        AutoRoute(
          path: RoutePaths.home,
          page: HomeRouterRoute.page,
          guards: [authGuard],
          children: [
            AutoRoute(
              path: '',
              page: HomeRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.settings,
              page: SettingsRoute.page,
            ),
          ],
        ),
      ],
    ),

  ];
}
