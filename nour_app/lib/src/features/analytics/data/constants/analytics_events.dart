/// Centralised catalogue of Firebase Analytics **event names**.
///
/// Rules (Firebase): snake_case, <= 40 chars, start with a letter, only
/// `[a-z0-9_]`. Keep names stable — renaming an event splits its history in
/// the console. Reserved names (`screen_view`, `login`, etc.) are emitted
/// through the dedicated SDK helpers, not [AnalyticsEvents].
abstract class AnalyticsEvents {
  AnalyticsEvents._();

  // ── Navigation / generic ────────────────────────────────────────────────
  /// A primary feature surface was opened (tool, library, calculator…).
  static const featureOpen = 'feature_open';

  /// A tracked button/CTA was tapped (carries `button_id` + `screen`).
  static const buttonClick = 'button_click';

  // ── Onboarding ──────────────────────────────────────────────────────────
  static const onboardingPageView = 'onboarding_page_view';
  static const onboardingComplete = 'onboarding_complete';

  // ── Auth ────────────────────────────────────────────────────────────────
  /// Tap on a "sign in / connect" CTA (intent, before the SDK `login`).
  static const signInClick = 'sign_in_click';
  static const logout = 'logout';

  // ── Daily quick actions ─────────────────────────────────────────────────
  static const dailyVerseView = 'daily_verse_view';
  static const dailyVerseListen = 'daily_verse_listen';
  static const dailyDuaRecite = 'daily_dua_recite';
  static const quizStart = 'quiz_start';
  static const quizComplete = 'quiz_complete';

  // ── Dhikr / Tasbih ──────────────────────────────────────────────────────
  static const dhikrIncrement = 'dhikr_increment';
  static const dhikrCycleComplete = 'dhikr_cycle_complete';
  static const dhikrPhraseSelected = 'dhikr_phrase_selected';

  // ── Notifications (custom: Adhan) ───────────────────────────────────────
  static const adhanNotificationToggle = 'adhan_notification_toggle';
  static const adhkarNotificationToggle = 'adhkar_notification_toggle';
  static const dailyAyahNotificationToggle = 'daily_ayah_notif_toggle';

  // ── Settings ────────────────────────────────────────────────────────────
  static const settingsOpen = 'settings_open';
  static const settingChanged = 'setting_changed';
}
