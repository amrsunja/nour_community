import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'constants/analytics_events.dart';
import 'constants/analytics_params.dart';
import 'datasources/analytics_remote_datasource.dart';

final analyticsRepoProvider = Provider(
  (ref) => AnalyticsRepo(
    remoteDatasource: ref.read(analyticsRemoteDataProvider),
  ),
);

/// Semantic analytics API for the whole app.
///
/// Presenters and widgets depend on this (`ref.read(analyticsRepoProvider)`)
/// and call intent-named methods — they never touch event-name strings or the
/// Firebase SDK directly. All methods are fire-and-forget (`unawaited`-safe).
class AnalyticsRepo {
  AnalyticsRepo({required this.remoteDatasource});

  final AnalyticsRemoteDatasource remoteDatasource;

  // ── Lifecycle / identity ────────────────────────────────────────────────
  Future<void> setEnabled(bool enabled) =>
      remoteDatasource.setCollectionEnabled(enabled);

  Future<void> identifyUser({required String? userId, bool? isAnonymous}) async {
    await remoteDatasource.setUserId(userId);
    if (isAnonymous != null) {
      await remoteDatasource.setUserProperty(
        name: 'account_type',
        value: isAnonymous ? 'anonymous' : 'connected',
      );
    }
  }

  // ── Screens / navigation ────────────────────────────────────────────────
  Future<void> trackScreen(String screenName) =>
      remoteDatasource.logScreenView(screenName: screenName);

  Future<void> trackFeatureOpen(String feature, {String? source}) =>
      remoteDatasource.logEvent(AnalyticsEvents.featureOpen, {
        AnalyticsParams.feature: feature,
        AnalyticsParams.source: source,
      });

  Future<void> trackButtonClick(String buttonId, {String? screen}) =>
      remoteDatasource.logEvent(AnalyticsEvents.buttonClick, {
        AnalyticsParams.buttonId: buttonId,
        AnalyticsParams.screen: screen,
      });

  // ── Onboarding ──────────────────────────────────────────────────────────
  Future<void> trackOnboardingPage(int pageIndex) =>
      remoteDatasource.logEvent(AnalyticsEvents.onboardingPageView, {
        AnalyticsParams.pageIndex: pageIndex,
      });

  Future<void> trackOnboardingComplete() =>
      remoteDatasource.logEvent(AnalyticsEvents.onboardingComplete);

  // ── Auth ────────────────────────────────────────────────────────────────
  Future<void> trackSignInClick({String method = 'unknown'}) =>
      remoteDatasource.logEvent(AnalyticsEvents.signInClick, {
        AnalyticsParams.method: method,
      });

  Future<void> trackLogin({String? method}) =>
      remoteDatasource.logLogin(method: method);

  Future<void> trackLogout({String method = 'manual'}) =>
      remoteDatasource.logEvent(AnalyticsEvents.logout, {
        AnalyticsParams.method: method,
      });

  // ── Daily quick actions ─────────────────────────────────────────────────
  Future<void> trackDailyVerseView({String source = 'dashboard'}) =>
      remoteDatasource.logEvent(AnalyticsEvents.dailyVerseView, {
        AnalyticsParams.source: source,
      });

  Future<void> trackDailyVerseListen({int? surah, int? ayah}) =>
      remoteDatasource.logEvent(AnalyticsEvents.dailyVerseListen, {
        AnalyticsParams.surah: surah,
        AnalyticsParams.ayah: ayah,
      });

  /// [period] = `morning` | `evening` | `daily`.
  Future<void> trackDailyDuaRecite({required String period}) =>
      remoteDatasource.logEvent(AnalyticsEvents.dailyDuaRecite, {
        AnalyticsParams.period: period,
      });

  Future<void> trackQuizStart() =>
      remoteDatasource.logEvent(AnalyticsEvents.quizStart);

  Future<void> trackQuizComplete({required int score, required int total}) =>
      remoteDatasource.logEvent(AnalyticsEvents.quizComplete, {
        AnalyticsParams.score: score,
        AnalyticsParams.total: total,
        AnalyticsParams.correctRatio:
            total > 0 ? (score / total).toStringAsFixed(2) : '0',
      });

  // ── Dhikr / Tasbih ──────────────────────────────────────────────────────
  Future<void> trackDhikrIncrement({
    required int dhikrId,
    String? phrase,
    int? count,
  }) async {
    return ;
    /*
    return remoteDatasource.logEvent(AnalyticsEvents.dhikrIncrement, {
        AnalyticsParams.dhikrId: dhikrId,
        AnalyticsParams.dhikrPhrase: phrase,
        AnalyticsParams.count: count,
      });
    */
  }

  Future<void> trackDhikrCycleComplete({
    required int dhikrId,
    String? phrase,
    required int cycles,
  }) =>
      remoteDatasource.logEvent(AnalyticsEvents.dhikrCycleComplete, {
        AnalyticsParams.dhikrId: dhikrId,
        AnalyticsParams.dhikrPhrase: phrase,
        AnalyticsParams.cycles: cycles,
      });

  Future<void> trackDhikrPhraseSelected({
    required int dhikrId,
    String? phrase,
  }) =>
      remoteDatasource.logEvent(AnalyticsEvents.dhikrPhraseSelected, {
        AnalyticsParams.dhikrId: dhikrId,
        AnalyticsParams.dhikrPhrase: phrase,
      });

  // ── Notifications (Adhan / Adhkar custom events) ────────────────────────
  /// [prayer] = `fajr|dhuhr|asr|maghrib|isha|all`.
  Future<void> trackAdhanToggle({
    required String prayer,
    required bool enabled,
  }) =>
      remoteDatasource.logEvent(AnalyticsEvents.adhanNotificationToggle, {
        AnalyticsParams.prayer: prayer,
        AnalyticsParams.enabled: enabled,
      });

  /// [period] = `morning` | `evening`.
  Future<void> trackAdhkarReminderToggle({
    required String period,
    required bool enabled,
  }) =>
      remoteDatasource.logEvent(AnalyticsEvents.adhkarNotificationToggle, {
        AnalyticsParams.period: period,
        AnalyticsParams.enabled: enabled,
      });

  Future<void> trackDailyAyahReminderToggle({required bool enabled}) =>
      remoteDatasource.logEvent(AnalyticsEvents.dailyAyahNotificationToggle, {
        AnalyticsParams.enabled: enabled,
      });

  // ── Settings ────────────────────────────────────────────────────────────
  Future<void> trackSettingsOpen() =>
      remoteDatasource.logEvent(AnalyticsEvents.settingsOpen);

  Future<void> trackSettingChanged({
    required String key,
    required String value,
  }) =>
      remoteDatasource.logEvent(AnalyticsEvents.settingChanged, {
        AnalyticsParams.settingKey: key,
        AnalyticsParams.settingValue: value,
      });
}
