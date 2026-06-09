import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'analytics_observer.dart';
import 'analytics_repo.dart';

/// Builder for the `screen_view` route observer.
///
/// auto_route propagates root `navigatorObservers` to every nested navigator
/// (and a single [NavigatorObserver] instance can only be attached to ONE
/// navigator — Flutter asserts `observer.navigator == null` otherwise). So we
/// expose a **builder** that mints a fresh observer per navigator rather than a
/// shared singleton. Matches auto_route's `NavigatorObserversBuilder` type, so
/// it can be passed straight to `router.config(navigatorObservers: ...)`.
final analyticsObserverBuilderProvider =
    Provider<List<NavigatorObserver> Function()>(
  (ref) => () => [AnalyticsRouteObserver(ref.read(analyticsRepoProvider))],
);
