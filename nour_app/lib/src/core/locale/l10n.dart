import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

import 'gen/app_localizations.dart';

typedef AppLocale = AppLocalizations;

final l10nProvider = Provider<AppLocale>((ref) {
	// 1. initialize from the initial locale
	final locale = L10n.defaultLocale ;
  late AppLocalizations state;

	//state = lookupAppLocalizations(locale);

	// 2. create an observer to update the state
	final localSettings = ref.watch(settingsProvider).data;

	state = lookupAppLocalizations(localSettings?.locale ?? locale);
	//ref.state = lookupAppLocalizations(locale);

	return state;
});


class L10n {
	static Locale get en => all[0];
	static Locale get fr => all[1];
	static Locale get ar => all[2];
	static Locale get de => all[3];
	static Locale get nl => all[4];
	static Locale get tr => all[5];
	static Locale get id => all[6];
	static Locale get ur => all[7];
	static Locale get bn => all[8];
	static Locale get ms => all[9];

  static final all = [
    const Locale('en', 'EN'),
    const Locale('fr', 'FR'),
    const Locale('ar', 'AR'),
    const Locale('de', 'DE'),
    const Locale('nl', 'NL'),
    const Locale('tr', 'TR'),
    const Locale('id', 'ID'),
    const Locale('ur', 'UR'),
    const Locale('bn', 'BN'),
    const Locale('ms', 'MS'),
  ];

	/// Default to English. Device locale only matched if it is one of the
	/// supported languages, otherwise English is used as the fallback.
	static Locale get defaultLocale {
		final appNativeLocale = ui.PlatformDispatcher.instance.locale;
		return all.firstWhereOrNull((value) => appNativeLocale.languageCode == value.languageCode) ?? en;
	}
}
