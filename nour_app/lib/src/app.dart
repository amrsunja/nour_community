// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/scaffold_messenger_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/features/analytics/data/analytics_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

import 'core/utils/enums/app_theme_type.dart';
import 'core/utils/extensions/build_context_extensions.dart';
import 'features/notifications/ui/state_management/notifications_provider.dart';


/// White status bar icons (Android: light icon brightness; iOS: dark status bar
/// brightness). Transparent bar so the page gradient shows through.
const _overlayStyle = SystemUiOverlayStyle(
	statusBarColor: Colors.transparent,
	statusBarIconBrightness: Brightness.light, // Android
	statusBarBrightness: Brightness.light, // iOS
  systemNavigationBarIconBrightness: .light
);

class App extends StatefulHookConsumerWidget {
	const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
	@override
	Widget build(BuildContext context) {
    // Listen to app events
    ref.watch(appEventsListenerProvider);

		final appSettings = ref.watch(settingsProvider).data;
		final appRouter = ref.read(navigationServicesProvider);

		useEffect(() {
		  WidgetsBinding.instance.addObserver(this);

			// White status bar icons globally (dark-only app).
			SystemChrome.setSystemUIOverlayStyle(_overlayStyle);

			Future.microtask(() async {
			  await ref.read(settingsProvider.notifier).initLocalSettings();
			  // Reschedule against today's prayer times so the rolling 7-day
			  // window stays accurate on every cold start (also loads settings).
			  await ref.read(notificationsProvider.notifier).rescheduleAll();
			});

			return null;
		}, []);


    final theme = useMemoized(() {
      final systemTheme = context.isDarkMode ? UIThemeData.dark() : UIThemeData.dark();

      if (appSettings == null) return systemTheme;


      switch (appSettings.themeMode) {
        case AppThemeType.system:
          return systemTheme;
        case AppThemeType.dark:
          return UIThemeData.dark();
        case AppThemeType.light:
          return UIThemeData.dark();
      }
    }, [appSettings?.themeMode]);

		return UITheme(
			data: theme,
			child: MaterialApp.router(
				theme: ThemeData(
					scaffoldBackgroundColor: theme.colors.bgColor,
					appBarTheme: AppBarTheme(
						shadowColor: Colors.transparent,
						//surfaceTintColor: UIColorsToken.,
						elevation: 0,
						titleSpacing: 0,
						scrolledUnderElevation: 0.0,
						// Keep white status bar icons even when an AppBar is present.
						systemOverlayStyle: _overlayStyle,
					),
					// Change splash effect colors
					splashColor: Colors.transparent,
					highlightColor: Colors.transparent,
					hoverColor: Colors.transparent,
				),
				title: kAppName,
			  debugShowCheckedModeBanner: false,
				supportedLocales: L10n.all,
		  	locale: appSettings?.locale,
				localizationsDelegates: AppLocale.localizationsDelegates,
			  scaffoldMessengerKey: ref.read(scaffoldMessengerProvider),
				routerConfig: appRouter.router.config(
          // Auto screen_view tracking for every route push/replace + tab change.
          // Builder (not a singleton): auto_route reuses observers across nested
          // navigators, and one observer instance can't be attached to two.
          navigatorObservers: ref.read(analyticsObserverBuilderProvider),
          //deepLinkTransformer: DeepLink.prefixStripper('/app'),
					//deepLinkBuilder: DeepLinksServices.navigateDeepLink
        ),
			),
		);
	}
}
