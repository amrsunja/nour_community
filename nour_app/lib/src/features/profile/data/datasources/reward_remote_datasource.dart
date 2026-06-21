import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/reward_models.dart';

final rewardRemoteDataProvider = Provider(
  (ref) => RewardRemoteDatasource(),
);

class RewardRemoteDatasource {
  static const _table = 'daily_activity';

  /// Device-local calendar date (`YYYY-MM-DD`). `daily_activity` rows are keyed
  /// by the client's local day on the server (`fn_mark_daily_activity` /
  /// `fn_sync_daily_dhikr_totals` are fed the dhikr progress row's local
  /// `progress_date`), so the client must read + claim the same row by the
  /// local date — matching the dhikr datasource's `_today`.
  String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _requireUserId() {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
      );
    }
    return authUser.id;
  }

  /// Realtime stream of *today's* `daily_activity` row (or null until it
  /// exists). Supabase `.stream()` allows a single `.eq` filter, so we scope to
  /// the user and pick today's row client-side. RLS keeps it to the caller's
  /// own rows.
  Stream<DailyActivityModel?> watchTodayActivity() {
    final userId = _requireUserId();
    final today = _today;

    return supabaseClient
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
          for (final row in rows) {
            if ((row['activity_date'] as String?)?.startsWith(today) ?? false) {
              return DailyActivityModel.fromJson(row);
            }
          }
          return null;
        });
  }

  /// Authoritative current streak read straight from `profiles`. Used at the
  /// moment a streak reward is claimed so the displayed "Day N" reflects the
  /// freshly-incremented value regardless of realtime delivery order.
  Future<int> fetchCurrentStreak() async {
    final userId = _requireUserId();
    try {
      final row = await supabaseClient
          .from('profiles')
          .select('current_streak')
          .eq('id', userId)
          .maybeSingle();
      return (row?['current_streak'] as int?) ?? 0;
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.rewardStreakLoadFailed,
      );
    }
  }

  /// Atomically claims the streak-day reward for today: flips
  /// `streak_reward_seen` false→true and returns whether *this* call won the
  /// claim. Idempotent — a realtime double-fire or cold-start re-check can
  /// never show the reward twice.
  Future<bool> claimStreakReward() => _claim('streak_reward_seen');

  /// Atomically claims the daily-dhikr reward for today (see
  /// [claimStreakReward]).
  Future<bool> claimDhikrReward() => _claim('dhikr_reward_seen');

  Future<bool> _claim(String column) async {
    final userId = _requireUserId();

    try {
      final rows = await supabaseClient
          .from(_table)
          .update({column: true})
          .eq('user_id', userId)
          .eq('activity_date', _today)
          .eq(column, false)
          .select();

      return (rows as List).isNotEmpty;
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.rewardClaimFailed,
      );
    }
  }
}
