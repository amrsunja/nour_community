import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show CountOption;
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/hadith_collection_model.dart';
import '../models/hadith_model.dart';
import '../models/hadith_progress_model.dart';

final hadithRemoteDataProvider = Provider((ref) => HadithRemoteDatasource());

/// Backend access for the Hadith feature. Reuses the existing
/// `hadith_collections`, `hadiths`, `hadith_progress` and `favorite_hadiths`
/// tables (see backend migrations).
class HadithRemoteDatasource {
  static const _collectionsTable = 'hadith_collections';
  static const _hadithsTable = 'hadiths';
  static const _progressTable = 'hadith_progress';
  static const _favoriteHadithsTable = 'favorite_hadiths';

  // SECURITY DEFINER RPC awarding ajr the first time a hadith is completed.
  // ajr_log INSERTs are blocked by RLS, so this is the only sanctioned path.
  // Degrades gracefully if the function isn't deployed yet.
  static const _rpcAwardHadithAjr = 'fn_award_hadith_ajr';

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

  /// Device-local calendar date (`YYYY-MM-DD`) — the day key the streak /
  /// daily_activity system buckets by (must match the dhikr feature's local day
  /// so dhikr_done + quick_action_done land on the same row).
  String get _localDate {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ── Collections ──────────────────────────────────────────────────────────

  /// Active collections (ordered by `position`) with their `totalHadiths`
  /// count filled in. The count drives the source-tab progress line.
  Future<List<HadithCollectionModel>> getCollections() async {
    try {
      final response = await supabaseClient
          .from(_collectionsTable)
          .select()
          .eq('is_active', true)
          .order('position', ascending: true);

      final collections = (response as List)
          .map((e) => HadithCollectionModel.fromJson(e))
          .toList();

      // Fill the active-hadith count per collection (few collections → cheap).
      final counts = await Future.wait(
        collections.map((c) => _countHadiths(c.id)),
      );

      return [
        for (var i = 0; i < collections.length; i++)
          collections[i].copyWith(totalHadiths: counts[i]),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load hadith collections',
      );
    }
  }

  Future<int> _countHadiths(int collectionId) async {
    try {
      final res = await supabaseClient
          .from(_hadithsTable)
          .select('id')
          .eq('hadith_collection_id', collectionId)
          .eq('is_active', true)
          .count(CountOption.exact);
      return res.count;
    } catch (e) {
      talker.warning('count hadiths exact fallback ($collectionId): $e');
      // Fall back to counting the returned id rows (still id-only payload).
      try {
        final rows = await supabaseClient
            .from(_hadithsTable)
            .select('id')
            .eq('hadith_collection_id', collectionId)
            .eq('is_active', true);
        return (rows as List).length;
      } catch (e2) {
        talker.warning('count hadiths length fallback ($collectionId): $e2');
        return 0;
      }
    }
  }

  /// All active hadiths in [collectionId], ordered by `position`.
  Future<List<HadithModel>> getHadiths(int collectionId) async {
    try {
      final response = await supabaseClient
          .from(_hadithsTable)
          .select()
          .eq('hadith_collection_id', collectionId)
          .eq('is_active', true)
          .order('position', ascending: true);

      return (response as List).map((e) => HadithModel.fromJson(e)).toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load hadiths',
      );
    }
  }

  // ── Reading progress ───────────────────────────────────────────────────────

  /// All of the user's progress rows, one per collection, with the current
  /// hadith's 1-based [HadithProgressModel.currentPosition] resolved so the
  /// source tab can render "x/total" without loading every hadith.
  Future<List<HadithProgressModel>> getProgress() async {
    final userId = _requireUserId();
    try {
      final rows = await supabaseClient
          .from(_progressTable)
          .select('hadith_collection_id, current_hadith_id, updated_at')
          .eq('user_id', userId);

      final list = (rows as List).cast<Map<String, dynamic>>();

      // Resolve positions for the referenced current hadiths in one query.
      final hadithIds = <int>{
        for (final r in list)
          if (r['current_hadith_id'] != null) r['current_hadith_id'] as int,
      };

      final positions = await _positionsForHadiths(hadithIds);

      return list.map((r) {
        final currentId = r['current_hadith_id'] as int?;
        return HadithProgressModel(
          collectionId: r['hadith_collection_id'] as int,
          currentHadithId: currentId,
          currentPosition: currentId == null ? 0 : (positions[currentId] ?? 0),
          updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? ''),
        );
      }).toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load hadith progress',
      );
    }
  }

  Future<Map<int, int>> _positionsForHadiths(Set<int> ids) async {
    if (ids.isEmpty) return const {};
    try {
      final rows = await supabaseClient
          .from(_hadithsTable)
          .select('id, position')
          .inFilter('id', ids.toList());

      return {
        for (final r in rows as List) r['id'] as int: (r['position'] ?? 0) as int,
      };
    } catch (e) {
      talker.warning('positionsForHadiths fallback: $e');
      return const {};
    }
  }

  /// Upserts the reading position for [collectionId]. The row is unique per
  /// (user, collection), so we conflict-resolve on that pair. Returns the
  /// resolved [HadithProgressModel] (position included).
  Future<HadithProgressModel> saveProgress({
    required int collectionId,
    required int hadithId,
    required int position,
  }) async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_progressTable)
          .upsert({
            'user_id': userId,
            'hadith_collection_id': collectionId,
            'current_hadith_id': hadithId,
          }, onConflict: 'user_id,hadith_collection_id')
          .select('hadith_collection_id, current_hadith_id, updated_at')
          .single();

      return HadithProgressModel(
        collectionId: response['hadith_collection_id'] as int,
        currentHadithId: response['current_hadith_id'] as int?,
        currentPosition: position,
        updatedAt: DateTime.tryParse(response['updated_at']?.toString() ?? ''),
      );
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to save hadith progress',
      );
    }
  }

  // ── Ajr ──────────────────────────────────────────────────────────────────

  /// Awards ajr the first time [hadithId] is completed (idempotent, server
  /// side). Degrades to a no-op if the RPC isn't deployed.
  Future<void> awardHadithAjr({required int hadithId}) async {
    _requireUserId();
    try {
      await supabaseClient.rpc(
        _rpcAwardHadithAjr,
        params: {'p_hadith_id': hadithId, 'p_local_date': _localDate},
      );
    } catch (e) {
      // RPC missing / network issue → progress still saved, feature works.
      talker.warning('awardHadithAjr fallback: $e');
    }
  }

  // ── Favorites / likes ────────────────────────────────────────────────────

  /// Hadith ids the current user has liked.
  Future<Set<int>> getLikedHadiths() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteHadithsTable)
          .select('hadith_id')
          .eq('user_id', userId);

      return {for (final row in response as List) row['hadith_id'] as int};
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load liked hadiths',
      );
    }
  }

  Future<void> likeHadith(int hadithId) async {
    final userId = _requireUserId();
    try {
      await supabaseClient.from(_favoriteHadithsTable).upsert({
        'user_id': userId,
        'hadith_id': hadithId,
      }, onConflict: 'user_id,hadith_id');
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, message: 'Failed to like hadith');
    }
  }

  Future<void> unlikeHadith(int hadithId) async {
    final userId = _requireUserId();
    try {
      await supabaseClient
          .from(_favoriteHadithsTable)
          .delete()
          .eq('user_id', userId)
          .eq('hadith_id', hadithId);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to unlike hadith',
      );
    }
  }
}
