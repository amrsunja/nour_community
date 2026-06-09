/// Centralised catalogue of Firebase Analytics **parameter keys**.
///
/// Rules (Firebase): snake_case, <= 40 chars; String values <= 100 chars.
/// Never put PII here (no name, email, phone, free-text the user typed).
abstract class AnalyticsParams {
  AnalyticsParams._();

  // Generic
  static const screen = 'screen';
  static const buttonId = 'button_id';
  static const feature = 'feature';
  static const source = 'source';
  static const method = 'method';
  static const enabled = 'enabled';

  // Onboarding
  static const pageIndex = 'page_index';

  // Daily actions
  static const period = 'period'; // morning | evening | daily
  static const surah = 'surah';
  static const ayah = 'ayah';

  // Quiz
  static const score = 'score';
  static const total = 'total';
  static const correctRatio = 'correct_ratio';

  // Dhikr
  static const dhikrId = 'dhikr_id';
  static const dhikrPhrase = 'dhikr_phrase'; // transliteration, not arabic
  static const count = 'count';
  static const cycles = 'cycles';

  // Notifications
  static const prayer = 'prayer'; // fajr | dhuhr | asr | maghrib | isha | all

  // Settings
  static const settingKey = 'setting_key';
  static const settingValue = 'setting_value';
}
