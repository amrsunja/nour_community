import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

final pushRemoteDataProvider = Provider((ref) => PushRemoteDatasource());

/// Server side of the push infrastructure: device tokens, open tracking and
/// per-kind preferences (`profiles.push_prefs`).
class PushRemoteDatasource {
  static const _tokensTable = 'device_tokens';

  Future<void> registerToken({
    required String token,
    required String platform,
    String? appVersion,
    String? locale,
    String? timezone,
  }) async {
    if (supabaseClient.auth.currentUser == null) return;
    try {
      await supabaseClient.rpc('fn_register_device_token', params: {
        'p_token': token,
        'p_platform': platform,
        'p_app_version': appVersion,
        'p_locale': locale,
        'p_timezone': timezone,
      });
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.pushRegisterFailed);
    }
  }

  Future<void> deleteToken(String token) async {
    try {
      await supabaseClient.from(_tokensTable).delete().eq('token', token);
    } catch (e) {
      talker.error(e);
    }
  }

  Future<void> markOpened(int logId) async {
    try {
      await supabaseClient.rpc('fn_mark_notification_opened', params: {'p_id': logId});
    } catch (e) {
      talker.error(e);
    }
  }

  /// The caller's last pushes (`notifications_log`, RLS self-read).
  Future<List<Map<String, dynamic>>> myNotifications({int limit = 50}) async {
    try {
      final rows = await supabaseClient
          .from('notifications_log')
          .select('id, kind, title, body, data, sent_at, opened_at')
          .order('sent_at', ascending: false)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>();
    } catch (e) {
      talker.error(e);
      return const [];
    }
  }

  Future<void> setPushPrefs(Map<String, dynamic> prefs) async {
    try {
      await supabaseClient.rpc('fn_set_push_prefs', params: {'p_prefs': prefs});
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    }
  }
}
