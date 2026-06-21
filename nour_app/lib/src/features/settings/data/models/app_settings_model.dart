import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:nour/src/core/utils/enums/app_theme_type.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AppSettingsModel extends Equatable {
	final Locale? locale;
	final AppThemeType themeMode;
	final ReciterType favoriteReciter;

	const AppSettingsModel({
		required this.locale,
		required this.themeMode,
		required this.favoriteReciter,
	});

	AppSettingsModel copyWith({
		Locale? locale,
		AppThemeType? themeMode,
		ReciterType? favoriteReciter,
	}) {
		return AppSettingsModel(
			locale: locale ?? this.locale,
			themeMode: themeMode ?? this.themeMode,
			favoriteReciter: favoriteReciter ?? this.favoriteReciter,
		);
	}

	factory AppSettingsModel.fromJson(Json json) {
		final langRaw = json[SQLiteConfig.languageCodeKey];
		final countryRaw = json[SQLiteConfig.countryCodeKey];
		final Locale? locale = langRaw == null
				? null
				: Locale(
						'$langRaw',
						countryRaw == null ? null : '$countryRaw',
					);
		return AppSettingsModel(
			locale: locale,
			themeMode: AppThemeType.fromJson(json[SQLiteConfig.themeModeKey]),
			favoriteReciter: ReciterType.fromString(
				json[SQLiteConfig.favoriteReciterKey] as String?,
			),
		);
	}

	Json toJson() => {
		SQLiteConfig.languageCodeKey: locale?.languageCode,
		SQLiteConfig.countryCodeKey: locale?.countryCode,
		SQLiteConfig.themeModeKey: themeMode.name,
		SQLiteConfig.favoriteReciterKey: favoriteReciter.dbValue,
	};

	static AppSettingsModel get getInitSettings => const AppSettingsModel(
		locale: null,
		themeMode: AppThemeType.system,
		favoriteReciter: ReciterType.defaultReciter,
	);

  @override
  List<Object?> get props => [locale, themeMode, favoriteReciter];
}
