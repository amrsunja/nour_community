/// Analytics feature barrel.
///
/// Public surface for the rest of the app:
///   • `analyticsRepoProvider`      → semantic tracking API (call from anywhere)
///   • `analyticsObserverBuilderProvider` → router observers for auto screen_view
///   • `AnalyticsScreens/Events/Params` → stable string catalogues
library;

export 'data/analytics_observer.dart';
export 'data/analytics_provider.dart';
export 'data/analytics_repo.dart';
export 'data/constants/analytics_events.dart';
export 'data/constants/analytics_params.dart';
export 'data/constants/analytics_screens.dart';
export 'data/datasources/analytics_remote_datasource.dart';
