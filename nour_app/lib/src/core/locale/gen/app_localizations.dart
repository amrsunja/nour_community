import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('id'),
    Locale('ms'),
    Locale('nl'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get appLanguage;

  /// No description provided for @l10nTexts.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TEXTS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nTexts;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_maybe_later.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get common_maybe_later;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_assalamu_alaykum.
  ///
  /// In en, this message translates to:
  /// **'As-salamu Alaykum'**
  String get common_assalamu_alaykum;

  /// No description provided for @common_monday_tag.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get common_monday_tag;

  /// No description provided for @common_tuesday_tag.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get common_tuesday_tag;

  /// No description provided for @common_wednesday_tag.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get common_wednesday_tag;

  /// No description provided for @common_thursday_tag.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get common_thursday_tag;

  /// No description provided for @common_friday_tag.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get common_friday_tag;

  /// No description provided for @common_saturday_tag.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get common_saturday_tag;

  /// No description provided for @common_sunday_tag.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get common_sunday_tag;

  /// No description provided for @l10nNavBar.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ NAV BAR ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nNavBar;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get nav_source;

  /// No description provided for @nav_impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get nav_impact;

  /// No description provided for @nav_tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get nav_tools;

  /// No description provided for @nav_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get nav_dhikr;

  /// No description provided for @l10nSettings.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nSettings;

  /// No description provided for @settings_app.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_app;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_info.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the application interface.'**
  String get settings_language_info;

  /// No description provided for @settings_favorite_reciter.
  ///
  /// In en, this message translates to:
  /// **'Favourite reciter'**
  String get settings_favorite_reciter;

  /// No description provided for @settings_favorite_reciter_info.
  ///
  /// In en, this message translates to:
  /// **'Choose the reciter used for Quran audio playback.'**
  String get settings_favorite_reciter_info;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_info.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred theme for the application interface.'**
  String get settings_theme_info;

  /// No description provided for @settings_term_of_use.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settings_term_of_use;

  /// No description provided for @settings_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy_policy;

  /// No description provided for @settings_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settings_support;

  /// No description provided for @settings_delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settings_delete_all_data;

  /// No description provided for @settings_delete_all_data_warning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible and will delete all your tracking data from this device.'**
  String get settings_delete_all_data_warning;

  /// No description provided for @l10nAbout.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nAbout;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_project.
  ///
  /// In en, this message translates to:
  /// **'About the Project'**
  String get about_project;

  /// No description provided for @l10nWarning.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WARNING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nWarning;

  /// No description provided for @warning_are_you_sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get warning_are_you_sure;

  /// No description provided for @l10nOnboarding.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠'**
  String get l10nOnboarding;

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboarding;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_start.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_start;

  /// No description provided for @onboarding_lets_get_started.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get onboarding_lets_get_started;

  /// No description provided for @onboarding_allow_notifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboarding_allow_notifications;

  /// No description provided for @onboarding_maybe_later.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get onboarding_maybe_later;

  /// No description provided for @onboarding_screen_1_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nour'**
  String get onboarding_screen_1_title;

  /// No description provided for @onboarding_screen_1_description.
  ///
  /// In en, this message translates to:
  /// **'Your premium companion for a beautiful spiritual journey'**
  String get onboarding_screen_1_description;

  /// No description provided for @onboarding_screen_2_title.
  ///
  /// In en, this message translates to:
  /// **'Everything you need'**
  String get onboarding_screen_2_title;

  /// No description provided for @onboarding_screen_2_description.
  ///
  /// In en, this message translates to:
  /// **'Daily practice, sacred texts, and tools — all in one place.'**
  String get onboarding_screen_2_description;

  /// No description provided for @onboarding_screen_2_card_streak_reward.
  ///
  /// In en, this message translates to:
  /// **'Streak reward'**
  String get onboarding_screen_2_card_streak_reward;

  /// No description provided for @onboarding_screen_2_card_ajr_counter.
  ///
  /// In en, this message translates to:
  /// **'Ajr counter'**
  String get onboarding_screen_2_card_ajr_counter;

  /// No description provided for @onboarding_screen_2_card_daily_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Daily Dhikr'**
  String get onboarding_screen_2_card_daily_dhikr;

  /// No description provided for @onboarding_screen_3_title.
  ///
  /// In en, this message translates to:
  /// **'Build a beautiful daily routine'**
  String get onboarding_screen_3_title;

  /// No description provided for @onboarding_screen_3_description.
  ///
  /// In en, this message translates to:
  /// **'Earn ajr through dhikr, find peace in the Qur\'an, and grow in your faith.'**
  String get onboarding_screen_3_description;

  /// No description provided for @onboarding_screen_3_dhikr_translation.
  ///
  /// In en, this message translates to:
  /// **'Glory be to Allah'**
  String get onboarding_screen_3_dhikr_translation;

  /// No description provided for @onboarding_screen_4_title.
  ///
  /// In en, this message translates to:
  /// **'Where are you on your journey?'**
  String get onboarding_screen_4_title;

  /// No description provided for @onboarding_screen_4_description.
  ///
  /// In en, this message translates to:
  /// **'*'**
  String get onboarding_screen_4_description;

  /// No description provided for @onboarding_screen_5_title.
  ///
  /// In en, this message translates to:
  /// **'How much time daily?'**
  String get onboarding_screen_5_title;

  /// No description provided for @onboarding_screen_5_description.
  ///
  /// In en, this message translates to:
  /// **'Choose a goal that fits your life.'**
  String get onboarding_screen_5_description;

  /// No description provided for @onboarding_screen_5_minutes_per_day.
  ///
  /// In en, this message translates to:
  /// **'minutes per day'**
  String get onboarding_screen_5_minutes_per_day;

  /// No description provided for @onboarding_screen_6_title.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders'**
  String get onboarding_screen_6_title;

  /// No description provided for @onboarding_screen_6_description.
  ///
  /// In en, this message translates to:
  /// **'We\'ll only send what you allow.'**
  String get onboarding_screen_6_description;

  /// No description provided for @onboarding_screen_7_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a voice'**
  String get onboarding_screen_7_title;

  /// No description provided for @onboarding_screen_7_description.
  ///
  /// In en, this message translates to:
  /// **'Choose your favourite reciter'**
  String get onboarding_screen_7_description;

  /// No description provided for @onboarding_screen_7_reciter_artist.
  ///
  /// In en, this message translates to:
  /// **'Quran — Al-Fatiha 1:1'**
  String get onboarding_screen_7_reciter_artist;

  /// No description provided for @onboarding_screen_8_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboarding_screen_8_title;

  /// No description provided for @onboarding_screen_8_description.
  ///
  /// In en, this message translates to:
  /// **'*'**
  String get onboarding_screen_8_description;

  /// No description provided for @onboarding_screen_8_lang_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onboarding_screen_8_lang_en;

  /// No description provided for @onboarding_screen_8_lang_ar.
  ///
  /// In en, this message translates to:
  /// **'العربيه'**
  String get onboarding_screen_8_lang_ar;

  /// No description provided for @onboarding_screen_8_lang_fr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get onboarding_screen_8_lang_fr;

  /// No description provided for @onboarding_screen_8_lang_de.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get onboarding_screen_8_lang_de;

  /// No description provided for @onboarding_screen_8_lang_nl.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get onboarding_screen_8_lang_nl;

  /// No description provided for @onboarding_screen_8_lang_tr.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get onboarding_screen_8_lang_tr;

  /// No description provided for @onboarding_screen_8_lang_id.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get onboarding_screen_8_lang_id;

  /// No description provided for @onboarding_screen_8_lang_ur.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get onboarding_screen_8_lang_ur;

  /// No description provided for @onboarding_screen_8_lang_bn.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get onboarding_screen_8_lang_bn;

  /// No description provided for @onboarding_screen_8_lang_ms.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Melayu'**
  String get onboarding_screen_8_lang_ms;

  /// No description provided for @onboarding_screen_8_lang_ru.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get onboarding_screen_8_lang_ru;

  /// No description provided for @onboarding_screen_9_title.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get onboarding_screen_9_title;

  /// No description provided for @onboarding_screen_9_description.
  ///
  /// In en, this message translates to:
  /// **'To save your daily progress'**
  String get onboarding_screen_9_description;

  /// No description provided for @onboarding_screen_9_name_label.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboarding_screen_9_name_label;

  /// No description provided for @onboarding_screen_9_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get onboarding_screen_9_name_hint;

  /// No description provided for @onboarding_screen_9_gender_question.
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender?'**
  String get onboarding_screen_9_gender_question;

  /// No description provided for @onboarding_screen_9_gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboarding_screen_9_gender_male;

  /// No description provided for @onboarding_screen_9_gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboarding_screen_9_gender_female;

  /// No description provided for @onboarding_screen_9_gender_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_screen_9_gender_skip;

  /// No description provided for @level_begining_title.
  ///
  /// In en, this message translates to:
  /// **'Begining'**
  String get level_begining_title;

  /// No description provided for @level_begining_description.
  ///
  /// In en, this message translates to:
  /// **'Just starting or learning'**
  String get level_begining_description;

  /// No description provided for @level_growing_title.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get level_growing_title;

  /// No description provided for @level_growing_description.
  ///
  /// In en, this message translates to:
  /// **'Practicing and learning more'**
  String get level_growing_description;

  /// No description provided for @level_established_title.
  ///
  /// In en, this message translates to:
  /// **'Established'**
  String get level_established_title;

  /// No description provided for @level_established_description.
  ///
  /// In en, this message translates to:
  /// **'Committed daily practice'**
  String get level_established_description;

  /// No description provided for @level_returning_title.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get level_returning_title;

  /// No description provided for @level_returning_description.
  ///
  /// In en, this message translates to:
  /// **'Coming back to my faith'**
  String get level_returning_description;

  /// No description provided for @l10nNotifications.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ NOTIFICATIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nNotifications;

  /// No description provided for @notifications_prayer_times_label.
  ///
  /// In en, this message translates to:
  /// **'Prayer times (5 prayers)'**
  String get notifications_prayer_times_label;

  /// No description provided for @notifications_morning_adhkar_label.
  ///
  /// In en, this message translates to:
  /// **'Morning adkar reminder'**
  String get notifications_morning_adhkar_label;

  /// No description provided for @notifications_evening_adhkar_label.
  ///
  /// In en, this message translates to:
  /// **'Evening adkar reminder'**
  String get notifications_evening_adhkar_label;

  /// No description provided for @notifications_daily_ayah_label.
  ///
  /// In en, this message translates to:
  /// **'Daily ayah notification'**
  String get notifications_daily_ayah_label;

  /// No description provided for @notifications_prayer_fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get notifications_prayer_fajr;

  /// No description provided for @notifications_prayer_dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get notifications_prayer_dhuhr;

  /// No description provided for @notifications_prayer_asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get notifications_prayer_asr;

  /// No description provided for @notifications_prayer_maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get notifications_prayer_maghrib;

  /// No description provided for @notifications_prayer_isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get notifications_prayer_isha;

  /// No description provided for @notifications_prayer_body.
  ///
  /// In en, this message translates to:
  /// **'It is time for {prayer} prayer.'**
  String notifications_prayer_body(String prayer);

  /// No description provided for @notifications_morning_adhkar_title.
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar'**
  String get notifications_morning_adhkar_title;

  /// No description provided for @notifications_morning_adhkar_body.
  ///
  /// In en, this message translates to:
  /// **'Time for your morning adhkar.'**
  String get notifications_morning_adhkar_body;

  /// No description provided for @notifications_evening_adhkar_title.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar'**
  String get notifications_evening_adhkar_title;

  /// No description provided for @notifications_evening_adhkar_body.
  ///
  /// In en, this message translates to:
  /// **'Time for your evening adhkar.'**
  String get notifications_evening_adhkar_body;

  /// No description provided for @notifications_daily_ayah_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Ayah'**
  String get notifications_daily_ayah_title;

  /// No description provided for @notifications_daily_ayah_body.
  ///
  /// In en, this message translates to:
  /// **'A new ayah is waiting for you.'**
  String get notifications_daily_ayah_body;

  /// No description provided for @notifications_error_prayers_schedule.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule prayer notifications.'**
  String get notifications_error_prayers_schedule;

  /// No description provided for @notifications_error_adhkar_schedule.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule adhkar notifications.'**
  String get notifications_error_adhkar_schedule;

  /// No description provided for @l10nSuccess.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUCCESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nSuccess;

  /// No description provided for @success_all_data_deleted.
  ///
  /// In en, this message translates to:
  /// **'All your progress data has been successfully deleted from this device!'**
  String get success_all_data_deleted;

  /// No description provided for @l10nErrors.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nErrors;

  /// No description provided for @error_db_failure.
  ///
  /// In en, this message translates to:
  /// **'DB Error'**
  String get error_db_failure;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_unknown;

  /// No description provided for @error_server_failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please check your internet connection'**
  String get error_server_failure;

  /// No description provided for @l10nAuth.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ AUTH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nAuth;

  /// No description provided for @auth_connect_title.
  ///
  /// In en, this message translates to:
  /// **'Let’s connect your account'**
  String get auth_connect_title;

  /// No description provided for @auth_connect_subtitle.
  ///
  /// In en, this message translates to:
  /// **'So you don\'t lose your data and daily progress'**
  String get auth_connect_subtitle;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get auth_email_hint;

  /// No description provided for @auth_otp.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get auth_otp;

  /// No description provided for @auth_otp_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get auth_otp_hint;

  /// No description provided for @auth_send_code.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get auth_send_code;

  /// No description provided for @auth_resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get auth_resend_code;

  /// No description provided for @auth_otp_sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email'**
  String get auth_otp_sent;

  /// No description provided for @auth_otp_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get auth_otp_required;

  /// No description provided for @auth_otp_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get auth_otp_invalid;

  /// No description provided for @auth_or_sign_up_with.
  ///
  /// In en, this message translates to:
  /// **'or with'**
  String get auth_or_sign_up_with;

  /// No description provided for @auth_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get auth_connect;

  /// No description provided for @auth_email_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get auth_email_required;

  /// No description provided for @auth_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get auth_email_invalid;

  /// No description provided for @auth_link_success.
  ///
  /// In en, this message translates to:
  /// **'Your account is connected'**
  String get auth_link_success;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profile_guest;

  /// No description provided for @profile_connect_account.
  ///
  /// In en, this message translates to:
  /// **'Connect my account'**
  String get profile_connect_account;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_journey.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get profile_journey;

  /// No description provided for @profile_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profile_preferences;

  /// No description provided for @profile_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile_account;

  /// No description provided for @profile_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profile_statistics;

  /// No description provided for @statistics_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statistics_filter_all;

  /// No description provided for @statistics_filter_week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statistics_filter_week;

  /// No description provided for @statistics_filter_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statistics_filter_today;

  /// No description provided for @statistics_earned_ajr.
  ///
  /// In en, this message translates to:
  /// **'Earned Ajr'**
  String get statistics_earned_ajr;

  /// No description provided for @statistics_dhikr_completed.
  ///
  /// In en, this message translates to:
  /// **'Dikr completed'**
  String get statistics_dhikr_completed;

  /// No description provided for @statistics_completed_deeds.
  ///
  /// In en, this message translates to:
  /// **'Completed deeds'**
  String get statistics_completed_deeds;

  /// No description provided for @statistics_ayahs_read.
  ///
  /// In en, this message translates to:
  /// **'Ayahs read'**
  String get statistics_ayahs_read;

  /// No description provided for @statistics_hadiths_read.
  ///
  /// In en, this message translates to:
  /// **'Hadiths read'**
  String get statistics_hadiths_read;

  /// No description provided for @statistics_duas_recited.
  ///
  /// In en, this message translates to:
  /// **'Duas recited'**
  String get statistics_duas_recited;

  /// No description provided for @statistics_active_days.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get statistics_active_days;

  /// No description provided for @profile_favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get profile_favourites;

  /// No description provided for @favorites_tab_ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get favorites_tab_ayahs;

  /// No description provided for @favorites_tab_adhkars.
  ///
  /// In en, this message translates to:
  /// **'Adhkars'**
  String get favorites_tab_adhkars;

  /// No description provided for @favorites_tab_duas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get favorites_tab_duas;

  /// No description provided for @favorites_tab_hadiths.
  ///
  /// In en, this message translates to:
  /// **'Hadiths'**
  String get favorites_tab_hadiths;

  /// No description provided for @favorites_empty.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet.'**
  String get favorites_empty;

  /// No description provided for @favorites_error_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get favorites_error_title;

  /// No description provided for @favorites_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your favourites. Please try again.'**
  String get favorites_error_subtitle;

  /// No description provided for @favorites_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get favorites_try_again;

  /// No description provided for @favorites_tab_impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get favorites_tab_impact;

  /// No description provided for @impact_title.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact_title;

  /// No description provided for @impact_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get impact_filter_all;

  /// No description provided for @impact_empty.
  ///
  /// In en, this message translates to:
  /// **'There aren’t any projects available yet, but we’ll be adding them soon. Thank you!'**
  String get impact_empty;

  /// No description provided for @impact_about_project.
  ///
  /// In en, this message translates to:
  /// **'About the project'**
  String get impact_about_project;

  /// No description provided for @impact_read_more.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get impact_read_more;

  /// No description provided for @impact_read_less.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get impact_read_less;

  /// No description provided for @impact_partner_org.
  ///
  /// In en, this message translates to:
  /// **'Partner organization'**
  String get impact_partner_org;

  /// No description provided for @impact_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get impact_verified;

  /// No description provided for @impact_stories_title.
  ///
  /// In en, this message translates to:
  /// **'Stories from the field'**
  String get impact_stories_title;

  /// No description provided for @impact_donors.
  ///
  /// In en, this message translates to:
  /// **'{count} people have donated'**
  String impact_donors(String count);

  /// No description provided for @impact_time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get impact_time_just_now;

  /// No description provided for @impact_time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{hours} hour(s) ago'**
  String impact_time_hours_ago(int hours);

  /// No description provided for @impact_time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) ago'**
  String impact_time_days_ago(int days);

  /// No description provided for @impact_time_weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'{weeks} week(s) ago'**
  String impact_time_weeks_ago(int weeks);

  /// No description provided for @impact_time_months_ago.
  ///
  /// In en, this message translates to:
  /// **'{months} month(s) ago'**
  String impact_time_months_ago(int months);

  /// No description provided for @profile_reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get profile_reminders;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_reading_preferences.
  ///
  /// In en, this message translates to:
  /// **'Reading preferences'**
  String get profile_reading_preferences;

  /// No description provided for @profile_account_information.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get profile_account_information;

  /// No description provided for @account_information_title.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get account_information_title;

  /// No description provided for @account_information_name_label.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get account_information_name_label;

  /// No description provided for @account_information_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get account_information_name_hint;

  /// No description provided for @account_information_gender_question.
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender?'**
  String get account_information_gender_question;

  /// No description provided for @account_information_gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get account_information_gender_male;

  /// No description provided for @account_information_gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get account_information_gender_female;

  /// No description provided for @account_information_gender_skip.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get account_information_gender_skip;

  /// No description provided for @account_information_daily_practice_title.
  ///
  /// In en, this message translates to:
  /// **'Daily practice time'**
  String get account_information_daily_practice_title;

  /// No description provided for @account_information_minutes_per_day.
  ///
  /// In en, this message translates to:
  /// **'minutes per day'**
  String get account_information_minutes_per_day;

  /// No description provided for @account_information_level_title.
  ///
  /// In en, this message translates to:
  /// **'Where are you on your journey?'**
  String get account_information_level_title;

  /// No description provided for @profile_help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profile_help_support;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About Nour'**
  String get profile_about;

  /// No description provided for @profile_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profile_privacy_policy;

  /// No description provided for @profile_terms_of_use.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get profile_terms_of_use;

  /// No description provided for @profile_avatar_title.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profile_avatar_title;

  /// No description provided for @profile_avatar_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profile_avatar_take_photo;

  /// No description provided for @profile_avatar_choose_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profile_avatar_choose_gallery;

  /// No description provided for @profile_avatar_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profile_avatar_remove;

  /// No description provided for @profile_avatar_remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove profile photo?'**
  String get profile_avatar_remove_title;

  /// No description provided for @profile_avatar_remove_message.
  ///
  /// In en, this message translates to:
  /// **'Your current photo will be permanently deleted.'**
  String get profile_avatar_remove_message;

  /// No description provided for @profile_avatar_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profile_avatar_cancel;

  /// No description provided for @profile_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profile_delete_account;

  /// No description provided for @profile_delete_account_title.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profile_delete_account_title;

  /// No description provided for @profile_delete_account_message.
  ///
  /// In en, this message translates to:
  /// **'All your data will be permanently deleted and cannot be recovered. Are you sure you want to continue?'**
  String get profile_delete_account_message;

  /// No description provided for @profile_delete_account_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profile_delete_account_confirm;

  /// No description provided for @profile_delete_account_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profile_delete_account_cancel;

  /// No description provided for @l10nDashboard.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nDashboard;

  /// No description provided for @dashboard_daily_dhikr_goal.
  ///
  /// In en, this message translates to:
  /// **'Daily Dhikr Goal'**
  String get dashboard_daily_dhikr_goal;

  /// No description provided for @dashboard_dhikr_goal_progress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{goal}  dhikr per day'**
  String dashboard_dhikr_goal_progress(int current, int goal);

  /// No description provided for @dashboard_start_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Start dhikr'**
  String get dashboard_start_dhikr;

  /// No description provided for @dashboard_quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboard_quick_actions;

  /// No description provided for @dashboard_next_prayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get dashboard_next_prayer;

  /// No description provided for @dashboard_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboard_view_all;

  /// No description provided for @dashboard_quick_tools.
  ///
  /// In en, this message translates to:
  /// **'Quick tools'**
  String get dashboard_quick_tools;

  /// No description provided for @dashboard_see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashboard_see_all;

  /// No description provided for @dashboard_impact_projects.
  ///
  /// In en, this message translates to:
  /// **'Nour impact'**
  String get dashboard_impact_projects;

  /// No description provided for @dashboard_see_all_projects.
  ///
  /// In en, this message translates to:
  /// **'See all projects'**
  String get dashboard_see_all_projects;

  /// No description provided for @l10nRewards.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REWARDS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nRewards;

  /// No description provided for @reward_streak_day_title.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String reward_streak_day_title(int day);

  /// No description provided for @reward_streak_congrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your streak is now at {count} day(s)'**
  String reward_streak_congrats(int count);

  /// No description provided for @reward_dhikr_title.
  ///
  /// In en, this message translates to:
  /// **'MashaAllah'**
  String get reward_dhikr_title;

  /// No description provided for @reward_dhikr_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You completed your dhikr, and earned your daily ajr'**
  String get reward_dhikr_subtitle;

  /// No description provided for @reward_ajr_earned.
  ///
  /// In en, this message translates to:
  /// **'Ajr earned'**
  String get reward_ajr_earned;

  /// No description provided for @reward_dhikr_completed.
  ///
  /// In en, this message translates to:
  /// **'Dikr completed'**
  String get reward_dhikr_completed;

  /// No description provided for @reward_alhamdulilah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulilah'**
  String get reward_alhamdulilah;

  /// No description provided for @reward_go_further.
  ///
  /// In en, this message translates to:
  /// **'Go further in my practice'**
  String get reward_go_further;

  /// No description provided for @quiz_question_progress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quiz_question_progress(int current, int total);

  /// No description provided for @quiz_validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get quiz_validate;

  /// No description provided for @quiz_correct_title.
  ///
  /// In en, this message translates to:
  /// **'MashaAllah!'**
  String get quiz_correct_title;

  /// No description provided for @quiz_wrong_title.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get quiz_wrong_title;

  /// No description provided for @quiz_good_answer.
  ///
  /// In en, this message translates to:
  /// **'Good answer: {answer}'**
  String quiz_good_answer(String answer);

  /// No description provided for @quiz_reward_title.
  ///
  /// In en, this message translates to:
  /// **'MashaAllah'**
  String get quiz_reward_title;

  /// No description provided for @quiz_reward_perfect_title.
  ///
  /// In en, this message translates to:
  /// **'BarakaAllahufik'**
  String get quiz_reward_perfect_title;

  /// No description provided for @quiz_reward_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You answered {correct} of {total} correctly'**
  String quiz_reward_subtitle(int correct, int total);

  /// No description provided for @quiz_reward_perfect_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You did a perfect quiz and answered all {total} correctly'**
  String quiz_reward_perfect_subtitle(int total);

  /// No description provided for @quiz_reward_bonus.
  ///
  /// In en, this message translates to:
  /// **'+{ajr} Ajr bonus'**
  String quiz_reward_bonus(int ajr);

  /// No description provided for @quiz_reward_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get quiz_reward_score;

  /// No description provided for @quiz_already_played_title.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow'**
  String get quiz_already_played_title;

  /// No description provided for @quiz_already_played_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already completed today\'s quiz. A new one awaits tomorrow, inshaAllah.'**
  String get quiz_already_played_subtitle;

  /// No description provided for @quiz_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No quiz available'**
  String get quiz_empty_title;

  /// No description provided for @quiz_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no questions for you right now. Please check back later.'**
  String get quiz_empty_subtitle;

  /// No description provided for @l10nDhikr.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DHIKR ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nDhikr;

  /// No description provided for @dhikr_choose_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Dhikr'**
  String get dhikr_choose_title;

  /// No description provided for @dhikr_continue_section.
  ///
  /// In en, this message translates to:
  /// **'Continue dhikr'**
  String get dhikr_continue_section;

  /// No description provided for @dhikr_essential_section.
  ///
  /// In en, this message translates to:
  /// **'Essential dhikr'**
  String get dhikr_essential_section;

  /// No description provided for @dhikr_tap_to_count.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get dhikr_tap_to_count;

  /// No description provided for @dhikr_done.
  ///
  /// In en, this message translates to:
  /// **'I\'m done'**
  String get dhikr_done;

  /// No description provided for @dhikr_session.
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get dhikr_session;

  /// No description provided for @dhikr_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dhikr_today;

  /// No description provided for @dhikr_ajr_earned.
  ///
  /// In en, this message translates to:
  /// **'Ajr earned'**
  String get dhikr_ajr_earned;

  /// No description provided for @dhikr_choose_another.
  ///
  /// In en, this message translates to:
  /// **'Choose another dhikr'**
  String get dhikr_choose_another;

  /// No description provided for @dhikr_quote.
  ///
  /// In en, this message translates to:
  /// **'And remember Allah abundantly'**
  String get dhikr_quote;

  /// No description provided for @dhikr_quote_source.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Anfal 8:45'**
  String get dhikr_quote_source;

  /// No description provided for @dhikr_browse_all_adhkar.
  ///
  /// In en, this message translates to:
  /// **'Browse all adhkar'**
  String get dhikr_browse_all_adhkar;

  /// No description provided for @dhikr_browse_all_adhkar_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning, evening, situational du’as'**
  String get dhikr_browse_all_adhkar_subtitle;

  /// No description provided for @l10nAdhkar.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ADHKAR ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nAdhkar;

  /// No description provided for @adhkar_all_title.
  ///
  /// In en, this message translates to:
  /// **'All Adhkar'**
  String get adhkar_all_title;

  /// No description provided for @adhkar_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get adhkar_search_hint;

  /// No description provided for @adhkar_recommended_now.
  ///
  /// In en, this message translates to:
  /// **'Recommended now'**
  String get adhkar_recommended_now;

  /// No description provided for @adhkar_no_results.
  ///
  /// In en, this message translates to:
  /// **'No matching adhkar'**
  String get adhkar_no_results;

  /// No description provided for @adhkar_empty.
  ///
  /// In en, this message translates to:
  /// **'No adhkar here yet'**
  String get adhkar_empty;

  /// No description provided for @l10nTools.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TOOLS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nTools;

  /// No description provided for @tools_title.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools_title;

  /// No description provided for @tools_daily_ayah.
  ///
  /// In en, this message translates to:
  /// **'Daily ayah'**
  String get tools_daily_ayah;

  /// No description provided for @tools_daily_dua.
  ///
  /// In en, this message translates to:
  /// **'Daily dua'**
  String get tools_daily_dua;

  /// No description provided for @tools_dua_library.
  ///
  /// In en, this message translates to:
  /// **'Dua Library'**
  String get tools_dua_library;

  /// No description provided for @tools_daily_quiz.
  ///
  /// In en, this message translates to:
  /// **'Daily quiz'**
  String get tools_daily_quiz;

  /// No description provided for @tools_qibla_finder.
  ///
  /// In en, this message translates to:
  /// **'Qibla finder'**
  String get tools_qibla_finder;

  /// No description provided for @tools_prayer_times.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get tools_prayer_times;

  /// No description provided for @tools_dhikr_counter.
  ///
  /// In en, this message translates to:
  /// **'Dhikr counter'**
  String get tools_dhikr_counter;

  /// No description provided for @tools_zakat_calculator.
  ///
  /// In en, this message translates to:
  /// **'Zakat calculator'**
  String get tools_zakat_calculator;

  /// No description provided for @tools_hijri_calendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri calendar'**
  String get tools_hijri_calendar;

  /// No description provided for @l10nQuran.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ QURAN / SOURCE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nQuran;

  /// No description provided for @source_title.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source_title;

  /// No description provided for @source_quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get source_quran;

  /// No description provided for @source_hadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get source_hadith;

  /// No description provided for @source_hadith_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Hadith section coming soon.'**
  String get source_hadith_coming_soon;

  /// No description provided for @source_hadith_coming_soon_sub.
  ///
  /// In en, this message translates to:
  /// **'This feature will be implemented later.'**
  String get source_hadith_coming_soon_sub;

  /// No description provided for @quran_continue_reading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get quran_continue_reading;

  /// No description provided for @quran_all_surahs.
  ///
  /// In en, this message translates to:
  /// **'All Surahs'**
  String get quran_all_surahs;

  /// No description provided for @quran_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get quran_resume;

  /// No description provided for @quran_verse.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get quran_verse;

  /// No description provided for @quran_verses.
  ///
  /// In en, this message translates to:
  /// **'verses'**
  String get quran_verses;

  /// No description provided for @quran_meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get quran_meccan;

  /// No description provided for @quran_medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get quran_medinan;

  /// No description provided for @quran_error_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get quran_error_title;

  /// No description provided for @quran_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the Quran right now.'**
  String get quran_error_subtitle;

  /// No description provided for @quran_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get quran_try_again;

  /// No description provided for @quran_empty.
  ///
  /// In en, this message translates to:
  /// **'No surahs available.'**
  String get quran_empty;

  /// No description provided for @quran_title.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran_title;

  /// No description provided for @quran_done.
  ///
  /// In en, this message translates to:
  /// **'I\'m done'**
  String get quran_done;

  /// No description provided for @quran_transcription_title.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get quran_transcription_title;

  /// No description provided for @quran_transcription_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Transcription isn’t available for this verse yet.'**
  String get quran_transcription_unavailable;

  /// No description provided for @quran_tafsir_title.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get quran_tafsir_title;

  /// No description provided for @quran_tafsir_note.
  ///
  /// In en, this message translates to:
  /// **'A detailed tafsir is on the way. Meanwhile, here is the meaning of the verse:'**
  String get quran_tafsir_note;

  /// No description provided for @hadith_title.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadith_title;

  /// No description provided for @hadith_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get hadith_resume;

  /// No description provided for @hadith_done.
  ///
  /// In en, this message translates to:
  /// **'I\'m done'**
  String get hadith_done;

  /// No description provided for @hadith_error_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get hadith_error_title;

  /// No description provided for @hadith_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the hadiths right now.'**
  String get hadith_error_subtitle;

  /// No description provided for @hadith_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get hadith_try_again;

  /// No description provided for @hadith_empty.
  ///
  /// In en, this message translates to:
  /// **'No hadiths available.'**
  String get hadith_empty;

  /// No description provided for @hadith_explanation_title.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get hadith_explanation_title;

  /// No description provided for @dua_title.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get dua_title;

  /// No description provided for @dua_library_title.
  ///
  /// In en, this message translates to:
  /// **'Dua Library'**
  String get dua_library_title;

  /// No description provided for @dua_done.
  ///
  /// In en, this message translates to:
  /// **'I\'m done'**
  String get dua_done;

  /// No description provided for @dua_when_to_recite.
  ///
  /// In en, this message translates to:
  /// **'When to recite'**
  String get dua_when_to_recite;

  /// No description provided for @dua_explanation_title.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get dua_explanation_title;

  /// No description provided for @dua_error_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get dua_error_title;

  /// No description provided for @dua_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the duas right now.'**
  String get dua_error_subtitle;

  /// No description provided for @dua_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get dua_try_again;

  /// No description provided for @dua_empty.
  ///
  /// In en, this message translates to:
  /// **'No duas available.'**
  String get dua_empty;

  /// No description provided for @prayer_times_title.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get prayer_times_title;

  /// No description provided for @prayer_times_calc_method.
  ///
  /// In en, this message translates to:
  /// **'Calculation method - {method}'**
  String prayer_times_calc_method(String method);

  /// No description provided for @prayer_times_method_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get prayer_times_method_sheet_title;

  /// No description provided for @prayer_times_chourouk.
  ///
  /// In en, this message translates to:
  /// **'Chourouk'**
  String get prayer_times_chourouk;

  /// No description provided for @prayer_times_jumua.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'a'**
  String get prayer_times_jumua;

  /// No description provided for @prayer_times_location_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t determine your location. Enable location access to see accurate prayer times.'**
  String get prayer_times_location_error;

  /// No description provided for @prayer_times_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get prayer_times_retry;

  /// No description provided for @qibla_distance_to_mecca.
  ///
  /// In en, this message translates to:
  /// **'{distance} km to Mecca'**
  String qibla_distance_to_mecca(String distance);

  /// No description provided for @qibla_aligned.
  ///
  /// In en, this message translates to:
  /// **'Facing the Qibla'**
  String get qibla_aligned;

  /// No description provided for @qibla_sensor_error.
  ///
  /// In en, this message translates to:
  /// **'Your device doesn\'t have a compass sensor.'**
  String get qibla_sensor_error;

  /// No description provided for @qibla_locating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get qibla_locating;

  /// No description provided for @hijri_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get hijri_today;

  /// No description provided for @hijri_white_day.
  ///
  /// In en, this message translates to:
  /// **'White day'**
  String get hijri_white_day;

  /// No description provided for @hijri_coming_up.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get hijri_coming_up;

  /// No description provided for @hijri_in_days.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String hijri_in_days(int days);

  /// No description provided for @calc_methods_comment.
  ///
  /// In en, this message translates to:
  /// **'Prayer-time calculation methods (name + description) for CalculationMethodType.'**
  String get calc_methods_comment;

  /// No description provided for @calc_method_muslim_world_league_name.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get calc_method_muslim_world_league_name;

  /// No description provided for @calc_method_muslim_world_league_desc.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League. Widely used across Europe, the Far East and parts of North America. Fajr 18°, Isha 17°.'**
  String get calc_method_muslim_world_league_desc;

  /// No description provided for @calc_method_france_name.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get calc_method_france_name;

  /// No description provided for @calc_method_france_desc.
  ///
  /// In en, this message translates to:
  /// **'Union des Organisations Islamiques de France (UOIF). Fajr and Isha at 12°.'**
  String get calc_method_france_desc;

  /// No description provided for @calc_method_egyptian_name.
  ///
  /// In en, this message translates to:
  /// **'Egyptian'**
  String get calc_method_egyptian_name;

  /// No description provided for @calc_method_egyptian_desc.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority of Survey. Common in Egypt, Africa and parts of the Middle East. Fajr 19.5°, Isha 17.5°.'**
  String get calc_method_egyptian_desc;

  /// No description provided for @calc_method_karachi_name.
  ///
  /// In en, this message translates to:
  /// **'Karachi'**
  String get calc_method_karachi_name;

  /// No description provided for @calc_method_karachi_desc.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi. Used in Pakistan, India, Bangladesh and Afghanistan. Fajr and Isha at 18°.'**
  String get calc_method_karachi_desc;

  /// No description provided for @calc_method_umm_al_qura_name.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura'**
  String get calc_method_umm_al_qura_name;

  /// No description provided for @calc_method_umm_al_qura_desc.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura University, Makkah. Used in Saudi Arabia. Fajr 18.5°, Isha 90 minutes after Maghrib.'**
  String get calc_method_umm_al_qura_desc;

  /// No description provided for @calc_method_dubai_name.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get calc_method_dubai_name;

  /// No description provided for @calc_method_dubai_desc.
  ///
  /// In en, this message translates to:
  /// **'Used across the United Arab Emirates. Fajr and Isha at 18.2°.'**
  String get calc_method_dubai_desc;

  /// No description provided for @calc_method_qatar_name.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get calc_method_qatar_name;

  /// No description provided for @calc_method_qatar_desc.
  ///
  /// In en, this message translates to:
  /// **'Modified Umm al-Qura. Fajr 18°, Isha 90 minutes after Maghrib.'**
  String get calc_method_qatar_desc;

  /// No description provided for @calc_method_kuwait_name.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get calc_method_kuwait_name;

  /// No description provided for @calc_method_kuwait_desc.
  ///
  /// In en, this message translates to:
  /// **'Used in Kuwait. Fajr 18°, Isha 17.5°.'**
  String get calc_method_kuwait_desc;

  /// No description provided for @calc_method_moonsighting_committee_name.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get calc_method_moonsighting_committee_name;

  /// No description provided for @calc_method_moonsighting_committee_desc.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee Worldwide with a seasonal high-latitude adjustment. Fajr and Isha at 18°.'**
  String get calc_method_moonsighting_committee_desc;

  /// No description provided for @calc_method_singapore_name.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get calc_method_singapore_name;

  /// No description provided for @calc_method_singapore_desc.
  ///
  /// In en, this message translates to:
  /// **'Majlis Ugama Islam Singapura. Fajr 20°, Isha 18°.'**
  String get calc_method_singapore_desc;

  /// No description provided for @calc_method_north_america_name.
  ///
  /// In en, this message translates to:
  /// **'North America (ISNA)'**
  String get calc_method_north_america_name;

  /// No description provided for @calc_method_north_america_desc.
  ///
  /// In en, this message translates to:
  /// **'Islamic Society of North America (ISNA). Fajr and Isha at 15°.'**
  String get calc_method_north_america_desc;

  /// No description provided for @calc_method_turkey_name.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get calc_method_turkey_name;

  /// No description provided for @calc_method_turkey_desc.
  ///
  /// In en, this message translates to:
  /// **'Diyanet İşleri Başkanlığı (Turkey). Fajr 18°, Isha 17°.'**
  String get calc_method_turkey_desc;

  /// No description provided for @calc_method_tehran_name.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get calc_method_tehran_name;

  /// No description provided for @calc_method_tehran_desc.
  ///
  /// In en, this message translates to:
  /// **'Institute of Geophysics, University of Tehran. Fajr 17.7°, Isha 14°.'**
  String get calc_method_tehran_desc;

  /// No description provided for @calc_method_algerian_name.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get calc_method_algerian_name;

  /// No description provided for @calc_method_algerian_desc.
  ///
  /// In en, this message translates to:
  /// **'Algerian Ministry of Religious Affairs and Wakfs. Fajr 18°, Isha 17°.'**
  String get calc_method_algerian_desc;

  /// No description provided for @calc_method_gulf_region_name.
  ///
  /// In en, this message translates to:
  /// **'Gulf Region'**
  String get calc_method_gulf_region_name;

  /// No description provided for @calc_method_gulf_region_desc.
  ///
  /// In en, this message translates to:
  /// **'Gulf Region. Fajr 19.5°, Isha 90 minutes after Maghrib.'**
  String get calc_method_gulf_region_desc;

  /// No description provided for @calc_method_indonesian_name.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get calc_method_indonesian_name;

  /// No description provided for @calc_method_indonesian_desc.
  ///
  /// In en, this message translates to:
  /// **'Kementerian Agama Republik Indonesia (KEMENAG). Fajr 20°, Isha 18°.'**
  String get calc_method_indonesian_desc;

  /// No description provided for @calc_method_jafari_name.
  ///
  /// In en, this message translates to:
  /// **'Jafari (Shia)'**
  String get calc_method_jafari_name;

  /// No description provided for @calc_method_jafari_desc.
  ///
  /// In en, this message translates to:
  /// **'Shia Ithna-Ashari, Leva Institute, Qum. Fajr 16°, Maghrib 4°, Isha 14°.'**
  String get calc_method_jafari_desc;

  /// No description provided for @calc_method_jordan_name.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get calc_method_jordan_name;

  /// No description provided for @calc_method_jordan_desc.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan. Fajr and Isha at 18°.'**
  String get calc_method_jordan_desc;

  /// No description provided for @calc_method_morocco_name.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get calc_method_morocco_name;

  /// No description provided for @calc_method_morocco_desc.
  ///
  /// In en, this message translates to:
  /// **'Moroccan Ministry of Habous and Islamic Affairs. Fajr 19°, Isha 17°.'**
  String get calc_method_morocco_desc;

  /// No description provided for @calc_method_portugal_name.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get calc_method_portugal_name;

  /// No description provided for @calc_method_portugal_desc.
  ///
  /// In en, this message translates to:
  /// **'Comunidade Islâmica de Lisboa, Portugal. Fajr 18°, Isha 77 minutes after Maghrib.'**
  String get calc_method_portugal_desc;

  /// No description provided for @calc_method_russia_name.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get calc_method_russia_name;

  /// No description provided for @calc_method_russia_desc.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Administration of Muslims of Russia. Fajr 16°, Isha 15°.'**
  String get calc_method_russia_desc;

  /// No description provided for @calc_method_tunisia_name.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get calc_method_tunisia_name;

  /// No description provided for @calc_method_tunisia_desc.
  ///
  /// In en, this message translates to:
  /// **'Tunisian Ministry of Religious Affairs. Fajr and Isha at 18°.'**
  String get calc_method_tunisia_desc;

  /// No description provided for @zakat_title.
  ///
  /// In en, this message translates to:
  /// **'Zakat calculator'**
  String get zakat_title;

  /// No description provided for @zakat_total_assets.
  ///
  /// In en, this message translates to:
  /// **'Total assets'**
  String get zakat_total_assets;

  /// No description provided for @zakat_total_debts.
  ///
  /// In en, this message translates to:
  /// **'Total debts'**
  String get zakat_total_debts;

  /// No description provided for @zakat_net_assets.
  ///
  /// In en, this message translates to:
  /// **'Net assets'**
  String get zakat_net_assets;

  /// No description provided for @zakat_above_nisab.
  ///
  /// In en, this message translates to:
  /// **'Above Nisab threshold'**
  String get zakat_above_nisab;

  /// No description provided for @zakat_below_nisab.
  ///
  /// In en, this message translates to:
  /// **'Below Nisab threshold'**
  String get zakat_below_nisab;

  /// No description provided for @zakat_your_zakat.
  ///
  /// In en, this message translates to:
  /// **'Your zakat (2.5%)'**
  String get zakat_your_zakat;

  /// No description provided for @zakat_obligation_note.
  ///
  /// In en, this message translates to:
  /// **'Zakat is obligatory on every adult Muslim whose wealth reaches the Nisab and has been in possession for one full lunar year'**
  String get zakat_obligation_note;

  /// No description provided for @zakat_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get zakat_reset;

  /// No description provided for @zakat_give.
  ///
  /// In en, this message translates to:
  /// **'Give zakat'**
  String get zakat_give;

  /// No description provided for @zakat_section_precious_metals.
  ///
  /// In en, this message translates to:
  /// **'Precious metals'**
  String get zakat_section_precious_metals;

  /// No description provided for @zakat_section_cash.
  ///
  /// In en, this message translates to:
  /// **'Cash & savings'**
  String get zakat_section_cash;

  /// No description provided for @zakat_section_investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get zakat_section_investments;

  /// No description provided for @zakat_section_debts.
  ///
  /// In en, this message translates to:
  /// **'Debts you owe'**
  String get zakat_section_debts;

  /// No description provided for @zakat_field_gold.
  ///
  /// In en, this message translates to:
  /// **'Value of gold'**
  String get zakat_field_gold;

  /// No description provided for @zakat_field_silver.
  ///
  /// In en, this message translates to:
  /// **'Value of silver'**
  String get zakat_field_silver;

  /// No description provided for @zakat_per_gram.
  ///
  /// In en, this message translates to:
  /// **'/gram'**
  String get zakat_per_gram;

  /// No description provided for @zakat_field_cash.
  ///
  /// In en, this message translates to:
  /// **'Cash & bank balance'**
  String get zakat_field_cash;

  /// No description provided for @zakat_field_savings.
  ///
  /// In en, this message translates to:
  /// **'Saved for future use'**
  String get zakat_field_savings;

  /// No description provided for @zakat_field_investments.
  ///
  /// In en, this message translates to:
  /// **'Stocks, ETFs, crypto'**
  String get zakat_field_investments;

  /// No description provided for @zakat_field_loans_given.
  ///
  /// In en, this message translates to:
  /// **'Loans given to others'**
  String get zakat_field_loans_given;

  /// No description provided for @zakat_field_personal_loans.
  ///
  /// In en, this message translates to:
  /// **'Personal loans, credit'**
  String get zakat_field_personal_loans;

  /// No description provided for @zakat_field_bills.
  ///
  /// In en, this message translates to:
  /// **'Bills & rent due now'**
  String get zakat_field_bills;

  /// No description provided for @zakat_footer_quote.
  ///
  /// In en, this message translates to:
  /// **'Take from their wealth a charity by which you purify them...'**
  String get zakat_footer_quote;

  /// No description provided for @zakat_field_other.
  ///
  /// In en, this message translates to:
  /// **'Other valuables'**
  String get zakat_field_other;

  /// No description provided for @zakat_nisab_threshold.
  ///
  /// In en, this message translates to:
  /// **'Nisab threshold'**
  String get zakat_nisab_threshold;

  /// No description provided for @zakat_api_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Live zakat service unavailable — showing offline estimate.'**
  String get zakat_api_unavailable;

  /// No description provided for @l10nStopLineDontTouch.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nStopLineDontTouch;

  /// No description provided for @l10nApiErrors.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠ API ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nApiErrors;

  /// No description provided for @error_api_auth_anonymous_failed.
  ///
  /// In en, this message translates to:
  /// **'Anonymous sign-in failed. Please try again.'**
  String get error_api_auth_anonymous_failed;

  /// No description provided for @error_api_auth_start_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start sign-in. Please try again.'**
  String get error_api_auth_start_failed;

  /// No description provided for @error_api_auth_check_email_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify the email address. Please try again.'**
  String get error_api_auth_check_email_failed;

  /// No description provided for @error_api_auth_code_verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Code verification failed. Please check the code and try again.'**
  String get error_api_auth_code_verification_failed;

  /// No description provided for @error_api_auth_sign_in_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get error_api_auth_sign_in_cancelled;

  /// No description provided for @error_api_auth_missing_google_token.
  ///
  /// In en, this message translates to:
  /// **'Missing Google ID token. Please try again.'**
  String get error_api_auth_missing_google_token;

  /// No description provided for @error_api_auth_google_failed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get error_api_auth_google_failed;

  /// No description provided for @error_api_auth_missing_apple_token.
  ///
  /// In en, this message translates to:
  /// **'Missing Apple ID token. Please try again.'**
  String get error_api_auth_missing_apple_token;

  /// No description provided for @error_api_auth_apple_failed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get error_api_auth_apple_failed;

  /// No description provided for @error_api_auth_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Please try again.'**
  String get error_api_auth_delete_failed;

  /// No description provided for @error_api_user_not_authenticated.
  ///
  /// In en, this message translates to:
  /// **'You\'re not signed in. Please sign in and try again.'**
  String get error_api_user_not_authenticated;

  /// No description provided for @error_api_profile_avatar_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload your photo. Please try again.'**
  String get error_api_profile_avatar_upload_failed;

  /// No description provided for @error_api_profile_avatar_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your photo. Please try again.'**
  String get error_api_profile_avatar_delete_failed;

  /// No description provided for @error_api_profile_invalid.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile. Please try again.'**
  String get error_api_profile_invalid;

  /// No description provided for @error_api_profile_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile. Please try again.'**
  String get error_api_profile_load_failed;

  /// No description provided for @error_api_profile_update_practice_time_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your daily practice time.'**
  String get error_api_profile_update_practice_time_failed;

  /// No description provided for @error_api_profile_update_level_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your level.'**
  String get error_api_profile_update_level_failed;

  /// No description provided for @error_api_profile_update_name_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your name.'**
  String get error_api_profile_update_name_failed;

  /// No description provided for @error_api_profile_update_gender_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your gender.'**
  String get error_api_profile_update_gender_failed;

  /// No description provided for @error_api_profile_update_onboarding_screen_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your progress.'**
  String get error_api_profile_update_onboarding_screen_failed;

  /// No description provided for @error_api_profile_complete_onboarding_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete onboarding.'**
  String get error_api_profile_complete_onboarding_failed;

  /// No description provided for @error_api_reward_streak_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your streak.'**
  String get error_api_reward_streak_load_failed;

  /// No description provided for @error_api_reward_claim_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t claim your reward.'**
  String get error_api_reward_claim_failed;

  /// No description provided for @error_api_quiz_unexpected_get_response.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response while loading the quiz.'**
  String get error_api_quiz_unexpected_get_response;

  /// No description provided for @error_api_quiz_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the quiz.'**
  String get error_api_quiz_load_failed;

  /// No description provided for @error_api_quiz_unexpected_submit_response.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response while submitting the quiz.'**
  String get error_api_quiz_unexpected_submit_response;

  /// No description provided for @error_api_quiz_submit_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit the quiz.'**
  String get error_api_quiz_submit_failed;

  /// No description provided for @error_api_favorites_ayahs_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your favourite ayahs.'**
  String get error_api_favorites_ayahs_load_failed;

  /// No description provided for @error_api_favorites_adhkars_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your favourite adhkar.'**
  String get error_api_favorites_adhkars_load_failed;

  /// No description provided for @error_api_favorites_duas_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your favourite duas.'**
  String get error_api_favorites_duas_load_failed;

  /// No description provided for @error_api_favorites_hadiths_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your favourite hadiths.'**
  String get error_api_favorites_hadiths_load_failed;

  /// No description provided for @error_api_favorites_projects_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your favourite projects.'**
  String get error_api_favorites_projects_load_failed;

  /// No description provided for @error_api_dua_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load duas.'**
  String get error_api_dua_load_failed;

  /// No description provided for @error_api_dua_progress_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dua progress.'**
  String get error_api_dua_progress_load_failed;

  /// No description provided for @error_api_dua_progress_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your dua progress.'**
  String get error_api_dua_progress_save_failed;

  /// No description provided for @error_api_dua_ajr_award_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record your daily dua reward.'**
  String get error_api_dua_ajr_award_failed;

  /// No description provided for @error_api_dua_liked_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your liked duas.'**
  String get error_api_dua_liked_load_failed;

  /// No description provided for @error_api_dua_like_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t like this dua.'**
  String get error_api_dua_like_failed;

  /// No description provided for @error_api_dua_unlike_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove the like from this dua.'**
  String get error_api_dua_unlike_failed;

  /// No description provided for @error_api_statistics_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your statistics.'**
  String get error_api_statistics_load_failed;

  /// No description provided for @error_api_adhkar_categories_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load adhkar categories.'**
  String get error_api_adhkar_categories_load_failed;

  /// No description provided for @error_api_adhkar_subcategories_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load adhkar subcategories.'**
  String get error_api_adhkar_subcategories_load_failed;

  /// No description provided for @error_api_adhkars_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load adhkar.'**
  String get error_api_adhkars_load_failed;

  /// No description provided for @error_api_dhikrs_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load dhikr.'**
  String get error_api_dhikrs_load_failed;

  /// No description provided for @error_api_dhikr_progress_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dhikr progress.'**
  String get error_api_dhikr_progress_load_failed;

  /// No description provided for @error_api_dhikr_ajr_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dhikr reward.'**
  String get error_api_dhikr_ajr_load_failed;

  /// No description provided for @error_api_dhikr_progress_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your dhikr progress.'**
  String get error_api_dhikr_progress_save_failed;

  /// No description provided for @error_api_hadith_collections_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load hadith collections.'**
  String get error_api_hadith_collections_load_failed;

  /// No description provided for @error_api_hadiths_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load hadiths.'**
  String get error_api_hadiths_load_failed;

  /// No description provided for @error_api_hadith_progress_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your hadith progress.'**
  String get error_api_hadith_progress_load_failed;

  /// No description provided for @error_api_hadith_progress_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your hadith progress.'**
  String get error_api_hadith_progress_save_failed;

  /// No description provided for @error_api_hadith_liked_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your liked hadiths.'**
  String get error_api_hadith_liked_load_failed;

  /// No description provided for @error_api_hadith_like_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t like this hadith.'**
  String get error_api_hadith_like_failed;

  /// No description provided for @error_api_hadith_unlike_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove the like from this hadith.'**
  String get error_api_hadith_unlike_failed;

  /// No description provided for @error_api_impact_categories_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load project categories.'**
  String get error_api_impact_categories_load_failed;

  /// No description provided for @error_api_impact_projects_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load projects.'**
  String get error_api_impact_projects_load_failed;

  /// No description provided for @error_api_impact_project_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the project.'**
  String get error_api_impact_project_load_failed;

  /// No description provided for @error_api_impact_add_favorite_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add to favourites.'**
  String get error_api_impact_add_favorite_failed;

  /// No description provided for @error_api_impact_remove_favorite_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove from favourites.'**
  String get error_api_impact_remove_favorite_failed;

  /// No description provided for @error_api_quran_progress_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your Quran progress.'**
  String get error_api_quran_progress_load_failed;

  /// No description provided for @error_api_quran_progress_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your Quran progress.'**
  String get error_api_quran_progress_save_failed;

  /// No description provided for @error_api_quran_liked_ayahs_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your liked ayahs.'**
  String get error_api_quran_liked_ayahs_load_failed;

  /// No description provided for @error_api_quran_ayah_ajr_award_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record your daily ayah reward.'**
  String get error_api_quran_ayah_ajr_award_failed;

  /// No description provided for @error_api_quran_like_ayah_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t like this ayah.'**
  String get error_api_quran_like_ayah_failed;

  /// No description provided for @error_api_quran_transliteration_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the transliteration.'**
  String get error_api_quran_transliteration_load_failed;

  /// No description provided for @error_api_quran_tafsir_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the tafsir.'**
  String get error_api_quran_tafsir_load_failed;

  /// No description provided for @error_api_quran_unlike_ayah_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove the like from this ayah.'**
  String get error_api_quran_unlike_ayah_failed;

  /// No description provided for @l10nPayments.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PAYMENTS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nPayments;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_retry;

  /// No description provided for @impact_donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get impact_donate;

  /// No description provided for @impact_donate_or_zakat.
  ///
  /// In en, this message translates to:
  /// **'Donate or give Zakat'**
  String get impact_donate_or_zakat;

  /// No description provided for @impact_transactions_title.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get impact_transactions_title;

  /// No description provided for @impact_transactions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'See how the collected funds were disbursed to the partner, with proof.'**
  String get impact_transactions_subtitle;

  /// No description provided for @impact_transactions_empty.
  ///
  /// In en, this message translates to:
  /// **'No disbursements have been made for this project yet.'**
  String get impact_transactions_empty;

  /// No description provided for @impact_transactions_distributed.
  ///
  /// In en, this message translates to:
  /// **'Distributed'**
  String get impact_transactions_distributed;

  /// No description provided for @donate_title.
  ///
  /// In en, this message translates to:
  /// **'Support this project'**
  String get donate_title;

  /// No description provided for @donate_type_donation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get donate_type_donation;

  /// No description provided for @donate_type_zakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get donate_type_zakat;

  /// No description provided for @donate_amount_label.
  ///
  /// In en, this message translates to:
  /// **'Amount ({symbol})'**
  String donate_amount_label(String symbol);

  /// No description provided for @donate_cover_fees.
  ///
  /// In en, this message translates to:
  /// **'Cover the processing fee'**
  String get donate_cover_fees;

  /// No description provided for @donate_cover_fees_hint.
  ///
  /// In en, this message translates to:
  /// **'Adds {fee} so the project receives the full amount.'**
  String donate_cover_fees_hint(String fee);

  /// No description provided for @donate_button.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String donate_button(String amount);

  /// No description provided for @donate_button_empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get donate_button_empty;

  /// No description provided for @donate_processing_title.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get donate_processing_title;

  /// No description provided for @donate_processing_message.
  ///
  /// In en, this message translates to:
  /// **'We\'re confirming your payment. This only takes a moment.'**
  String get donate_processing_message;

  /// No description provided for @donate_success_title.
  ///
  /// In en, this message translates to:
  /// **'Jazak Allahu khayran!'**
  String get donate_success_title;

  /// No description provided for @donate_success_message.
  ///
  /// In en, this message translates to:
  /// **'Your contribution has been received.'**
  String get donate_success_message;

  /// No description provided for @donate_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get donate_failed_title;

  /// No description provided for @donate_failed_message.
  ///
  /// In en, this message translates to:
  /// **'Your payment could not be completed. No charge was applied.'**
  String get donate_failed_message;

  /// No description provided for @l10nAdmin.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ADMIN ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nAdmin;

  /// No description provided for @admin_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get admin_panel_title;

  /// No description provided for @admin_panel_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Donations, payments and payouts'**
  String get admin_panel_subtitle;

  /// No description provided for @admin_analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Transactions & donations'**
  String get admin_analytics_title;

  /// No description provided for @admin_total_donated.
  ///
  /// In en, this message translates to:
  /// **'Total donated'**
  String get admin_total_donated;

  /// No description provided for @admin_total_donors.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get admin_total_donors;

  /// No description provided for @admin_total_paid_out.
  ///
  /// In en, this message translates to:
  /// **'Paid out'**
  String get admin_total_paid_out;

  /// No description provided for @admin_outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get admin_outstanding;

  /// No description provided for @admin_tab_projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get admin_tab_projects;

  /// No description provided for @admin_tab_payouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get admin_tab_payouts;

  /// No description provided for @admin_tab_received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get admin_tab_received;

  /// No description provided for @admin_record_payout.
  ///
  /// In en, this message translates to:
  /// **'Record payout'**
  String get admin_record_payout;

  /// No description provided for @admin_empty_projects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get admin_empty_projects;

  /// No description provided for @admin_empty_payouts.
  ///
  /// In en, this message translates to:
  /// **'No payouts recorded yet.'**
  String get admin_empty_payouts;

  /// No description provided for @admin_empty_received.
  ///
  /// In en, this message translates to:
  /// **'No transactions received yet.'**
  String get admin_empty_received;

  /// No description provided for @admin_no_donations_yet.
  ///
  /// In en, this message translates to:
  /// **'No donations yet.'**
  String get admin_no_donations_yet;

  /// No description provided for @admin_donors_count.
  ///
  /// In en, this message translates to:
  /// **'{count} donors'**
  String admin_donors_count(String count);

  /// No description provided for @admin_field_project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get admin_field_project;

  /// No description provided for @admin_field_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get admin_field_type;

  /// No description provided for @admin_field_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get admin_field_amount;

  /// No description provided for @admin_field_method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get admin_field_method;

  /// No description provided for @admin_field_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get admin_field_status;

  /// No description provided for @admin_field_reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get admin_field_reference;

  /// No description provided for @admin_field_reference_hint.
  ///
  /// In en, this message translates to:
  /// **'Bank / Wise transfer reference'**
  String get admin_field_reference_hint;

  /// No description provided for @admin_field_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get admin_field_note;

  /// No description provided for @admin_field_proof.
  ///
  /// In en, this message translates to:
  /// **'Proof of transfer'**
  String get admin_field_proof;

  /// No description provided for @admin_add_proof.
  ///
  /// In en, this message translates to:
  /// **'Add a receipt image'**
  String get admin_add_proof;

  /// No description provided for @admin_save_payout.
  ///
  /// In en, this message translates to:
  /// **'Save payout'**
  String get admin_save_payout;

  /// No description provided for @payout_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get payout_confirmed;

  /// No description provided for @payout_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get payout_sent;

  /// No description provided for @payout_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get payout_pending;

  /// No description provided for @error_api_payment_intent_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the payment. Please try again.'**
  String get error_api_payment_intent_failed;

  /// No description provided for @error_api_payment_sheet_failed.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be completed.'**
  String get error_api_payment_sheet_failed;

  /// No description provided for @error_api_payment_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled.'**
  String get error_api_payment_cancelled;

  /// No description provided for @error_api_payment_history_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your donation history.'**
  String get error_api_payment_history_load_failed;

  /// No description provided for @error_api_payment_project_transactions_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this project\'s transactions.'**
  String get error_api_payment_project_transactions_load_failed;

  /// No description provided for @error_api_admin_analytics_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the analytics.'**
  String get error_api_admin_analytics_load_failed;

  /// No description provided for @error_api_admin_payouts_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the payouts.'**
  String get error_api_admin_payouts_load_failed;

  /// No description provided for @error_api_admin_payout_create_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record the payout.'**
  String get error_api_admin_payout_create_failed;

  /// No description provided for @error_api_admin_payout_proof_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload the proof image.'**
  String get error_api_admin_payout_proof_upload_failed;

  /// No description provided for @error_api_admin_transactions_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the transactions.'**
  String get error_api_admin_transactions_load_failed;

  /// No description provided for @l10nPaymentsV2.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PAYMENTS V2 ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nPaymentsV2;

  /// No description provided for @donate_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Donate how much?'**
  String get donate_sheet_title;

  /// No description provided for @donate_frequency_yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get donate_frequency_yearly;

  /// No description provided for @donate_frequency_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get donate_frequency_monthly;

  /// No description provided for @donate_frequency_one_time.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get donate_frequency_one_time;

  /// No description provided for @donate_how_much.
  ///
  /// In en, this message translates to:
  /// **'How much would you like to give ?'**
  String get donate_how_much;

  /// No description provided for @donate_or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get donate_or;

  /// No description provided for @donate_enter_manually.
  ///
  /// In en, this message translates to:
  /// **'Enter amount manually'**
  String get donate_enter_manually;

  /// No description provided for @donate_checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get donate_checkout;

  /// No description provided for @donate_footer_partners.
  ///
  /// In en, this message translates to:
  /// **'Funds are distributed via verified partners'**
  String get donate_footer_partners;

  /// No description provided for @donate_footer_transparent.
  ///
  /// In en, this message translates to:
  /// **'100% transparent'**
  String get donate_footer_transparent;

  /// No description provided for @donate_per_month.
  ///
  /// In en, this message translates to:
  /// **'{amount} / month'**
  String donate_per_month(String amount);

  /// No description provided for @donate_per_year.
  ///
  /// In en, this message translates to:
  /// **'{amount} / year'**
  String donate_per_year(String amount);

  /// No description provided for @impact_donate_now.
  ///
  /// In en, this message translates to:
  /// **'Donate now'**
  String get impact_donate_now;

  /// No description provided for @impact_tiers_title.
  ///
  /// In en, this message translates to:
  /// **'Your donation provides'**
  String get impact_tiers_title;

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_title;

  /// No description provided for @checkout_my_donation.
  ///
  /// In en, this message translates to:
  /// **'My donation'**
  String get checkout_my_donation;

  /// No description provided for @checkout_options_title.
  ///
  /// In en, this message translates to:
  /// **'Donation options'**
  String get checkout_options_title;

  /// No description provided for @checkout_anonymous_title.
  ///
  /// In en, this message translates to:
  /// **'Make this anonymous'**
  String get checkout_anonymous_title;

  /// No description provided for @checkout_anonymous_hint.
  ///
  /// In en, this message translates to:
  /// **'Your name won\'t appear in public counts'**
  String get checkout_anonymous_hint;

  /// No description provided for @checkout_cover_fees_title.
  ///
  /// In en, this message translates to:
  /// **'Cover transaction fees (+{fee})'**
  String checkout_cover_fees_title(String fee);

  /// No description provided for @checkout_cover_fees_hint.
  ///
  /// In en, this message translates to:
  /// **'100% of your donation reaches projects'**
  String get checkout_cover_fees_hint;

  /// No description provided for @checkout_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get checkout_payment_method;

  /// No description provided for @checkout_method_paypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get checkout_method_paypal;

  /// No description provided for @checkout_method_card.
  ///
  /// In en, this message translates to:
  /// **'Debit/Credit card'**
  String get checkout_method_card;

  /// No description provided for @checkout_method_apple_pay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get checkout_method_apple_pay;

  /// No description provided for @checkout_method_google_pay.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get checkout_method_google_pay;

  /// No description provided for @checkout_pay_button.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_pay_button;

  /// No description provided for @checkout_total.
  ///
  /// In en, this message translates to:
  /// **'Total {amount}'**
  String checkout_total(String amount);

  /// No description provided for @checkout_recurring_note_month.
  ///
  /// In en, this message translates to:
  /// **'You will be charged {amount} every month. Cancel anytime from My donations.'**
  String checkout_recurring_note_month(String amount);

  /// No description provided for @checkout_recurring_note_year.
  ///
  /// In en, this message translates to:
  /// **'You will be charged {amount} every year. Cancel anytime from My donations.'**
  String checkout_recurring_note_year(String amount);

  /// No description provided for @checkout_processing_title.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment…'**
  String get checkout_processing_title;

  /// No description provided for @checkout_processing_message.
  ///
  /// In en, this message translates to:
  /// **'This usually takes a few seconds. Please don\'t close the app.'**
  String get checkout_processing_message;

  /// No description provided for @checkout_timeout_title.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than expected'**
  String get checkout_timeout_title;

  /// No description provided for @checkout_timeout_message.
  ///
  /// In en, this message translates to:
  /// **'Your payment is still being confirmed. You can keep waiting or check the status later in My donations.'**
  String get checkout_timeout_message;

  /// No description provided for @checkout_keep_waiting.
  ///
  /// In en, this message translates to:
  /// **'Keep waiting'**
  String get checkout_keep_waiting;

  /// No description provided for @checkout_check_later.
  ///
  /// In en, this message translates to:
  /// **'Check later'**
  String get checkout_check_later;

  /// No description provided for @reward_donation_title.
  ///
  /// In en, this message translates to:
  /// **'Jazak Allahu Khayr'**
  String get reward_donation_title;

  /// No description provided for @reward_donation_message.
  ///
  /// In en, this message translates to:
  /// **'Your donation has been received.\nMay Allah accept it and multiply its reward.'**
  String get reward_donation_message;

  /// No description provided for @reward_donation_you_donated.
  ///
  /// In en, this message translates to:
  /// **'You donated'**
  String get reward_donation_you_donated;

  /// No description provided for @reward_donation_you_give.
  ///
  /// In en, this message translates to:
  /// **'You give'**
  String get reward_donation_you_give;

  /// No description provided for @reward_donation_project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get reward_donation_project;

  /// No description provided for @reward_donation_via.
  ///
  /// In en, this message translates to:
  /// **'Via {org}'**
  String reward_donation_via(String org);

  /// No description provided for @profile_my_donations.
  ///
  /// In en, this message translates to:
  /// **'My donations'**
  String get profile_my_donations;

  /// No description provided for @my_donations_tab_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get my_donations_tab_history;

  /// No description provided for @my_donations_tab_recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get my_donations_tab_recurring;

  /// No description provided for @my_donations_empty_history.
  ///
  /// In en, this message translates to:
  /// **'No donations yet. Your contributions will appear here.'**
  String get my_donations_empty_history;

  /// No description provided for @my_donations_empty_recurring.
  ///
  /// In en, this message translates to:
  /// **'No recurring donations.'**
  String get my_donations_empty_recurring;

  /// No description provided for @my_donations_status_succeeded.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get my_donations_status_succeeded;

  /// No description provided for @my_donations_status_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get my_donations_status_failed;

  /// No description provided for @my_donations_status_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get my_donations_status_refunded;

  /// No description provided for @my_donations_status_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get my_donations_status_processing;

  /// No description provided for @my_donations_sub_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get my_donations_sub_active;

  /// No description provided for @my_donations_sub_past_due.
  ///
  /// In en, this message translates to:
  /// **'Payment issue'**
  String get my_donations_sub_past_due;

  /// No description provided for @my_donations_sub_canceled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get my_donations_sub_canceled;

  /// No description provided for @my_donations_sub_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get my_donations_sub_incomplete;

  /// No description provided for @my_donations_sub_ends_on.
  ///
  /// In en, this message translates to:
  /// **'Ends on {date}'**
  String my_donations_sub_ends_on(String date);

  /// No description provided for @my_donations_next_charge.
  ///
  /// In en, this message translates to:
  /// **'Next charge: {date}'**
  String my_donations_next_charge(String date);

  /// No description provided for @my_donations_cancel.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get my_donations_cancel;

  /// No description provided for @my_donations_cancel_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Stop this recurring donation?'**
  String get my_donations_cancel_confirm_title;

  /// No description provided for @my_donations_cancel_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'It stays active until the end of the current period, then no further charges are made.'**
  String get my_donations_cancel_confirm_message;

  /// No description provided for @my_donations_cancel_confirm_yes.
  ///
  /// In en, this message translates to:
  /// **'Stop donation'**
  String get my_donations_cancel_confirm_yes;

  /// No description provided for @my_donations_keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get my_donations_keep;

  /// No description provided for @my_donations_anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get my_donations_anonymous;

  /// No description provided for @my_donations_fee_included.
  ///
  /// In en, this message translates to:
  /// **'incl. {fee} fees'**
  String my_donations_fee_included(String fee);

  /// No description provided for @my_donations_zakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get my_donations_zakat;

  /// No description provided for @my_donations_sadaqa.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa'**
  String get my_donations_sadaqa;

  /// No description provided for @my_donations_recurring_badge.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get my_donations_recurring_badge;

  /// No description provided for @error_api_payment_amount_too_small.
  ///
  /// In en, this message translates to:
  /// **'The minimum donation is 1€.'**
  String get error_api_payment_amount_too_small;

  /// No description provided for @error_api_payment_amount_too_large.
  ///
  /// In en, this message translates to:
  /// **'The maximum per payment is 10,000€.'**
  String get error_api_payment_amount_too_large;

  /// No description provided for @error_api_payment_project_inactive.
  ///
  /// In en, this message translates to:
  /// **'This project is no longer accepting donations.'**
  String get error_api_payment_project_inactive;

  /// No description provided for @error_api_payment_not_zakat_eligible.
  ///
  /// In en, this message translates to:
  /// **'This project is not eligible for zakat.'**
  String get error_api_payment_not_zakat_eligible;

  /// No description provided for @error_api_payment_subscription_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t set up the recurring donation. Please try again.'**
  String get error_api_payment_subscription_failed;

  /// No description provided for @error_api_payment_subscriptions_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your recurring donations.'**
  String get error_api_payment_subscriptions_load_failed;

  /// No description provided for @error_api_payment_subscription_cancel_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t stop the recurring donation. Please try again.'**
  String get error_api_payment_subscription_cancel_failed;

  /// No description provided for @error_api_payment_confirmation_timeout.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the payment yet. Check My donations in a moment.'**
  String get error_api_payment_confirmation_timeout;

  /// No description provided for @admin_change_status_title.
  ///
  /// In en, this message translates to:
  /// **'Change payout status'**
  String get admin_change_status_title;

  /// No description provided for @admin_change_status_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Only CONFIRMED disbursements are shown publicly on the project page.'**
  String get admin_change_status_subtitle;

  /// No description provided for @admin_status_pending_hint.
  ///
  /// In en, this message translates to:
  /// **'Recorded, transfer not sent yet'**
  String get admin_status_pending_hint;

  /// No description provided for @admin_status_sent_hint.
  ///
  /// In en, this message translates to:
  /// **'Transfer sent, awaiting partner confirmation'**
  String get admin_status_sent_hint;

  /// No description provided for @admin_status_confirmed_hint.
  ///
  /// In en, this message translates to:
  /// **'Received by the partner — visible to donors'**
  String get admin_status_confirmed_hint;

  /// No description provided for @error_api_admin_payout_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the payout status.'**
  String get error_api_admin_payout_update_failed;

  /// No description provided for @zakat_alloc_title.
  ///
  /// In en, this message translates to:
  /// **'Give zakat to eligible Nour projects'**
  String get zakat_alloc_title;

  /// No description provided for @zakat_alloc_info.
  ///
  /// In en, this message translates to:
  /// **'Only projects that meet the 8 Quranic categories of Zakat eligibility (Surah 9:60) are shown here'**
  String get zakat_alloc_info;

  /// No description provided for @zakat_alloc_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No zakat-eligible projects right now'**
  String get zakat_alloc_empty_title;

  /// No description provided for @zakat_alloc_empty_message.
  ///
  /// In en, this message translates to:
  /// **'You can\'t give zakat through the app just yet — don\'t worry, new eligible projects will be added soon insha\'Allah.'**
  String get zakat_alloc_empty_message;

  /// No description provided for @zakat_alloc_owed.
  ///
  /// In en, this message translates to:
  /// **'Zakat owed'**
  String get zakat_alloc_owed;

  /// No description provided for @zakat_alloc_allocated.
  ///
  /// In en, this message translates to:
  /// **'Zakat allocated'**
  String get zakat_alloc_allocated;

  /// No description provided for @zakat_alloc_fully.
  ///
  /// In en, this message translates to:
  /// **'Fully allocated'**
  String get zakat_alloc_fully;

  /// No description provided for @zakat_alloc_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get zakat_alloc_remaining;

  /// No description provided for @zakat_alloc_extra.
  ///
  /// In en, this message translates to:
  /// **'Extra (counts as Sadaqa)'**
  String get zakat_alloc_extra;

  /// No description provided for @zakat_checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get zakat_checkout_title;

  /// No description provided for @zakat_checkout_my_zakat.
  ///
  /// In en, this message translates to:
  /// **'My zakat'**
  String get zakat_checkout_my_zakat;

  /// No description provided for @zakat_checkout_allocated_to.
  ///
  /// In en, this message translates to:
  /// **'Allocated to'**
  String get zakat_checkout_allocated_to;

  /// No description provided for @zakat_checkout_fees.
  ///
  /// In en, this message translates to:
  /// **'Transaction fees'**
  String get zakat_checkout_fees;

  /// No description provided for @zakat_checkout_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get zakat_checkout_total;

  /// No description provided for @zakat_reward_message.
  ///
  /// In en, this message translates to:
  /// **'Your zakat has been received.\nMay Allah accept it and multiply its reward.'**
  String get zakat_reward_message;

  /// No description provided for @zakat_reward_you_gave.
  ///
  /// In en, this message translates to:
  /// **'You gave'**
  String get zakat_reward_you_gave;

  /// No description provided for @admin_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get admin_filter_all;

  /// No description provided for @admin_delete_payout.
  ///
  /// In en, this message translates to:
  /// **'Delete this payout'**
  String get admin_delete_payout;

  /// No description provided for @admin_delete_payout_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete this payout?'**
  String get admin_delete_payout_confirm_title;

  /// No description provided for @admin_delete_payout_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'It disappears permanently from the ledger and, if it was confirmed, from the public transparency section of the project. Paid-out and outstanding totals will be recalculated.'**
  String get admin_delete_payout_confirm_message;

  /// No description provided for @admin_delete_payout_confirm_yes.
  ///
  /// In en, this message translates to:
  /// **'Delete payout'**
  String get admin_delete_payout_confirm_yes;

  /// No description provided for @error_api_admin_payout_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the payout.'**
  String get error_api_admin_payout_delete_failed;

  /// No description provided for @common_required_field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get common_required_field;

  /// No description provided for @common_optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get common_optional;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @mosque_onboarding_resume.
  ///
  /// In en, this message translates to:
  /// **'Continue my mosque registration'**
  String get mosque_onboarding_resume;

  /// No description provided for @mosque_onboarding_start_over.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get mosque_onboarding_start_over;

  /// No description provided for @profile_type_title.
  ///
  /// In en, this message translates to:
  /// **'How will you use Nour?'**
  String get profile_type_title;

  /// No description provided for @profile_type_mosque_title.
  ///
  /// In en, this message translates to:
  /// **'I am a mosque manager'**
  String get profile_type_mosque_title;

  /// No description provided for @profile_type_mosque_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish to your community, run fundraising campaigns.'**
  String get profile_type_mosque_subtitle;

  /// No description provided for @profile_type_user_title.
  ///
  /// In en, this message translates to:
  /// **'I am a worshipper'**
  String get profile_type_user_title;

  /// No description provided for @profile_type_user_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow mosques, track prayer times, and stay connected.'**
  String get profile_type_user_subtitle;

  /// No description provided for @mosque_post_type_announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get mosque_post_type_announcement;

  /// No description provided for @mosque_post_type_event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get mosque_post_type_event;

  /// No description provided for @mosque_post_type_event_hint.
  ///
  /// In en, this message translates to:
  /// **'Date, time, place'**
  String get mosque_post_type_event_hint;

  /// No description provided for @mosque_post_type_volunteering.
  ///
  /// In en, this message translates to:
  /// **'Volunteering'**
  String get mosque_post_type_volunteering;

  /// No description provided for @mosque_post_type_volunteering_hint.
  ///
  /// In en, this message translates to:
  /// **'Recruit helpers'**
  String get mosque_post_type_volunteering_hint;

  /// No description provided for @mosque_post_type_highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get mosque_post_type_highlight;

  /// No description provided for @mosque_post_type_highlight_hint.
  ///
  /// In en, this message translates to:
  /// **'Share moments'**
  String get mosque_post_type_highlight_hint;

  /// No description provided for @mosque_post_type_janaza.
  ///
  /// In en, this message translates to:
  /// **'Janaza'**
  String get mosque_post_type_janaza;

  /// No description provided for @mosque_post_type_janaza_hint.
  ///
  /// In en, this message translates to:
  /// **'Date, prayer time'**
  String get mosque_post_type_janaza_hint;

  /// No description provided for @mosque_onboarding_feature_1_title.
  ///
  /// In en, this message translates to:
  /// **'Made for mosque announcements.'**
  String get mosque_onboarding_feature_1_title;

  /// No description provided for @mosque_onboarding_feature_1_description.
  ///
  /// In en, this message translates to:
  /// **'Events, fundraisers, volunteer calls, janazas, reminders, highlights.'**
  String get mosque_onboarding_feature_1_description;

  /// No description provided for @mosque_onboarding_feature_2_title.
  ///
  /// In en, this message translates to:
  /// **'Raise funds the trusted way.'**
  String get mosque_onboarding_feature_2_title;

  /// No description provided for @mosque_onboarding_feature_2_description.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Sadaqah and time-bound campaigns.'**
  String get mosque_onboarding_feature_2_description;

  /// No description provided for @mosque_onboarding_feature_3_title.
  ///
  /// In en, this message translates to:
  /// **'A calendar that reflects your imam.'**
  String get mosque_onboarding_feature_3_title;

  /// No description provided for @mosque_onboarding_feature_3_description.
  ///
  /// In en, this message translates to:
  /// **'Publish your own prayer schedule and iqama times.'**
  String get mosque_onboarding_feature_3_description;

  /// No description provided for @mosque_onboarding_country_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your country'**
  String get mosque_onboarding_country_title;

  /// No description provided for @mosque_onboarding_country_search.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get mosque_onboarding_country_search;

  /// No description provided for @mosque_legal_status_1901.
  ///
  /// In en, this message translates to:
  /// **'Association (law 1901)'**
  String get mosque_legal_status_1901;

  /// No description provided for @mosque_legal_status_1905.
  ///
  /// In en, this message translates to:
  /// **'Religious association (law 1905)'**
  String get mosque_legal_status_1905;

  /// No description provided for @mosque_legal_status_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get mosque_legal_status_other;

  /// No description provided for @mosque_register_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s register your mosque'**
  String get mosque_register_title;

  /// No description provided for @mosque_register_legal_name.
  ///
  /// In en, this message translates to:
  /// **'Legal name'**
  String get mosque_register_legal_name;

  /// No description provided for @mosque_register_legal_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your legal name'**
  String get mosque_register_legal_name_hint;

  /// No description provided for @mosque_register_legal_status.
  ///
  /// In en, this message translates to:
  /// **'Legal status'**
  String get mosque_register_legal_status;

  /// No description provided for @mosque_register_legal_status_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a legal status'**
  String get mosque_register_legal_status_hint;

  /// No description provided for @mosque_register_rna.
  ///
  /// In en, this message translates to:
  /// **'RNA'**
  String get mosque_register_rna;

  /// No description provided for @mosque_register_rna_invalid.
  ///
  /// In en, this message translates to:
  /// **'RNA must look like W751123456'**
  String get mosque_register_rna_invalid;

  /// No description provided for @mosque_register_siren.
  ///
  /// In en, this message translates to:
  /// **'SIREN number'**
  String get mosque_register_siren;

  /// No description provided for @mosque_register_siren_invalid.
  ///
  /// In en, this message translates to:
  /// **'SIREN must have 9 digits'**
  String get mosque_register_siren_invalid;

  /// No description provided for @mosque_register_cta.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get mosque_register_cta;

  /// No description provided for @mosque_account_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your account'**
  String get mosque_account_title;

  /// No description provided for @mosque_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'To manage your mosque on Nour'**
  String get mosque_account_subtitle;

  /// No description provided for @mosque_account_existing_hint.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Use the same email or provider to sign in.'**
  String get mosque_account_existing_hint;

  /// No description provided for @mosque_account_cta.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get mosque_account_cta;

  /// No description provided for @mosque_review_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Your mosque is being reviewed'**
  String get mosque_review_pending_title;

  /// No description provided for @mosque_review_pending_message.
  ///
  /// In en, this message translates to:
  /// **'Our team is checking your registration. You\'ll be notified as soon as it is approved — usually within a few days.'**
  String get mosque_review_pending_message;

  /// No description provided for @mosque_review_rejected_title.
  ///
  /// In en, this message translates to:
  /// **'Registration refused'**
  String get mosque_review_rejected_title;

  /// No description provided for @mosque_review_rejected_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t approve your mosque. See the note below or contact support.'**
  String get mosque_review_rejected_message;

  /// No description provided for @mosque_review_suspended_title.
  ///
  /// In en, this message translates to:
  /// **'Mosque suspended'**
  String get mosque_review_suspended_title;

  /// No description provided for @mosque_review_suspended_message.
  ///
  /// In en, this message translates to:
  /// **'Your mosque profile has been suspended. Contact support for more information.'**
  String get mosque_review_suspended_message;

  /// No description provided for @mosque_review_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get mosque_review_contact_support;

  /// No description provided for @mosque_admin_tab_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get mosque_admin_tab_dashboard;

  /// No description provided for @mosque_admin_tab_community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get mosque_admin_tab_community;

  /// No description provided for @mosque_admin_tab_mosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get mosque_admin_tab_mosque;

  /// No description provided for @mosque_admin_tab_post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get mosque_admin_tab_post;

  /// No description provided for @mosque_admin_total_raised_year.
  ///
  /// In en, this message translates to:
  /// **'Total raised this year'**
  String get mosque_admin_total_raised_year;

  /// No description provided for @mosque_admin_donors.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get mosque_admin_donors;

  /// No description provided for @mosque_admin_recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get mosque_admin_recurring;

  /// No description provided for @mosque_admin_avg_gift.
  ///
  /// In en, this message translates to:
  /// **'Avg gift'**
  String get mosque_admin_avg_gift;

  /// No description provided for @error_api_mosque_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the mosque.'**
  String get error_api_mosque_load_failed;

  /// No description provided for @error_api_mosque_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the changes.'**
  String get error_api_mosque_save_failed;

  /// No description provided for @error_api_mosque_search_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search mosques.'**
  String get error_api_mosque_search_failed;

  /// No description provided for @error_api_mosque_register_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t register the mosque. Please try again.'**
  String get error_api_mosque_register_failed;

  /// No description provided for @error_api_mosque_register_is_worshipper.
  ///
  /// In en, this message translates to:
  /// **'This account is already a worshipper account. Use another email to register a mosque.'**
  String get error_api_mosque_register_is_worshipper;

  /// No description provided for @error_api_mosque_register_anonymous.
  ///
  /// In en, this message translates to:
  /// **'Please sign in with an email, Google or Apple account.'**
  String get error_api_mosque_register_anonymous;

  /// No description provided for @error_api_mosque_register_invalid_siren.
  ///
  /// In en, this message translates to:
  /// **'The SIREN number is invalid.'**
  String get error_api_mosque_register_invalid_siren;

  /// No description provided for @error_api_mosque_register_invalid_rna.
  ///
  /// In en, this message translates to:
  /// **'The RNA number is invalid.'**
  String get error_api_mosque_register_invalid_rna;

  /// No description provided for @error_api_mosque_register_duplicate.
  ///
  /// In en, this message translates to:
  /// **'This mosque is already registered. Contact support if you manage it.'**
  String get error_api_mosque_register_duplicate;

  /// No description provided for @error_api_mosque_post_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'You reached the limit of active posts of this type. Archive one first.'**
  String get error_api_mosque_post_limit_reached;

  /// No description provided for @error_api_mosque_broadcast_quota_exceeded.
  ///
  /// In en, this message translates to:
  /// **'You already sent the maximum notifications this week.'**
  String get error_api_mosque_broadcast_quota_exceeded;

  /// No description provided for @error_api_mosque_not_approved.
  ///
  /// In en, this message translates to:
  /// **'Your mosque is not approved yet.'**
  String get error_api_mosque_not_approved;

  /// No description provided for @error_api_push_register_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t register this device for notifications.'**
  String get error_api_push_register_failed;

  /// No description provided for @push_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get push_settings_title;

  /// No description provided for @push_settings_description.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications Nour may send to this device. Prayer and adhkar reminders are managed in Reminders.'**
  String get push_settings_description;

  /// No description provided for @push_kind_mosque_post.
  ///
  /// In en, this message translates to:
  /// **'Mosque news'**
  String get push_kind_mosque_post;

  /// No description provided for @push_kind_mosque_post_hint.
  ///
  /// In en, this message translates to:
  /// **'Announcements from the mosques you follow'**
  String get push_kind_mosque_post_hint;

  /// No description provided for @push_kind_mosque_event.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get push_kind_mosque_event;

  /// No description provided for @push_kind_mosque_event_hint.
  ///
  /// In en, this message translates to:
  /// **'Conferences, janazas, volunteering'**
  String get push_kind_mosque_event_hint;

  /// No description provided for @push_kind_mosque_campaign.
  ///
  /// In en, this message translates to:
  /// **'Fundraising campaigns'**
  String get push_kind_mosque_campaign;

  /// No description provided for @push_kind_mosque_campaign_hint.
  ///
  /// In en, this message translates to:
  /// **'New campaigns and deadlines'**
  String get push_kind_mosque_campaign_hint;

  /// No description provided for @push_kind_mosque_broadcast.
  ///
  /// In en, this message translates to:
  /// **'Messages from the mosque'**
  String get push_kind_mosque_broadcast;

  /// No description provided for @push_kind_mosque_broadcast_hint.
  ///
  /// In en, this message translates to:
  /// **'Direct messages sent by the mosque (max 2 per week)'**
  String get push_kind_mosque_broadcast_hint;

  /// No description provided for @push_kind_mosque_status.
  ///
  /// In en, this message translates to:
  /// **'Mosque account'**
  String get push_kind_mosque_status;

  /// No description provided for @push_kind_mosque_status_hint.
  ///
  /// In en, this message translates to:
  /// **'Review status and important account updates'**
  String get push_kind_mosque_status_hint;

  /// No description provided for @push_kind_system.
  ///
  /// In en, this message translates to:
  /// **'Nour updates'**
  String get push_kind_system;

  /// No description provided for @push_kind_system_hint.
  ///
  /// In en, this message translates to:
  /// **'Occasional news about the app'**
  String get push_kind_system_hint;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_load_more.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get common_load_more;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @admin_tab_mosques.
  ///
  /// In en, this message translates to:
  /// **'Mosques'**
  String get admin_tab_mosques;

  /// No description provided for @admin_mosque_approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get admin_mosque_approve;

  /// No description provided for @admin_mosque_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get admin_mosque_reject;

  /// No description provided for @admin_mosque_suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get admin_mosque_suspend;

  /// No description provided for @admin_mosque_reviewed.
  ///
  /// In en, this message translates to:
  /// **'Mosque updated — the owner has been notified.'**
  String get admin_mosque_reviewed;

  /// No description provided for @admin_mosque_duplicate_siren.
  ///
  /// In en, this message translates to:
  /// **'⚠ Another mosque uses this SIREN'**
  String get admin_mosque_duplicate_siren;

  /// No description provided for @admin_mosque_empty.
  ///
  /// In en, this message translates to:
  /// **'No mosque in this state.'**
  String get admin_mosque_empty;

  /// No description provided for @admin_mosque_filter_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get admin_mosque_filter_pending;

  /// No description provided for @admin_mosque_filter_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get admin_mosque_filter_approved;

  /// No description provided for @admin_mosque_filter_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get admin_mosque_filter_rejected;

  /// No description provided for @admin_mosque_filter_suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get admin_mosque_filter_suspended;

  /// No description provided for @admin_mosque_note_title.
  ///
  /// In en, this message translates to:
  /// **'Note for the mosque'**
  String get admin_mosque_note_title;

  /// No description provided for @admin_mosque_note_hint.
  ///
  /// In en, this message translates to:
  /// **'Reason (shown to the mosque manager)'**
  String get admin_mosque_note_hint;

  /// No description provided for @home_my_mosque.
  ///
  /// In en, this message translates to:
  /// **'My mosque'**
  String get home_my_mosque;

  /// No description provided for @home_no_mosque_title.
  ///
  /// In en, this message translates to:
  /// **'No mosque selected yet'**
  String get home_no_mosque_title;

  /// No description provided for @home_no_mosque_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your mosque to see its prayer times, news and campaigns right here.'**
  String get home_no_mosque_subtitle;

  /// No description provided for @home_find_mosque.
  ///
  /// In en, this message translates to:
  /// **'Find a mosque'**
  String get home_find_mosque;

  /// No description provided for @profile_my_mosques.
  ///
  /// In en, this message translates to:
  /// **'My mosques'**
  String get profile_my_mosques;

  /// No description provided for @prayer_times_add_mosque.
  ///
  /// In en, this message translates to:
  /// **'Add your mosque'**
  String get prayer_times_add_mosque;

  /// No description provided for @prayer_times_from_mosque_hint.
  ///
  /// In en, this message translates to:
  /// **'Times published by your mosque. Change your mosque to switch back to computed times.'**
  String get prayer_times_from_mosque_hint;

  /// No description provided for @onboarding_mosque_title.
  ///
  /// In en, this message translates to:
  /// **'Select a mosque'**
  String get onboarding_mosque_title;

  /// No description provided for @onboarding_mosque_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find and follow your local mosque to get its prayer times and news.'**
  String get onboarding_mosque_subtitle;

  /// No description provided for @mosque_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search a mosque'**
  String get mosque_search_hint;

  /// No description provided for @mosque_search_near_you.
  ///
  /// In en, this message translates to:
  /// **'Mosques near you'**
  String get mosque_search_near_you;

  /// No description provided for @mosque_search_near_you_short.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get mosque_search_near_you_short;

  /// No description provided for @mosque_search_results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get mosque_search_results;

  /// No description provided for @mosque_search_empty.
  ///
  /// In en, this message translates to:
  /// **'No mosque found. Try another name or city.'**
  String get mosque_search_empty;

  /// No description provided for @mosque_search_language.
  ///
  /// In en, this message translates to:
  /// **'Search language'**
  String get mosque_search_language;

  /// No description provided for @mosque_add_to_my_mosques.
  ///
  /// In en, this message translates to:
  /// **'Add to my mosques'**
  String get mosque_add_to_my_mosques;

  /// No description provided for @my_mosques_title.
  ///
  /// In en, this message translates to:
  /// **'Your mosque(s)'**
  String get my_mosques_title;

  /// No description provided for @my_mosques_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop the mosques to reorder them and set the main mosque.'**
  String get my_mosques_subtitle;

  /// No description provided for @my_mosques_principal.
  ///
  /// In en, this message translates to:
  /// **'Principal mosque'**
  String get my_mosques_principal;

  /// No description provided for @my_mosques_secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary mosque'**
  String get my_mosques_secondary;

  /// No description provided for @my_mosques_no_principal.
  ///
  /// In en, this message translates to:
  /// **'No principal mosque yet'**
  String get my_mosques_no_principal;

  /// No description provided for @my_mosques_no_secondary.
  ///
  /// In en, this message translates to:
  /// **'No secondary mosque yet'**
  String get my_mosques_no_secondary;

  /// No description provided for @my_mosques_saved.
  ///
  /// In en, this message translates to:
  /// **'Your mosques are saved.'**
  String get my_mosques_saved;

  /// No description provided for @my_mosques_added.
  ///
  /// In en, this message translates to:
  /// **'In my mosques'**
  String get my_mosques_added;

  /// No description provided for @my_mosques_is_principal.
  ///
  /// In en, this message translates to:
  /// **'Your principal mosque'**
  String get my_mosques_is_principal;

  /// No description provided for @my_mosques_is_secondary.
  ///
  /// In en, this message translates to:
  /// **'Your secondary mosque'**
  String get my_mosques_is_secondary;

  /// No description provided for @mosque_cover_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get mosque_cover_placeholder;

  /// No description provided for @mosque_status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mosque_status_open;

  /// No description provided for @mosque_status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mosque_status_closed;

  /// No description provided for @mosque_followers.
  ///
  /// In en, this message translates to:
  /// **'followers'**
  String get mosque_followers;

  /// No description provided for @mosque_members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get mosque_members;

  /// No description provided for @mosque_followers_title.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get mosque_followers_title;

  /// No description provided for @mosque_members_title.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get mosque_members_title;

  /// No description provided for @mosque_follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get mosque_follow;

  /// No description provided for @mosque_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get mosque_following;

  /// No description provided for @mosque_become_member.
  ///
  /// In en, this message translates to:
  /// **'Become a member'**
  String get mosque_become_member;

  /// No description provided for @mosque_member_badge.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get mosque_member_badge;

  /// No description provided for @mosque_follower_badge.
  ///
  /// In en, this message translates to:
  /// **'Follower'**
  String get mosque_follower_badge;

  /// No description provided for @mosque_action_itinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get mosque_action_itinerary;

  /// No description provided for @mosque_action_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get mosque_action_call;

  /// No description provided for @mosque_action_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get mosque_action_email;

  /// No description provided for @mosque_address_copied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get mosque_address_copied;

  /// No description provided for @mosque_tab_prayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get mosque_tab_prayers;

  /// No description provided for @mosque_tab_information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get mosque_tab_information;

  /// No description provided for @mosque_tab_news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get mosque_tab_news;

  /// No description provided for @mosque_tab_donation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get mosque_tab_donation;

  /// No description provided for @mosque_today_prayer_times.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayer times'**
  String get mosque_today_prayer_times;

  /// No description provided for @mosque_prayer_times_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Prayer times are not available right now.'**
  String get mosque_prayer_times_unavailable;

  /// No description provided for @mosque_prayer_times_computed_hint.
  ///
  /// In en, this message translates to:
  /// **'Computed times — the mosque hasn\'t published today\'s schedule yet.'**
  String get mosque_prayer_times_computed_hint;

  /// No description provided for @mosque_prayer_times_not_published.
  ///
  /// In en, this message translates to:
  /// **'Prayer times not published yet'**
  String get mosque_prayer_times_not_published;

  /// No description provided for @mosque_capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get mosque_capacity;

  /// No description provided for @mosque_capacity_men.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get mosque_capacity_men;

  /// No description provided for @mosque_capacity_women.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get mosque_capacity_women;

  /// No description provided for @mosque_capacity_men_women.
  ///
  /// In en, this message translates to:
  /// **'Men + Women'**
  String get mosque_capacity_men_women;

  /// No description provided for @mosque_founded.
  ///
  /// In en, this message translates to:
  /// **'Founded'**
  String get mosque_founded;

  /// No description provided for @mosque_years_old.
  ///
  /// In en, this message translates to:
  /// **'{n} years old'**
  String mosque_years_old(int n);

  /// No description provided for @mosque_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get mosque_services;

  /// No description provided for @mosque_services_edit_hint.
  ///
  /// In en, this message translates to:
  /// **'Select the services your mosque offers. They\'ll appear on your public profile.'**
  String get mosque_services_edit_hint;

  /// No description provided for @mosque_no_services.
  ///
  /// In en, this message translates to:
  /// **'No service listed yet.'**
  String get mosque_no_services;

  /// No description provided for @mosque_service_parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get mosque_service_parking;

  /// No description provided for @mosque_service_disabled_access.
  ///
  /// In en, this message translates to:
  /// **'Disabled access'**
  String get mosque_service_disabled_access;

  /// No description provided for @mosque_service_ablution_room.
  ///
  /// In en, this message translates to:
  /// **'Ablution room'**
  String get mosque_service_ablution_room;

  /// No description provided for @mosque_service_women_space.
  ///
  /// In en, this message translates to:
  /// **'Women\'s space'**
  String get mosque_service_women_space;

  /// No description provided for @mosque_service_adult_classes.
  ///
  /// In en, this message translates to:
  /// **'Adult classes'**
  String get mosque_service_adult_classes;

  /// No description provided for @mosque_service_children_classes.
  ///
  /// In en, this message translates to:
  /// **'Children classes'**
  String get mosque_service_children_classes;

  /// No description provided for @mosque_service_quran_classes.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an classes'**
  String get mosque_service_quran_classes;

  /// No description provided for @mosque_service_arabic_classes.
  ///
  /// In en, this message translates to:
  /// **'Arabic classes'**
  String get mosque_service_arabic_classes;

  /// No description provided for @mosque_service_eid_prayer.
  ///
  /// In en, this message translates to:
  /// **'Salat Al Eid'**
  String get mosque_service_eid_prayer;

  /// No description provided for @mosque_service_janaza.
  ///
  /// In en, this message translates to:
  /// **'Salat Al Janaza'**
  String get mosque_service_janaza;

  /// No description provided for @mosque_service_iftar_ramadan.
  ///
  /// In en, this message translates to:
  /// **'Iftar Ramadan'**
  String get mosque_service_iftar_ramadan;

  /// No description provided for @mosque_service_library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get mosque_service_library;

  /// No description provided for @mosque_service_new_muslims.
  ///
  /// In en, this message translates to:
  /// **'New Muslims support'**
  String get mosque_service_new_muslims;

  /// No description provided for @mosque_khutbah_languages.
  ///
  /// In en, this message translates to:
  /// **'Khutbah language(s)'**
  String get mosque_khutbah_languages;

  /// No description provided for @mosque_imams.
  ///
  /// In en, this message translates to:
  /// **'Imams'**
  String get mosque_imams;

  /// No description provided for @mosque_since_year.
  ///
  /// In en, this message translates to:
  /// **'Since {y}'**
  String mosque_since_year(int y);

  /// No description provided for @mosque_add_imam.
  ///
  /// In en, this message translates to:
  /// **'Add an Imam'**
  String get mosque_add_imam;

  /// No description provided for @mosque_edit_imam.
  ///
  /// In en, this message translates to:
  /// **'Edit Imam'**
  String get mosque_edit_imam;

  /// No description provided for @mosque_add_photo.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get mosque_add_photo;

  /// No description provided for @mosque_imam_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get mosque_imam_full_name;

  /// No description provided for @mosque_imam_role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get mosque_imam_role;

  /// No description provided for @mosque_imam_since.
  ///
  /// In en, this message translates to:
  /// **'At the mosque since'**
  String get mosque_imam_since;

  /// No description provided for @mosque_imam_bio.
  ///
  /// In en, this message translates to:
  /// **'Short bio'**
  String get mosque_imam_bio;

  /// No description provided for @mosque_imam_bio_hint.
  ///
  /// In en, this message translates to:
  /// **'A few words about the Imam'**
  String get mosque_imam_bio_hint;

  /// No description provided for @mosque_news_empty.
  ///
  /// In en, this message translates to:
  /// **'No news yet. Follow the mosque to be notified of its announcements.'**
  String get mosque_news_empty;

  /// No description provided for @mosque_post_urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get mosque_post_urgent;

  /// No description provided for @mosque_post_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get mosque_post_share;

  /// No description provided for @mosque_post_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get mosque_post_apply;

  /// No description provided for @mosque_post_applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get mosque_post_applied;

  /// No description provided for @mosque_post_attend_cta.
  ///
  /// In en, this message translates to:
  /// **'I\'ll attend'**
  String get mosque_post_attend_cta;

  /// No description provided for @mosque_post_attending_cta_done.
  ///
  /// In en, this message translates to:
  /// **'Attending ✓'**
  String get mosque_post_attending_cta_done;

  /// No description provided for @mosque_post_attending.
  ///
  /// In en, this message translates to:
  /// **'{n} attending'**
  String mosque_post_attending(int n);

  /// No description provided for @mosque_post_volunteers.
  ///
  /// In en, this message translates to:
  /// **'{n} volunteer(s)'**
  String mosque_post_volunteers(int n);

  /// No description provided for @mosque_post_duas.
  ///
  /// In en, this message translates to:
  /// **'{n} duas'**
  String mosque_post_duas(int n);

  /// No description provided for @mosque_post_say_dua.
  ///
  /// In en, this message translates to:
  /// **'Say a dua'**
  String get mosque_post_say_dua;

  /// No description provided for @mosque_post_dua_said.
  ///
  /// In en, this message translates to:
  /// **'Dua said ✓'**
  String get mosque_post_dua_said;

  /// No description provided for @mosque_post_after_prayer.
  ///
  /// In en, this message translates to:
  /// **'After {slot} prayer - {time}'**
  String mosque_post_after_prayer(String slot, String time);

  /// No description provided for @mosque_post_notified_all.
  ///
  /// In en, this message translates to:
  /// **'Notified all'**
  String get mosque_post_notified_all;

  /// No description provided for @mosque_dua_recite.
  ///
  /// In en, this message translates to:
  /// **'Recite this dua'**
  String get mosque_dua_recite;

  /// No description provided for @mosque_dua_translation.
  ///
  /// In en, this message translates to:
  /// **'O Allah, forgive him, have mercy on him, grant him well-being and pardon him.'**
  String get mosque_dua_translation;

  /// No description provided for @mosque_dua_done.
  ///
  /// In en, this message translates to:
  /// **'I\'m done'**
  String get mosque_dua_done;

  /// No description provided for @mosque_donations_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Donations to this mosque will be available soon.'**
  String get mosque_donations_coming_soon;

  /// No description provided for @mosque_donation_enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount manually'**
  String get mosque_donation_enter_amount;

  /// No description provided for @mosque_member_title.
  ///
  /// In en, this message translates to:
  /// **'Join our membership'**
  String get mosque_member_title;

  /// No description provided for @mosque_member_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Registering as a member helps us stay connected with you and organize our community life.'**
  String get mosque_member_subtitle;

  /// No description provided for @mosque_member_first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get mosque_member_first_name;

  /// No description provided for @mosque_member_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get mosque_member_last_name;

  /// No description provided for @mosque_member_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get mosque_member_birth_date;

  /// No description provided for @mosque_member_profession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get mosque_member_profession;

  /// No description provided for @mosque_member_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get mosque_member_phone;

  /// No description provided for @mosque_member_volunteer_question.
  ///
  /// In en, this message translates to:
  /// **'Available for volunteer projects?'**
  String get mosque_member_volunteer_question;

  /// No description provided for @mosque_member_consent.
  ///
  /// In en, this message translates to:
  /// **'I consent to the mosque using my information to contact me about volunteer and community support projects.'**
  String get mosque_member_consent;

  /// No description provided for @mosque_member_fee_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional contribution'**
  String get mosque_member_fee_optional;

  /// No description provided for @mosque_member_fee_title.
  ///
  /// In en, this message translates to:
  /// **'Support the mosque'**
  String get mosque_member_fee_title;

  /// No description provided for @mosque_member_fee_hint.
  ///
  /// In en, this message translates to:
  /// **'A recommended contribution of €120/year helps sustain the mosque. This is entirely optional, your membership is free.'**
  String get mosque_member_fee_hint;

  /// No description provided for @mosque_member_fee_choose.
  ///
  /// In en, this message translates to:
  /// **'Choose your contribution'**
  String get mosque_member_fee_choose;

  /// No description provided for @mosque_member_register.
  ///
  /// In en, this message translates to:
  /// **'Register as member'**
  String get mosque_member_register;

  /// No description provided for @mosque_member_fill_required.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields and accept the consent.'**
  String get mosque_member_fill_required;

  /// No description provided for @mosque_member_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the community!'**
  String get mosque_member_welcome;

  /// No description provided for @mosque_time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get mosque_time_just_now;

  /// No description provided for @mosque_time_min_ago.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String mosque_time_min_ago(int n);

  /// No description provided for @mosque_time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String mosque_time_hours_ago(int n);

  /// No description provided for @mosque_time_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get mosque_time_yesterday;

  /// No description provided for @mosque_time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{n} days ago'**
  String mosque_time_days_ago(int n);

  /// No description provided for @mosque_time_weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'{n} week(s) ago'**
  String mosque_time_weeks_ago(int n);

  /// No description provided for @mosque_admin_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Mosque dashboard'**
  String get mosque_admin_panel_title;

  /// No description provided for @mosque_admin_panel_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your mosque, posts and community'**
  String get mosque_admin_panel_subtitle;

  /// No description provided for @mosque_admin_attention.
  ///
  /// In en, this message translates to:
  /// **'{n} things need your attention'**
  String mosque_admin_attention(int n);

  /// No description provided for @mosque_admin_pending_events.
  ///
  /// In en, this message translates to:
  /// **'{n} pending event(s)'**
  String mosque_admin_pending_events(int n);

  /// No description provided for @mosque_admin_campaigns_ending.
  ///
  /// In en, this message translates to:
  /// **'{n} fundraising ending soon'**
  String mosque_admin_campaigns_ending(int n);

  /// No description provided for @mosque_admin_last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get mosque_admin_last_7_days;

  /// No description provided for @mosque_admin_last_30_days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get mosque_admin_last_30_days;

  /// No description provided for @mosque_admin_growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get mosque_admin_growth;

  /// No description provided for @mosque_admin_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get mosque_admin_today;

  /// No description provided for @mosque_admin_open_rate.
  ///
  /// In en, this message translates to:
  /// **'Notification open rate (30 days, estimate): {rate}%'**
  String mosque_admin_open_rate(String rate);

  /// No description provided for @mosque_admin_fundraising.
  ///
  /// In en, this message translates to:
  /// **'Fundraising'**
  String get mosque_admin_fundraising;

  /// No description provided for @mosque_campaign_days_left_short.
  ///
  /// In en, this message translates to:
  /// **'{n}d left'**
  String mosque_campaign_days_left_short(int n);

  /// No description provided for @mosque_admin_recent_posts.
  ///
  /// In en, this message translates to:
  /// **'Recent posts'**
  String get mosque_admin_recent_posts;

  /// No description provided for @mosque_admin_no_posts.
  ///
  /// In en, this message translates to:
  /// **'No post yet. Share news, events or a janaza with your community.'**
  String get mosque_admin_no_posts;

  /// No description provided for @mosque_admin_create_post.
  ///
  /// In en, this message translates to:
  /// **'Create a post'**
  String get mosque_admin_create_post;

  /// No description provided for @mosque_admin_view_mosque.
  ///
  /// In en, this message translates to:
  /// **'View public profile'**
  String get mosque_admin_view_mosque;

  /// No description provided for @mosque_admin_search_community.
  ///
  /// In en, this message translates to:
  /// **'Search name, email, phone'**
  String get mosque_admin_search_community;

  /// No description provided for @mosque_admin_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mosque_admin_filter_all;

  /// No description provided for @mosque_admin_filter_followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get mosque_admin_filter_followers;

  /// No description provided for @mosque_admin_filter_members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get mosque_admin_filter_members;

  /// No description provided for @mosque_admin_filter_volunteers.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get mosque_admin_filter_volunteers;

  /// No description provided for @mosque_admin_community_empty.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet.'**
  String get mosque_admin_community_empty;

  /// No description provided for @mosque_admin_remove_member.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get mosque_admin_remove_member;

  /// No description provided for @mosque_admin_prayer_times.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get mosque_admin_prayer_times;

  /// No description provided for @mosque_prayers_not_set_title.
  ///
  /// In en, this message translates to:
  /// **'The day\'s prayers have not yet been set.'**
  String get mosque_prayers_not_set_title;

  /// No description provided for @mosque_prayers_not_set_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter them manually or copy from another day'**
  String get mosque_prayers_not_set_hint;

  /// No description provided for @mosque_prayers_copy_from_day.
  ///
  /// In en, this message translates to:
  /// **'Copy from another day'**
  String get mosque_prayers_copy_from_day;

  /// No description provided for @mosque_prayers_copied_from.
  ///
  /// In en, this message translates to:
  /// **'Prayer times successfully copied from {date}'**
  String mosque_prayers_copied_from(String date);

  /// No description provided for @mosque_copy_title.
  ///
  /// In en, this message translates to:
  /// **'Copy prayer times'**
  String get mosque_copy_title;

  /// No description provided for @mosque_copy_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Reuse another day\'s times instead of typing them again.'**
  String get mosque_copy_subtitle;

  /// No description provided for @mosque_copy_from.
  ///
  /// In en, this message translates to:
  /// **'Copy from'**
  String get mosque_copy_from;

  /// No description provided for @mosque_copy_times.
  ///
  /// In en, this message translates to:
  /// **'Times to copy'**
  String get mosque_copy_times;

  /// No description provided for @mosque_copy_apply_to.
  ///
  /// In en, this message translates to:
  /// **'Apply to'**
  String get mosque_copy_apply_to;

  /// No description provided for @mosque_copy_this_day.
  ///
  /// In en, this message translates to:
  /// **'This day only'**
  String get mosque_copy_this_day;

  /// No description provided for @mosque_copy_date_range.
  ///
  /// In en, this message translates to:
  /// **'A date range'**
  String get mosque_copy_date_range;

  /// No description provided for @mosque_copy_from_date.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get mosque_copy_from_date;

  /// No description provided for @mosque_copy_to_date.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get mosque_copy_to_date;

  /// No description provided for @mosque_copy_overwrite_warning.
  ///
  /// In en, this message translates to:
  /// **'Days that already have times will be overwritten.'**
  String get mosque_copy_overwrite_warning;

  /// No description provided for @mosque_overrides_title.
  ///
  /// In en, this message translates to:
  /// **'Prayer\'s overrides'**
  String get mosque_overrides_title;

  /// No description provided for @mosque_overrides_shift_title.
  ///
  /// In en, this message translates to:
  /// **'Shift a prayer today'**
  String get mosque_overrides_shift_title;

  /// No description provided for @mosque_overrides_shift_hint.
  ///
  /// In en, this message translates to:
  /// **'Change one prayer\'s time for today only, without touching the permanent schedule.'**
  String get mosque_overrides_shift_hint;

  /// No description provided for @mosque_overrides_create.
  ///
  /// In en, this message translates to:
  /// **'Create an override'**
  String get mosque_overrides_create;

  /// No description provided for @mosque_overrides_applied.
  ///
  /// In en, this message translates to:
  /// **'Applied overrides'**
  String get mosque_overrides_applied;

  /// No description provided for @mosque_override_created.
  ///
  /// In en, this message translates to:
  /// **'Override applied — followers see the new time.'**
  String get mosque_override_created;

  /// No description provided for @mosque_override_new_time.
  ///
  /// In en, this message translates to:
  /// **'New time'**
  String get mosque_override_new_time;

  /// No description provided for @mosque_override_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get mosque_override_reason_hint;

  /// No description provided for @mosque_post_notify_followers.
  ///
  /// In en, this message translates to:
  /// **'Notify followers'**
  String get mosque_post_notify_followers;

  /// No description provided for @mosque_post_send_push.
  ///
  /// In en, this message translates to:
  /// **'Send push to {n} followers'**
  String mosque_post_send_push(int n);

  /// No description provided for @mosque_post_quota_left.
  ///
  /// In en, this message translates to:
  /// **'{left} of {limit} notifications left this week'**
  String mosque_post_quota_left(int left, int limit);

  /// No description provided for @mosque_post_notified.
  ///
  /// In en, this message translates to:
  /// **'Notification sent to {n} followers'**
  String mosque_post_notified(int n);

  /// No description provided for @mosque_post_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get mosque_post_archive;

  /// No description provided for @mosque_post_published.
  ///
  /// In en, this message translates to:
  /// **'Post published'**
  String get mosque_post_published;

  /// No description provided for @mosque_post_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mosque_post_title_hint;

  /// No description provided for @mosque_post_title_label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mosque_post_title_label;

  /// No description provided for @mosque_post_body_hint.
  ///
  /// In en, this message translates to:
  /// **'Start writing'**
  String get mosque_post_body_hint;

  /// No description provided for @mosque_post_add_to_post.
  ///
  /// In en, this message translates to:
  /// **'Add to your post'**
  String get mosque_post_add_to_post;

  /// No description provided for @mosque_post_choose_category.
  ///
  /// In en, this message translates to:
  /// **'Or choose a category'**
  String get mosque_post_choose_category;

  /// No description provided for @mosque_post_audience_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get mosque_post_audience_public;

  /// No description provided for @mosque_post_audience_followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get mosque_post_audience_followers;

  /// No description provided for @mosque_post_form_event.
  ///
  /// In en, this message translates to:
  /// **'Post an event'**
  String get mosque_post_form_event;

  /// No description provided for @mosque_post_form_volunteering.
  ///
  /// In en, this message translates to:
  /// **'Recruit volunteers'**
  String get mosque_post_form_volunteering;

  /// No description provided for @mosque_post_form_highlight.
  ///
  /// In en, this message translates to:
  /// **'Share a highlight'**
  String get mosque_post_form_highlight;

  /// No description provided for @mosque_post_form_janaza.
  ///
  /// In en, this message translates to:
  /// **'Announce a janaza'**
  String get mosque_post_form_janaza;

  /// No description provided for @mosque_post_cover_photo.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get mosque_post_cover_photo;

  /// No description provided for @mosque_post_add_cover.
  ///
  /// In en, this message translates to:
  /// **'Add cover photo'**
  String get mosque_post_add_cover;

  /// No description provided for @mosque_post_cover_required.
  ///
  /// In en, this message translates to:
  /// **'A photo is required for a highlight.'**
  String get mosque_post_cover_required;

  /// No description provided for @mosque_post_event_name.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get mosque_post_event_name;

  /// No description provided for @mosque_post_janaza_name.
  ///
  /// In en, this message translates to:
  /// **'Name of the deceased'**
  String get mosque_post_janaza_name;

  /// No description provided for @mosque_post_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mosque_post_description;

  /// No description provided for @mosque_post_description_hint.
  ///
  /// In en, this message translates to:
  /// **'What is this event about..'**
  String get mosque_post_description_hint;

  /// No description provided for @mosque_post_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get mosque_post_date;

  /// No description provided for @mosque_post_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get mosque_post_time;

  /// No description provided for @mosque_post_date_required.
  ///
  /// In en, this message translates to:
  /// **'Please choose a date.'**
  String get mosque_post_date_required;

  /// No description provided for @mosque_post_after_prayer_label.
  ///
  /// In en, this message translates to:
  /// **'After which prayer?'**
  String get mosque_post_after_prayer_label;

  /// No description provided for @mosque_post_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get mosque_post_location;

  /// No description provided for @mosque_post_location_default.
  ///
  /// In en, this message translates to:
  /// **'At the mosque'**
  String get mosque_post_location_default;

  /// No description provided for @mosque_post_volunteers_needed.
  ///
  /// In en, this message translates to:
  /// **'Volunteers needed'**
  String get mosque_post_volunteers_needed;

  /// No description provided for @mosque_post_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get mosque_post_language;

  /// No description provided for @mosque_post_mark_urgent.
  ///
  /// In en, this message translates to:
  /// **'Mark as urgent'**
  String get mosque_post_mark_urgent;

  /// No description provided for @mosque_post_mark_urgent_hint.
  ///
  /// In en, this message translates to:
  /// **'Post appears at top with urgent badge'**
  String get mosque_post_mark_urgent_hint;

  /// No description provided for @mosque_admin_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit mosque profile'**
  String get mosque_admin_edit_profile;

  /// No description provided for @mosque_admin_profile_saved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get mosque_admin_profile_saved;

  /// No description provided for @mosque_admin_cover_images.
  ///
  /// In en, this message translates to:
  /// **'Cover images'**
  String get mosque_admin_cover_images;

  /// No description provided for @mosque_admin_tap_to_change_logo.
  ///
  /// In en, this message translates to:
  /// **'Tap the logo to change it'**
  String get mosque_admin_tap_to_change_logo;

  /// No description provided for @mosque_admin_field_name.
  ///
  /// In en, this message translates to:
  /// **'Mosque name'**
  String get mosque_admin_field_name;

  /// No description provided for @mosque_admin_field_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mosque_admin_field_description;

  /// No description provided for @mosque_admin_field_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get mosque_admin_field_address;

  /// No description provided for @mosque_admin_field_postal.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get mosque_admin_field_postal;

  /// No description provided for @mosque_admin_field_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get mosque_admin_field_city;

  /// No description provided for @mosque_admin_field_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get mosque_admin_field_phone;

  /// No description provided for @mosque_admin_field_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get mosque_admin_field_website;

  /// No description provided for @mosque_admin_opening_status.
  ///
  /// In en, this message translates to:
  /// **'Opening status'**
  String get mosque_admin_opening_status;

  /// No description provided for @mosque_admin_opening_auto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get mosque_admin_opening_auto;

  /// No description provided for @mosque_admin_no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No notification yet.'**
  String get mosque_admin_no_notifications;

  /// No description provided for @error_api_mosque_campaign_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'You already have 3 active campaigns. Close one first.'**
  String get error_api_mosque_campaign_limit_reached;

  /// No description provided for @error_api_mosque_campaign_closed.
  ///
  /// In en, this message translates to:
  /// **'This campaign is closed.'**
  String get error_api_mosque_campaign_closed;

  /// No description provided for @error_api_mosque_donations_disabled.
  ///
  /// In en, this message translates to:
  /// **'This mosque can\'t receive donations yet.'**
  String get error_api_mosque_donations_disabled;

  /// No description provided for @error_api_mosque_receipts_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'This mosque doesn\'t issue tax receipts.'**
  String get error_api_mosque_receipts_not_allowed;

  /// No description provided for @error_api_mosque_receipt_no_donations.
  ///
  /// In en, this message translates to:
  /// **'No eligible donation found for this receipt.'**
  String get error_api_mosque_receipt_no_donations;

  /// No description provided for @error_api_mosque_receipt_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate the receipt.'**
  String get error_api_mosque_receipt_failed;

  /// No description provided for @error_api_mosque_stripe_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Stripe. Please try again.'**
  String get error_api_mosque_stripe_failed;

  /// No description provided for @my_donations_tab_mosques.
  ///
  /// In en, this message translates to:
  /// **'Mosques'**
  String get my_donations_tab_mosques;

  /// No description provided for @my_donations_empty_mosques.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t supported a mosque yet. Find one near you and give.'**
  String get my_donations_empty_mosques;

  /// No description provided for @mosque_donation_other_amount.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get mosque_donation_other_amount;

  /// No description provided for @mosque_donation_custom_amount_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get mosque_donation_custom_amount_hint;

  /// No description provided for @mosque_donation_give.
  ///
  /// In en, this message translates to:
  /// **'Give {amount}'**
  String mosque_donation_give(String amount);

  /// No description provided for @mosque_donation_give_monthly.
  ///
  /// In en, this message translates to:
  /// **'Give {amount} / month'**
  String mosque_donation_give_monthly(String amount);

  /// No description provided for @mosque_donation_give_yearly.
  ///
  /// In en, this message translates to:
  /// **'Give {amount} / year'**
  String mosque_donation_give_yearly(String amount);

  /// No description provided for @mosque_donation_secure_note.
  ///
  /// In en, this message translates to:
  /// **'Secure payment. 100% goes to the mosque — Nour takes no fee.'**
  String get mosque_donation_secure_note;

  /// No description provided for @mosque_donation_tax_badge.
  ///
  /// In en, this message translates to:
  /// **'Tax receipt'**
  String get mosque_donation_tax_badge;

  /// No description provided for @mosque_donation_active_monthly.
  ///
  /// In en, this message translates to:
  /// **'You give {amount} every month. Jazakallah khair.'**
  String mosque_donation_active_monthly(String amount);

  /// No description provided for @mosque_donation_active_yearly.
  ///
  /// In en, this message translates to:
  /// **'You give {amount} every year. Jazakallah khair.'**
  String mosque_donation_active_yearly(String amount);

  /// No description provided for @mosque_donation_cancel_recurring_title.
  ///
  /// In en, this message translates to:
  /// **'Stop your recurring gift?'**
  String get mosque_donation_cancel_recurring_title;

  /// No description provided for @mosque_donation_cancel_recurring_message.
  ///
  /// In en, this message translates to:
  /// **'You will keep the current period; no further charge will be made.'**
  String get mosque_donation_cancel_recurring_message;

  /// No description provided for @mosque_donation_recurring_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Your recurring gift has been stopped.'**
  String get mosque_donation_recurring_cancelled;

  /// No description provided for @mosque_donor_anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get mosque_donor_anonymous;

  /// No description provided for @mosque_campaigns_title.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get mosque_campaigns_title;

  /// No description provided for @mosque_campaigns_past_title.
  ///
  /// In en, this message translates to:
  /// **'Past campaigns'**
  String get mosque_campaigns_past_title;

  /// No description provided for @mosque_campaign_title.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get mosque_campaign_title;

  /// No description provided for @mosque_campaign_of_goal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String mosque_campaign_of_goal(String goal);

  /// No description provided for @mosque_campaign_donors_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No donor yet} =1{1 donor} other{{count} donors}}'**
  String mosque_campaign_donors_count(int count);

  /// No description provided for @mosque_campaign_days_left.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Ends today} =1{1 day left} other{{days} days left}}'**
  String mosque_campaign_days_left(int days);

  /// No description provided for @mosque_campaign_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mosque_campaign_closed;

  /// No description provided for @mosque_campaign_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get mosque_campaign_active;

  /// No description provided for @mosque_campaign_ending_soon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get mosque_campaign_ending_soon;

  /// No description provided for @mosque_campaign_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get mosque_campaign_remaining;

  /// No description provided for @mosque_campaign_contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get mosque_campaign_contribute;

  /// No description provided for @mosque_campaign_recent_donors.
  ///
  /// In en, this message translates to:
  /// **'Recent donors'**
  String get mosque_campaign_recent_donors;

  /// No description provided for @mosque_campaign_updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get mosque_campaign_updates;

  /// No description provided for @mosque_campaign_updates_empty.
  ///
  /// In en, this message translates to:
  /// **'No update posted yet.'**
  String get mosque_campaign_updates_empty;

  /// No description provided for @mosque_campaign_funded_note.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah, the goal has been reached. Thank you to everyone who contributed.'**
  String get mosque_campaign_funded_note;

  /// No description provided for @mosque_campaign_ended_note.
  ///
  /// In en, this message translates to:
  /// **'This campaign has ended. You can still support the mosque from its Donation tab.'**
  String get mosque_campaign_ended_note;

  /// No description provided for @mosque_checkout_sadaqa.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa to the mosque'**
  String get mosque_checkout_sadaqa;

  /// No description provided for @mosque_checkout_campaign_gift.
  ///
  /// In en, this message translates to:
  /// **'Campaign contribution'**
  String get mosque_checkout_campaign_gift;

  /// No description provided for @mosque_checkout_membership_fee.
  ///
  /// In en, this message translates to:
  /// **'Yearly membership contribution'**
  String get mosque_checkout_membership_fee;

  /// No description provided for @mosque_checkout_direct_note.
  ///
  /// In en, this message translates to:
  /// **'Paid directly to {mosque} via Stripe. Nour takes no fee.'**
  String mosque_checkout_direct_note(String mosque);

  /// No description provided for @mosque_checkout_success_title.
  ///
  /// In en, this message translates to:
  /// **'Jazakallah khair'**
  String get mosque_checkout_success_title;

  /// No description provided for @mosque_checkout_success_message.
  ///
  /// In en, this message translates to:
  /// **'Your gift of {amount} to {mosque} has been received.'**
  String mosque_checkout_success_message(String amount, String mosque);

  /// No description provided for @mosque_checkout_success_membership.
  ///
  /// In en, this message translates to:
  /// **'Your contribution of {amount} to {mosque} is confirmed. Welcome to the community.'**
  String mosque_checkout_success_membership(String amount, String mosque);

  /// No description provided for @mosque_receipts_empty.
  ///
  /// In en, this message translates to:
  /// **'No receipt yet.'**
  String get mosque_receipts_empty;

  /// No description provided for @mosque_receipt_single.
  ///
  /// In en, this message translates to:
  /// **'Single gift'**
  String get mosque_receipt_single;

  /// No description provided for @mosque_receipt_yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly summary {year}'**
  String mosque_receipt_yearly(int year);

  /// No description provided for @mosque_admin_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get mosque_admin_manage;

  /// No description provided for @mosque_admin_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get mosque_admin_preview;

  /// No description provided for @mosque_admin_stat_support.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa & memberships'**
  String get mosque_admin_stat_support;

  /// No description provided for @mosque_admin_stat_support_hint.
  ///
  /// In en, this message translates to:
  /// **'Ongoing support'**
  String get mosque_admin_stat_support_hint;

  /// No description provided for @mosque_admin_stat_campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get mosque_admin_stat_campaigns;

  /// No description provided for @mosque_donation_card_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get mosque_donation_card_support;

  /// No description provided for @mosque_donation_card_growth.
  ///
  /// In en, this message translates to:
  /// **'{growth} vs {year}'**
  String mosque_donation_card_growth(String growth, String year);

  /// No description provided for @mosque_admin_sadaqa_title.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa card'**
  String get mosque_admin_sadaqa_title;

  /// No description provided for @mosque_admin_sadaqa_month_summary.
  ///
  /// In en, this message translates to:
  /// **'{gifts} gifts this month ({amount}) · {monthly} monthly donors'**
  String mosque_admin_sadaqa_month_summary(
    int gifts,
    String amount,
    int monthly,
  );

  /// No description provided for @mosque_admin_sadaqa_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa settings'**
  String get mosque_admin_sadaqa_settings_title;

  /// No description provided for @mosque_admin_sadaqa_card_title.
  ///
  /// In en, this message translates to:
  /// **'Card title'**
  String get mosque_admin_sadaqa_card_title;

  /// No description provided for @mosque_admin_sadaqa_card_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Support the mosque'**
  String get mosque_admin_sadaqa_card_title_hint;

  /// No description provided for @mosque_admin_sadaqa_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell donors what their support funds…'**
  String get mosque_admin_sadaqa_description_hint;

  /// No description provided for @mosque_admin_sadaqa_amounts.
  ///
  /// In en, this message translates to:
  /// **'Suggested amounts'**
  String get mosque_admin_sadaqa_amounts;

  /// No description provided for @mosque_admin_sadaqa_amounts_hint.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated, up to 6 amounts. Donors can always enter another amount.'**
  String get mosque_admin_sadaqa_amounts_hint;

  /// No description provided for @mosque_admin_sadaqa_frequencies.
  ///
  /// In en, this message translates to:
  /// **'Allowed frequencies'**
  String get mosque_admin_sadaqa_frequencies;

  /// No description provided for @mosque_admin_sadaqa_frequency_required.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one frequency enabled.'**
  String get mosque_admin_sadaqa_frequency_required;

  /// No description provided for @mosque_admin_sadaqa_invalid.
  ///
  /// In en, this message translates to:
  /// **'Add a title and at least one amount.'**
  String get mosque_admin_sadaqa_invalid;

  /// No description provided for @mosque_admin_sadaqa_tax_badge.
  ///
  /// In en, this message translates to:
  /// **'Show \"Tax receipt\" badge'**
  String get mosque_admin_sadaqa_tax_badge;

  /// No description provided for @mosque_admin_sadaqa_tax_badge_hint.
  ///
  /// In en, this message translates to:
  /// **'Donors will see that their gift is tax-deductible.'**
  String get mosque_admin_sadaqa_tax_badge_hint;

  /// No description provided for @mosque_admin_sadaqa_tax_badge_locked.
  ///
  /// In en, this message translates to:
  /// **'Enable tax receipts in the Stripe setup first.'**
  String get mosque_admin_sadaqa_tax_badge_locked;

  /// No description provided for @mosque_admin_membership_fee_amounts.
  ///
  /// In en, this message translates to:
  /// **'Membership contribution amounts (yearly)'**
  String get mosque_admin_membership_fee_amounts;

  /// No description provided for @mosque_admin_membership_fee_amounts_hint.
  ///
  /// In en, this message translates to:
  /// **'Shown when a worshipper joins as a member. The second amount is recommended.'**
  String get mosque_admin_membership_fee_amounts_hint;

  /// No description provided for @mosque_admin_stripe_title.
  ///
  /// In en, this message translates to:
  /// **'Payments (Stripe)'**
  String get mosque_admin_stripe_title;

  /// No description provided for @mosque_admin_stripe_active.
  ///
  /// In en, this message translates to:
  /// **'Donations enabled · payouts go straight to your bank account'**
  String get mosque_admin_stripe_active;

  /// No description provided for @mosque_admin_stripe_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Receive donations'**
  String get mosque_admin_stripe_setup_title;

  /// No description provided for @mosque_admin_stripe_setup_message.
  ///
  /// In en, this message translates to:
  /// **'Connect a Stripe account to receive Sadaqa, campaign gifts and membership contributions directly. Takes about 5 minutes.'**
  String get mosque_admin_stripe_setup_message;

  /// No description provided for @mosque_admin_stripe_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get mosque_admin_stripe_pending_title;

  /// No description provided for @mosque_admin_stripe_pending_message.
  ///
  /// In en, this message translates to:
  /// **'Stripe still needs some information before donations can be enabled.'**
  String get mosque_admin_stripe_pending_message;

  /// No description provided for @mosque_admin_stripe_start.
  ///
  /// In en, this message translates to:
  /// **'Set up payments'**
  String get mosque_admin_stripe_start;

  /// No description provided for @mosque_admin_stripe_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue setup'**
  String get mosque_admin_stripe_continue;

  /// No description provided for @mosque_admin_stripe_update_info.
  ///
  /// In en, this message translates to:
  /// **'Update information'**
  String get mosque_admin_stripe_update_info;

  /// No description provided for @mosque_admin_stripe_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Stripe dashboard'**
  String get mosque_admin_stripe_dashboard;

  /// No description provided for @mosque_admin_stripe_explainer.
  ///
  /// In en, this message translates to:
  /// **'Donations are charged directly on your mosque\'s Stripe account — Nour never holds the funds and takes no commission. Stripe\'s standard processing fees apply.'**
  String get mosque_admin_stripe_explainer;

  /// No description provided for @mosque_admin_stripe_tax_receipts.
  ///
  /// In en, this message translates to:
  /// **'Our association can issue tax receipts'**
  String get mosque_admin_stripe_tax_receipts;

  /// No description provided for @mosque_admin_stripe_tax_receipts_hint.
  ///
  /// In en, this message translates to:
  /// **'Enables receipt generation (CERFA-style) for donors.'**
  String get mosque_admin_stripe_tax_receipts_hint;

  /// No description provided for @mosque_admin_stripe_charges.
  ///
  /// In en, this message translates to:
  /// **'Can receive payments'**
  String get mosque_admin_stripe_charges;

  /// No description provided for @mosque_admin_stripe_payouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts enabled'**
  String get mosque_admin_stripe_payouts;

  /// No description provided for @mosque_admin_stripe_details.
  ///
  /// In en, this message translates to:
  /// **'Information submitted'**
  String get mosque_admin_stripe_details;

  /// No description provided for @mosque_admin_stripe_requirements.
  ///
  /// In en, this message translates to:
  /// **'Still required by Stripe'**
  String get mosque_admin_stripe_requirements;

  /// No description provided for @mosque_admin_stripe_status_enabled.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get mosque_admin_stripe_status_enabled;

  /// No description provided for @mosque_admin_stripe_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get mosque_admin_stripe_status_pending;

  /// No description provided for @mosque_admin_stripe_status_restricted.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get mosque_admin_stripe_status_restricted;

  /// No description provided for @mosque_admin_stripe_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Stripe'**
  String get mosque_admin_stripe_status_rejected;

  /// No description provided for @mosque_admin_stripe_status_not_started.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get mosque_admin_stripe_status_not_started;

  /// No description provided for @mosque_admin_campaign_new.
  ///
  /// In en, this message translates to:
  /// **'New campaign'**
  String get mosque_admin_campaign_new;

  /// No description provided for @mosque_admin_campaign_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit campaign'**
  String get mosque_admin_campaign_edit;

  /// No description provided for @mosque_admin_campaign_launch.
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get mosque_admin_campaign_launch;

  /// No description provided for @mosque_admin_campaign_title_label.
  ///
  /// In en, this message translates to:
  /// **'Campaign title'**
  String get mosque_admin_campaign_title_label;

  /// No description provided for @mosque_admin_campaign_title_hint.
  ///
  /// In en, this message translates to:
  /// **'New ablution room'**
  String get mosque_admin_campaign_title_hint;

  /// No description provided for @mosque_admin_campaign_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Explain the project, the budget and the timeline…'**
  String get mosque_admin_campaign_description_hint;

  /// No description provided for @mosque_admin_campaign_goal.
  ///
  /// In en, this message translates to:
  /// **'Goal (€)'**
  String get mosque_admin_campaign_goal;

  /// No description provided for @mosque_admin_campaign_ends.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get mosque_admin_campaign_ends;

  /// No description provided for @mosque_admin_campaign_notify.
  ///
  /// In en, this message translates to:
  /// **'Notify followers'**
  String get mosque_admin_campaign_notify;

  /// No description provided for @mosque_admin_campaign_notify_hint.
  ///
  /// In en, this message translates to:
  /// **'Sends a push to your followers (counts in the weekly quota).'**
  String get mosque_admin_campaign_notify_hint;

  /// No description provided for @mosque_admin_campaign_notify_update.
  ///
  /// In en, this message translates to:
  /// **'Also notify followers'**
  String get mosque_admin_campaign_notify_update;

  /// No description provided for @mosque_admin_campaign_limit_note.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 active campaigns at a time. Donors are reminded 48h before the end.'**
  String get mosque_admin_campaign_limit_note;

  /// No description provided for @mosque_admin_campaign_invalid.
  ///
  /// In en, this message translates to:
  /// **'Add a title, a goal and a future end date.'**
  String get mosque_admin_campaign_invalid;

  /// No description provided for @mosque_admin_campaign_created.
  ///
  /// In en, this message translates to:
  /// **'Campaign launched'**
  String get mosque_admin_campaign_created;

  /// No description provided for @mosque_admin_campaigns_empty.
  ///
  /// In en, this message translates to:
  /// **'No campaign yet. Launch one to fund a project with your community.'**
  String get mosque_admin_campaigns_empty;

  /// No description provided for @mosque_admin_campaign_post_update.
  ///
  /// In en, this message translates to:
  /// **'Post an update'**
  String get mosque_admin_campaign_post_update;

  /// No description provided for @mosque_admin_campaign_update_hint.
  ///
  /// In en, this message translates to:
  /// **'Share progress with your donors…'**
  String get mosque_admin_campaign_update_hint;

  /// No description provided for @mosque_admin_campaign_update_posted.
  ///
  /// In en, this message translates to:
  /// **'Update posted'**
  String get mosque_admin_campaign_update_posted;

  /// No description provided for @mosque_admin_campaign_extend.
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get mosque_admin_campaign_extend;

  /// No description provided for @mosque_admin_campaign_extended.
  ///
  /// In en, this message translates to:
  /// **'Campaign extended'**
  String get mosque_admin_campaign_extended;

  /// No description provided for @mosque_admin_campaign_reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen with a new end date'**
  String get mosque_admin_campaign_reopen;

  /// No description provided for @mosque_admin_campaign_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mosque_admin_campaign_close;

  /// No description provided for @mosque_admin_campaign_close_title.
  ///
  /// In en, this message translates to:
  /// **'Close this campaign?'**
  String get mosque_admin_campaign_close_title;

  /// No description provided for @mosque_admin_campaign_close_message.
  ///
  /// In en, this message translates to:
  /// **'Donors won\'t be able to contribute anymore. You can reopen it later.'**
  String get mosque_admin_campaign_close_message;

  /// No description provided for @mosque_admin_campaign_closed.
  ///
  /// In en, this message translates to:
  /// **'Campaign closed'**
  String get mosque_admin_campaign_closed;

  /// No description provided for @mosque_admin_campaign_closed_note.
  ///
  /// In en, this message translates to:
  /// **'This campaign is closed {date}.'**
  String mosque_admin_campaign_closed_note(String date);

  /// No description provided for @mosque_admin_donors_list.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get mosque_admin_donors_list;

  /// No description provided for @mosque_admin_donors_empty.
  ///
  /// In en, this message translates to:
  /// **'No donation for this period.'**
  String get mosque_admin_donors_empty;

  /// No description provided for @mosque_admin_type_sadaqa.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa'**
  String get mosque_admin_type_sadaqa;

  /// No description provided for @mosque_admin_type_campaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get mosque_admin_type_campaign;

  /// No description provided for @mosque_admin_type_membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get mosque_admin_type_membership;

  /// No description provided for @mosque_admin_receipts.
  ///
  /// In en, this message translates to:
  /// **'Tax receipts'**
  String get mosque_admin_receipts;

  /// No description provided for @mosque_admin_receipt_issue.
  ///
  /// In en, this message translates to:
  /// **'Issue receipt'**
  String get mosque_admin_receipt_issue;

  /// No description provided for @mosque_admin_receipt_view.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get mosque_admin_receipt_view;

  /// No description provided for @mosque_admin_receipt_generated.
  ///
  /// In en, this message translates to:
  /// **'Receipt ready'**
  String get mosque_admin_receipt_generated;

  /// No description provided for @mosque_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Mosque settings'**
  String get mosque_settings_title;

  /// No description provided for @mosque_settings_logo_remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove mosque logo?'**
  String get mosque_settings_logo_remove_title;

  /// No description provided for @mosque_settings_logo_remove_message.
  ///
  /// In en, this message translates to:
  /// **'Your mosque will show its initials until you add a new logo.'**
  String get mosque_settings_logo_remove_message;

  /// No description provided for @mosque_settings_legal_section.
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get mosque_settings_legal_section;

  /// No description provided for @mosque_settings_legal_missing.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get mosque_settings_legal_missing;

  /// No description provided for @mosque_reminders_no_times_hint.
  ///
  /// In en, this message translates to:
  /// **'Your reminders use the prayer times you publish. Set your mosque\'s schedule to start receiving them.'**
  String get mosque_reminders_no_times_hint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'fr',
    'id',
    'ms',
    'nl',
    'ru',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ms':
      return AppLocalizationsMs();
    case 'nl':
      return AppLocalizationsNl();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
