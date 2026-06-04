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
              children: [
                AutoRoute(
                  path: RoutePaths.dashboard,
                  page: DashboardRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: DashboardRoute.page),
                    ...generalSubPages
                  ]
                ),
                AutoRoute(
                  path: RoutePaths.source,
                  page: SourceRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: SourceRoute.page),
                    ...generalSubPages
                  ]
                ),
                AutoRoute(
                  path: RoutePaths.impact,
                  page: ImpactRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: ImpactRoute.page),
                    ...generalSubPages
                  ]
                ),
                AutoRoute(
                  path: RoutePaths.tools,
                  page: ToolsRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: ToolsRoute.page),
                    ...generalSubPages
                  ]
                ),
              ]
            ),

            AutoRoute(
              path: RoutePaths.settings,
              page: SettingsRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.reminders,
              page: RemindersRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.favoriteReciter,
              page: FavoriteReciterRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.language,
              page: LanguageRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.profile,
              page: ProfileRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.profileStatistics,
              page: ProfileStatisticsRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.accountInformation,
              page: AccountInformationRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.webView,
              page: WebViewRoute.page,
            ),

            AutoRoute(
              path: RoutePaths.favorites,
              page: FavoritesRoute.page,
            ),

            /// Dhikr (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.dhikrsList,
              page: DhikrsListRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.dhikr,
              page: DhikrRoute.page,
            ),

            /// Adhkar (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.adhkarsList,
              page: AdhkarsListRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.adhkarDetail,
              page: AdhkarDetailRoute.page,
            ),

            /// Quran (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.surahDetail,
              page: SurahDetailRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.ayahReader,
              page: AyahReaderRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.dailyAyah,
              page: DailyAyahRoute.page,
            ),

            /// Hadith (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.hadithCollectionDetail,
              page: HadithCollectionDetailRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.hadithReader,
              page: HadithDetailRoute.page,
            ),

            /// Dua (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.duaLibrary,
              page: DuaListRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.duaReader,
              page: DuaDetailRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.dailyDua,
              page: DailyDuaRoute.page,
            ),

            /// Quiz (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.quiz,
              page: QuizRoute.page,
            ),

            /// Tools (full-screen over the bottom navbar)
            AutoRoute(
              path: RoutePaths.prayerTimes,
              page: PrayerTimesRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.hijriCalendar,
              page: CalendarRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.qiblaFinder,
              page: QiblaFinderRoute.page,
            ),
            AutoRoute(
              path: RoutePaths.zakatCalculator,
              page: ZakatCalculatorRoute.page,
            ),

            /// Rewards (full-screen over the bottom navbar, fade-in pop)
            customRoute(
              path: RoutePaths.rewardStreak,
              page: RewardStreakRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            customRoute(
              path: RoutePaths.rewardDailyDhikr,
              page: RewardDailyDhikrRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
          ],
        ),
      ],
    ),

  ];
}
