// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/scaffold_messenger_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

import 'core/utils/enums/app_theme_type.dart';
import 'core/utils/extensions/build_context_extensions.dart';


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

			Future.microtask(() async {
			  await ref.read(settingsProvider.notifier).initLocalSettings();
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
					),
					// Change splash effect colors
					//splashColor: UIColorToken.pri100,
					//highlightColor: UIColorToken.pri100,
					//hoverColor: UIColorToken.pri100,
				),
				title: kAppName,
			  debugShowCheckedModeBanner: false,
				supportedLocales: L10n.all,
		  	locale: appSettings?.locale,
				localizationsDelegates: AppLocale.localizationsDelegates,
			  scaffoldMessengerKey: ref.read(scaffoldMessengerProvider),
				routerConfig: appRouter.router.config(
          //deepLinkTransformer: DeepLink.prefixStripper('/app'),
					//deepLinkBuilder: DeepLinksServices.navigateDeepLink
        ),
			),
		);
	}
}
