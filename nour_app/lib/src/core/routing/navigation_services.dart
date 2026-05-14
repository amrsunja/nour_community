import 'package:nour/src/core/routing/route_paths.dart';

import 'app_router.dart';

abstract class NavigationServices {
	void pop();

	void toSettings();
}

class NavigationServicesImpl implements NavigationServices {
	final AppRouter router;

	NavigationServicesImpl({
		required this.router
	});

  @override
  void pop() => router.pop();

  @override
  void toSettings() {
		router.pushPath(RoutePaths.settings);
  }
}
