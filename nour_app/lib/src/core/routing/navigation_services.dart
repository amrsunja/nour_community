import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/routing/route_paths.dart';

import 'app_router.dart';

abstract class NavigationServices {
	void pop();

	void toSignIn();
	void toHome({bool openSignIn = false});
	void navigateToHome();
	void toSettings();

	void toDhikrsList();
	void toAdhkarsList();
	void toAdhkarDetail({required int subcategoryId});
	void toDhikr({required int selectedId});

	void toSurahDetail({required int surahNumber});
	void toAyahReader({required int surahNumber, int initialAyah});
	void toDailyAyah();
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
}
