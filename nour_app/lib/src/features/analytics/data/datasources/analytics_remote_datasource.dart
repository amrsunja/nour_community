import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

final analyticsRemoteDataProvider = Provider(
  (ref) => AnalyticsRemoteDatasource(FirebaseAnalytics.instance),
);

/// Thin, fire-and-forget sink over the Firebase Analytics SDK.
///
/// Every call is wrapped: analytics must never throw into a user flow. Param
/// maps are sanitised to the only types GA4 accepts (`String` / `num`) — nulls
/// dropped, `bool` coerced to `'true'`/`'false'`, strings clamped to 100 chars.
class AnalyticsRemoteDatasource {
  AnalyticsRemoteDatasource(this._analytics);

  final FirebaseAnalytics _analytics;

  FirebaseAnalytics get instance => _analytics;

  Future<void> setCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e, s) {
      talker.error('[analytics] setCollectionEnabled failed', e, s);
    }
  }

  Future<void> logEvent(String name, [Map<String, Object?>? parameters]) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: _sanitize(parameters),
      );
    } catch (e, s) {
      talker.error('[analytics] logEvent "$name" failed', e, s);
    }
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e, s) {
      talker.error('[analytics] logScreenView "$screenName" failed', e, s);
    }
  }

  Future<void> logLogin({String? method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e, s) {
      talker.error('[analytics] logLogin failed', e, s);
    }
  }

  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e, s) {
      talker.error('[analytics] logSignUp failed', e, s);
    }
  }

  /// Identify the active user. Pass a non-PII id (Supabase uid is fine).
  Future<void> setUserId(String? id) async {
    try {
      await _analytics.setUserId(id: id);
    } catch (e, s) {
      talker.error('[analytics] setUserId failed', e, s);
    }
  }

  Future<void> setUserProperty({required String name, String? value}) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e, s) {
      talker.error('[analytics] setUserProperty "$name" failed', e, s);
    }
  }

  /// Drop nulls, coerce bools, clamp long strings. Returns `null` when empty so
  /// the SDK records a bare event.
  Map<String, Object>? _sanitize(Map<String, Object?>? params) {
    if (params == null || params.isEmpty) return null;

    final out = <String, Object>{};
    params.forEach((key, value) {
      if (value == null) return;
      if (value is bool) {
        out[key] = value ? 'true' : 'false';
      } else if (value is num) {
        out[key] = value;
      } else {
        final s = value.toString();
        out[key] = s.length > 100 ? s.substring(0, 100) : s;
      }
    });

    return out.isEmpty ? null : out;
  }
}
