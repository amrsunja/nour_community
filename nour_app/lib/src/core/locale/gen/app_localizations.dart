import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('fr'),
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

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get auth_password_hint;

  /// No description provided for @auth_or_sign_up_with.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
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

  /// No description provided for @auth_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get auth_password_too_short;

  /// No description provided for @auth_link_success.
  ///
  /// In en, this message translates to:
  /// **'Your account is connected'**
  String get auth_link_success;

  /// No description provided for @l10nStopLineDontTouch.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nStopLineDontTouch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
