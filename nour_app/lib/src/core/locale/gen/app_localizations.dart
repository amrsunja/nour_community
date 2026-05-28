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

  /// No description provided for @profile_favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get profile_favourites;

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
