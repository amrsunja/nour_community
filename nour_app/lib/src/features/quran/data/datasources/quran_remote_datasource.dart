import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/daily_ayah_status_model.dart';
import '../models/quran_progress_model.dart';

final quranRemoteDataProvider = Provider((ref) => QuranRemoteDatasource());

/// Backend access for the Quran feature. Reuses the existing
/// `quran_progress` and `favorite_ayahs` tables (see backend migrations).
class QuranRemoteDatasource {
  static const _progressTable = 'quran_progress';
  static const _favoriteAyahsTable = 'favorite_ayahs';

  // SECURITY DEFINER RPCs that expose *global* like counts without leaking
  // other users' favorite rows (RLS keeps direct SELECTs scoped to the owner).
  static const _rpcSurahLikes = 'fn_surah_ayah_likes';

  // SECURITY DEFINER RPCs for the Daily Ayah quick action. ajr_log INSERTs are
  // blocked by RLS, so awarding ajr must go through the backend function.
  static const _rpcDailyAyahStatus = 'fn_daily_ayah_status';
  static const _rpcAwardDailyAyahAjr = 'fn_award_daily_ayah_ajr';

  // Public Quran API used only for transliteration (the bundled `quran`
  // package ships Arabic + translations + audio, but no transliteration).
  static const _alquranBase = 'https://api.alquran.cloud/v1';
  final Dio _dio = Dio();

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

  // ── Reading progress ───────────────────────────────────────────────────────

  /// The user's single `quran_progress` row. Returns [QuranProgressModel.initial]
  /// if (unexpectedly) absent.
  Future<QuranProgressModel> getProgress() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_progressTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return QuranProgressModel.initial;
      return QuranProgressModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranProgressLoadFailed,
      );
    }
  }

  /// Upserts the "continue reading" position. The row is unique per user, so
  /// we conflict-resolve on `user_id`.
  Future<QuranProgressModel> saveProgress({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_progressTable)
          .upsert({
            'user_id': userId,
            'current_surah_number': surahNumber,
            'current_ayah_number': ayahNumber,
          }, onConflict: 'user_id')
          .select()
          .single();

      return QuranProgressModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranProgressSaveFailed,
      );
    }
  }

  // ── Favorites / likes ────────────────────────────────────────────────────────

  /// Ayah numbers the current user has liked within [surahNumber].
  Future<Set<int>> getLikedAyahs(int surahNumber) async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteAyahsTable)
          .select('ayah_number')
          .eq('user_id', userId)
          .eq('surah_number', surahNumber);

      return {
        for (final row in response as List) row['ayah_number'] as int,
      };
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranLikedAyahsLoadFailed,
      );
    }
  }

  /// Global like counts for every liked ayah in [surahNumber], as a
  /// `{ayahNumber: count}` map. Backed by a SECURITY DEFINER RPC; if that
  /// function isn't deployed yet we degrade gracefully to an empty map.
  Future<Map<int, int>> getSurahLikeCounts(int surahNumber) async {
    try {
      final response = await supabaseClient.rpc(
        _rpcSurahLikes,
        params: {'p_surah_number': surahNumber},
      );

      final counts = <int, int>{};
      for (final row in response as List) {
        final ayah = row['ayah_number'] as int?;
        final count = row['likes_count'] as int?;
        if (ayah != null) counts[ayah] = count ?? 0;
      }
      return counts;
    } catch (e) {
      // RPC missing / network issue → no global counts, feature still works.
      talker.warning('getSurahLikeCounts fallback: $e');
      return const {};
    }
  }

  // ── Daily Ayah ajr ───────────────────────────────────────────────────────

  /// All-time ayah ajr + whether today's ayah is already completed. Backed by a
  /// SECURITY DEFINER RPC; degrades to [DailyAyahStatusModel.empty] if missing.
  Future<DailyAyahStatusModel> getDailyAyahStatus() async {
    _requireUserId();
    try {
      final response = await supabaseClient.rpc(_rpcDailyAyahStatus);

      // A TABLE-returning function comes back as a list of rows.
      final row = response is List
          ? (response.isNotEmpty ? response.first : null)
          : response;
      if (row is Map<String, dynamic>) {
        return DailyAyahStatusModel.fromJson(row);
      }
      return DailyAyahStatusModel.empty;
    } catch (e) {
      talker.warning('getDailyAyahStatus fallback: $e');
      return DailyAyahStatusModel.empty;
    }
  }

  /// Awards [ajr] for completing the Daily Ayah (idempotent per UTC day on the
  /// server). Returns the user's new all-time ayah ajr total.
  Future<int> awardDailyAyahAjr({int ajr = 5}) async {
    _requireUserId();
    try {
      final response = await supabaseClient.rpc(
        _rpcAwardDailyAyahAjr,
        params: {'p_ajr': ajr},
      );
      return (response as num?)?.toInt() ?? 0;
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranAyahAjrAwardFailed,
      );
    }
  }

  Future<void> likeAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final userId = _requireUserId();
    try {
      await supabaseClient.from(_favoriteAyahsTable).upsert({
        'user_id': userId,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
      }, onConflict: 'user_id,surah_number,ayah_number');
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranLikeAyahFailed,
      );
    }
  }

  // ── Transliteration ──────────────────────────────────────────────────────

  /// Latin transliteration for every ayah of [surahNumber], as a
  /// `{ayahNumber: text}` map. [edition] is the alquran.cloud transliteration
  /// edition id (defaults to `en.transliteration`). Read-only, anonymous
  /// endpoint — no auth required.
  Future<Map<int, String>> getSurahTransliteration(
    int surahNumber, {
    String edition = 'en.transliteration',
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_alquranBase/surah/$surahNumber/$edition',
      );

      final ayahs = (res.data?['data']?['ayahs'] as List?) ?? const [];
      final map = <int, String>{};
      for (final a in ayahs) {
        final n = a['numberInSurah'] as int?;
        final t = a['text'] as String?;
        if (n != null && t != null && t.isNotEmpty) map[n] = t;
      }
      return map;
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranTransliterationLoadFailed,
      );
    }
  }

  Future<void> unlikeAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final userId = _requireUserId();
    try {
      await supabaseClient
          .from(_favoriteAyahsTable)
          .delete()
          .eq('user_id', userId)
          .eq('surah_number', surahNumber)
          .eq('ayah_number', ayahNumber);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.quranUnlikeAyahFailed,
      );
    }
  }
}
