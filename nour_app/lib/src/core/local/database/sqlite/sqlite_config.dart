abstract class SQLiteConfig {
  static const String settingsTableName = 'settings';

  // Settings table rows
  static const String languageCodeKey = 'language_code';
  static const String countryCodeKey = 'country_code';
  static const String themeModeKey = 'theme_mode';
  static const String favoriteReciterKey = 'favorite_reciter';

  // Local notification toggles (0 / 1).
  // Legacy single prayers flag — superseded by the per-prayer columns below.
  // Kept only so historical (v1 → v2) migrations still reference a valid name.
  static const String notifPrayersKey = 'notif_prayers';
  // Per-prayer toggles — each prayer has its own scheduled notification.
  static const String notifPrayerFajrKey = 'notif_prayer_fajr';
  static const String notifPrayerDhuhrKey = 'notif_prayer_dhuhr';
  static const String notifPrayerAsrKey = 'notif_prayer_asr';
  static const String notifPrayerMaghribKey = 'notif_prayer_maghrib';
  static const String notifPrayerIshaKey = 'notif_prayer_isha';
  static const String notifMorningAdhkarKey = 'notif_morning_adhkar';
  static const String notifEveningAdhkarKey = 'notif_evening_adhkar';
  static const String notifDailyAyahKey = 'notif_daily_ayah';

  // Prayer-times preferences serialized as a JSON string
  // (calculation method only; per-prayer notifications now live in their
  // own columns above and are owned by the notifications feature).
  static const String prayerSettingsKey = 'prayer_settings';
}
