import 'package:nour/src/core/utils/constants/constants.dart';

import 'app_flavors.dart';

class AppConfig {
	String appName = '';
	String baseUrl = '';
	AppFlavors flavor = AppFlavors.stg;
	bool showDebugBanner;
	bool httpLogs;
	int httpRequestReries;
	String appVersion = '';
	String appBuildNumber = '';


	AppConfig(
		this.appName,
		this.baseUrl,
		this.flavor, {
		required this.showDebugBanner,
		required this.httpLogs,
		required this.appVersion,
		required this.appBuildNumber,
		required this.httpRequestReries,
	});

  factory AppConfig.create({
    String appName = '$kAppName dev',
    String baseUrl = '',
    String togglyAppKey = '',
    AppFlavors flavor = AppFlavors.stg,
    bool showDebugBanner = false,
    bool httpLogs = false,
    String appVersion = '',
    String appBuildNumber = '',
    int httpRequestReries = 0,
  }) => shared = AppConfig(
		appName,
		baseUrl,
		flavor,
		showDebugBanner: showDebugBanner,
		httpLogs: httpLogs,
		appVersion: appVersion,
		appBuildNumber: appBuildNumber,
		httpRequestReries: httpRequestReries,
	);

	static AppConfig shared = AppConfig.create();

	bool get isProd => flavor == AppFlavors.prod;
}
