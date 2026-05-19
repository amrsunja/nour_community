abstract class SQLiteConfig {
  static const String settingsTableName = 'settings';

  // Settings table rows
  static String languageCodeKey = 'language_code';
  static String countryCodeKey = 'country_code';
  static String themeModeKey = 'theme_mode';

  // Local notification toggles (0 / 1).
  static String notifPrayersKey = 'notif_prayers';
  static String notifMorningAdhkarKey = 'notif_morning_adhkar';
  static String notifEveningAdhkarKey = 'notif_evening_adhkar';
  static String notifDailyAyahKey = 'notif_daily_ayah';
}
