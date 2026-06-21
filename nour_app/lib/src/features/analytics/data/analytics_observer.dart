import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'analytics_repo.dart';
import 'constants/analytics_screens.dart';

/// Auto-tracks `screen_view` for every route push/replace **and** bottom-nav
/// tab change. Route names are mapped to stable snake_case labels via
/// [AnalyticsScreens.byRouteName]; unmapped routes fall back to a snake_cased
/// version of the route name so nothing is ever silently dropped.
class AnalyticsRouteObserver extends AutoRouteObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsRepo _analytics;

  String? _last;

  void _track(String? routeName) {
    if (routeName == null) return;
    final screen = AnalyticsScreens.byRouteName[routeName] ?? _toSnake(routeName);
    if (screen == _last) return; // de-dupe rebuild churn
    _last = screen;
    _analytics.trackScreen(screen);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track(newRoute?.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Returning to the underlying screen is a fresh view.
    _track(previousRoute?.settings.name);
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    _track(route.name);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    _track(route.name);
  }

  String _toSnake(String name) {
    final stripped = name.replaceAll(RegExp(r'Route$'), '');
    final snake = stripped
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
    return snake.isEmpty ? 'unknown' : snake;
  }
}
