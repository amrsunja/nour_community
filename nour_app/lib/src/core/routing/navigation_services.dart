import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/routing/route_paths.dart';

import 'app_router.dart';

abstract class NavigationServices {
	void pop();

	void toSignIn();
	void toHome({bool openSignIn = false});
	void toSettings();

	void toDhikrsList();
	void toAdhkarsList();
	void toDhikr({required int selectedId});
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
    throw UnimplementedError();
  }

  @override
  void toDhikr({required int selectedId}) {
		router.push(DhikrRoute(selectedId: selectedId));
  }
}
