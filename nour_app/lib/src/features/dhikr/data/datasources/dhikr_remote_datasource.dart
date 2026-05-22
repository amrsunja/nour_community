import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/dhikr_model.dart';
import '../models/dhikr_progress_model.dart';

final dhikrRemoteDataProvider = Provider(
  (ref) => DhikrRemoteDatasource(),
);

class DhikrRemoteDatasource {
  static const _dhikrsTable = 'dhikrs';
  static const _progressTable = 'dhikr_progress';

  String get _today {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

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

  Future<List<DhikrModel>> getDhikrs() async {
    try {
      final response = await supabaseClient
          .from(_dhikrsTable)
          .select()
          .eq('is_active', true)
          .order('id', ascending: true);

      return (response as List)
          .map((e) => DhikrModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, message: 'Failed to load dhikrs');
    }
  }

  /// Today's progress rows for the authenticated user.
  Future<List<DhikrProgressModel>> getTodayProgress() async {
    final userId = _requireUserId();

    try {
      final response = await supabaseClient
          .from(_progressTable)
          .select()
          .eq('user_id', userId)
          .eq('progress_date', _today);

      return (response as List)
          .map((e) => DhikrProgressModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load dhikr progress',
      );
    }
  }

  /// Upserts today's count for [dhikrId]. The DB trigger derives
  /// `is_completed` / ajr — the client only pushes `current_count`.
  Future<DhikrProgressModel> upsertProgress({
    required int dhikrId,
    required int count,
  }) async {
    final userId = _requireUserId();

    try {
      final response = await supabaseClient
          .from(_progressTable)
          .upsert({
            'user_id': userId,
            'dhikr_id': dhikrId,
            'current_count': count,
            'progress_date': _today,
          }, onConflict: 'user_id,dhikr_id,progress_date')
          .select()
          .single();

      return DhikrProgressModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to save dhikr progress',
      );
    }
  }
}
