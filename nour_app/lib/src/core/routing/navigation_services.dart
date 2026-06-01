import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/routing/route_paths.dart';

import 'app_router.dart';

abstract class NavigationServices {
	void pop();

	void toSignIn();
	void toRoot();
	void toHome({bool openSignIn = false});
	void navigateToHome();
	void toSettings();
	void toProfile();
	void toOnboarding();

	void toDhikrsList();
	void toAdhkarsList();
	void toAdhkarDetail({required int subcategoryId});
	void toDhikr({required int selectedId});

	void toSurahDetail({required int surahNumber});
	void toAyahReader({required int surahNumber, int initialAyah});
	void toDailyAyah();

	void toHadithCollectionDetail({required int collectionId});
	void toHadithReader({required int collectionId, required int initialHadithId});

	void toDuaLibrary();
	void toDuaReader({required int initialDuaId});
	void toDailyDua();

	void toQuiz();

	void toPrayerTimes();
	void toHijriCalendar();
	void toQiblaFinder();
	void toZakatCalculator();

	void toStreakReward({required int streakDay});
	void toDailyDhikrReward({required int dhikrCompleted, required int ajrEarned});
}

class NavigationServicesImpl implements NavigationServices {
	final AppRouter router;

	NavigationServicesImpl({
		required this.router
	});

  @override
  void pop() => router.pop();

  @override
  void toSignIn() {
		router.replaceAll([SignInRoute()]);
  }

  @override
  void toRoot() {
		router.replaceAll([RootRoute()]);
  }

  @override
  void toOnboarding() {
		router.replaceAll([OnboardingRoute()]);
  }

  @override
  void navigateToHome() {
		router.navigate(HomeRouterRoute());
  }

  @override
  void toHome({bool openSignIn = false}) {
		router.replaceAll([HomeRouterRoute(), if (openSignIn) SignInRoute()]);
  }

  @override
  void toSettings() {
		router.pushPath(RoutePaths.settings);
  }

  @override
  void toProfile() {
		router.push(ProfileRoute());
  }

  @override
  void toDhikrsList() {
		router.push(DhikrsListRoute());
  }

  @override
  void toAdhkarsList() {
		router.push(AdhkarsListRoute());
  }

  @override
  void toAdhkarDetail({required int subcategoryId}) {
		router.push(AdhkarDetailRoute(subcategoryId: subcategoryId));
  }

  @override
  void toDhikr({required int selectedId}) {
		router.push(DhikrRoute(selectedId: selectedId));
  }

  @override
  void toSurahDetail({required int surahNumber}) {
		router.push(SurahDetailRoute(surahNumber: surahNumber));
  }

  @override
  void toAyahReader({required int surahNumber, int initialAyah = 1}) {
		router.push(AyahReaderRoute(surahNumber: surahNumber, initialAyah: initialAyah));
  }

  @override
  void toDailyAyah() {
		router.push(DailyAyahRoute());
  }

  @override
  void toHadithCollectionDetail({required int collectionId}) {
		router.push(HadithCollectionDetailRoute(collectionId: collectionId));
  }

  @override
  void toHadithReader({required int collectionId, required int initialHadithId}) {
		router.push(HadithDetailRoute(
			collectionId: collectionId,
			initialHadithId: initialHadithId,
		));
  }

  @override
  void toDuaLibrary() {
		router.push(DuaListRoute());
  }

  @override
  void toDuaReader({required int initialDuaId}) {
		router.push(DuaDetailRoute(initialDuaId: initialDuaId));
  }

  @override
  void toDailyDua() {
		router.push(DailyDuaRoute());
  }

  @override
  void toQuiz() {
		router.push(QuizRoute());
  }

  @override
  void toPrayerTimes() {
		router.push(PrayerTimesRoute());
  }

  @override
  void toHijriCalendar() {
		router.push(CalendarRoute());
  }

  @override
  void toQiblaFinder() {
		router.push(QiblaFinderRoute());
  }

  @override
  void toZakatCalculator() {
		router.push(ZakatCalculatorRoute());
  }

  @override
  void toStreakReward({required int streakDay}) {
		router.push(RewardStreakRoute(streakDay: streakDay));
  }

  @override
  void toDailyDhikrReward({required int dhikrCompleted, required int ajrEarned}) {
		router.push(RewardDailyDhikrRoute(
			dhikrCompleted: dhikrCompleted,
			ajrEarned: ajrEarned,
		));
  }
}
