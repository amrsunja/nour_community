import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/daily_dua_status_model.dart';
import '../models/dua_model.dart';
import '../models/dua_progress_model.dart';

final duaRemoteDataProvider = Provider((ref) => DuaRemoteDatasource());

/// Backend access for the Dua feature. Reuses the existing `duas`,
/// `dua_progress` and `favorite_duas` tables (see backend migrations). Unlike
/// hadiths, duas are a single flat library (no collections).
class DuaRemoteDatasource {
  static const _duasTable = 'duas';
  static const _progressTable = 'dua_progress';
  static const _favoriteDuasTable = 'favorite_duas';

  // SECURITY DEFINER RPCs (ajr_log INSERTs are blocked by RLS, so awarding ajr
  // must go through these backend functions). Degrade gracefully if missing.
  static const _rpcAwardDuaAjr = 'fn_award_dua_ajr';
  static const _rpcDailyDuaStatus = 'fn_daily_dua_status';
  static const _rpcAwardDailyDuaAjr = 'fn_award_daily_dua_ajr';

  String _requireUserId() {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        message: 'The user is not authenticated',
      );
    }
    return authUser.id;
  }

  // ── Library ────────────────────────────────────────────────────────────────

  /// The whole active dua library, ordered by `position` then `id` (a stable
  /// tie-breaker for rows that haven't been given an explicit position).
  Future<List<DuaModel>> getDuas() async {
    try {
      final response = await supabaseClient
          .from(_duasTable)
          .select()
          .eq('is_active', true)
          .order('position', ascending: true)
          .order('id', ascending: true);

      return (response as List).map((e) => DuaModel.fromJson(e)).toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load duas',
      );
    }
  }

  // ── Reading progress ─────────────────────────────────────────────────────

  /// The user's single `dua_progress` row. Returns [DuaProgressModel.empty] if
  /// (unexpectedly) absent. The 1-based position is resolved client-side from
  /// the loaded library order.
  Future<DuaProgressModel> getProgress() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_progressTable)
          .select('current_dua_id, updated_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return DuaProgressModel.empty;
      return DuaProgressModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load dua progress',
      );
    }
  }

  /// Upserts the reading position. The row is unique per user, so we
  /// conflict-resolve on `user_id`.
  Future<DuaProgressModel> saveProgress({required int duaId}) async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_progressTable)
          .upsert({
            'user_id': userId,
            'current_dua_id': duaId,
          }, onConflict: 'user_id')
          .select('current_dua_id, updated_at')
          .single();

      return DuaProgressModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to save dua progress',
      );
    }
  }

  // ── Ajr ──────────────────────────────────────────────────────────────────

  /// Awards ajr the first time [duaId] is completed (idempotent, server side).
  /// Degrades to a no-op if the RPC isn't deployed.
  Future<void> awardDuaAjr({required int duaId}) async {
    _requireUserId();
    try {
      await supabaseClient.rpc(
        _rpcAwardDuaAjr,
        params: {'p_dua_id': duaId},
      );
    } catch (e) {
      talker.warning('awardDuaAjr fallback: $e');
    }
  }

  // ── Daily Dua quick action ─────────────────────────────────────────────────

  /// All-time dua ajr + whether today's daily dua is already completed. Backed
  /// by a SECURITY DEFINER RPC; degrades to [DailyDuaStatusModel.empty].
  Future<DailyDuaStatusModel> getDailyDuaStatus() async {
    _requireUserId();
    try {
      final response = await supabaseClient.rpc(_rpcDailyDuaStatus);

      // A TABLE-returning function comes back as a list of rows.
      final row = response is List
          ? (response.isNotEmpty ? response.first : null)
          : response;
      if (row is Map<String, dynamic>) {
        return DailyDuaStatusModel.fromJson(row);
      }
      return DailyDuaStatusModel.empty;
    } catch (e) {
      talker.warning('getDailyDuaStatus fallback: $e');
      return DailyDuaStatusModel.empty;
    }
  }

  /// Awards [ajr] for completing the Daily Dua (idempotent per UTC day on the
  /// server). Returns the user's new all-time dua ajr total.
  Future<int> awardDailyDuaAjr({int ajr = 5}) async {
    _requireUserId();
    try {
      final response = await supabaseClient.rpc(
        _rpcAwardDailyDuaAjr,
        params: {'p_ajr': ajr},
      );
      return (response as num?)?.toInt() ?? 0;
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to award daily dua ajr',
      );
    }
  }

  // ── Favorites / likes ────────────────────────────────────────────────────

  /// Dua ids the current user has liked.
  Future<Set<int>> getLikedDuas() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteDuasTable)
          .select('dua_id')
          .eq('user_id', userId);

      return {for (final row in response as List) row['dua_id'] as int};
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load liked duas',
      );
    }
  }

  Future<void> likeDua(int duaId) async {
    final userId = _requireUserId();
    try {
      await supabaseClient.from(_favoriteDuasTable).upsert({
        'user_id': userId,
        'dua_id': duaId,
      }, onConflict: 'user_id,dua_id');
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, message: 'Failed to like dua');
    }
  }

  Future<void> unlikeDua(int duaId) async {
    final userId = _requireUserId();
    try {
      await supabaseClient
          .from(_favoriteDuasTable)
          .delete()
          .eq('user_id', userId)
          .eq('dua_id', duaId);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to unlike dua',
      );
    }
  }
}
