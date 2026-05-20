import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nour/config/app_runner.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/app_flavors.dart';
import 'src/core/utils/constants/constants.dart';
import 'src/core/utils/env_services.dart';
import 'src/core/utils/screen_rotation.dart';

void main() {
	runZonedGuarded<Future<void>>(
		() async {
			WidgetsFlutterBinding.ensureInitialized();

			// init env
			await dotenv.load();

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

			// App configuration
			AppConfig.create(
				appName: kAppName,
				baseUrl: EnvServices.prodBaseUrl,
				flavor: AppFlavors.prod,
				//httpLogs: true,
				httpRequestReries: 5,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
			);

      await Supabase.initialize(
        url: EnvServices.supabaseUrl,
        anonKey: EnvServices.supabaseKey
      );

      // Background audio (notification controls + lock-screen).
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.nour.community.audio',
        androidNotificationChannelName: 'Nour Audio Playback',
        androidNotificationOngoing: true,
        preloadArtwork: true,
      );

			// Init Firebase
  		//await Firebase.initializeApp();

  		//FlutterNativeSplash.remove();
      //FlutterError.onError = (errorDetails) {
        //FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      //};

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      //PlatformDispatcher.instance.onError = (error, stack) {
        //FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        //return true;
      //};

			// Lock screen rotation
			ScreenRotation.toPortrait();

  		AppRunner.runApplication();

		}, (error, stack) async {
      talker.error(error.toString(), error, stack);
		}
	);
}

