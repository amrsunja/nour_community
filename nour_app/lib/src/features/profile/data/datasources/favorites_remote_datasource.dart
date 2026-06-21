import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../../../adhkar/data/models/adhkar_model.dart';
import '../../../dua/data/models/dua_model.dart';
import '../../../impact/data/models/impact_project_model.dart';
import '../models/favorite_hadith_item.dart';

final favoritesRemoteDataProvider =
    Provider((ref) => FavoritesRemoteDatasource());

/// A raw `favorite_ayahs` row (surah / ayah numbers only — ayahs are local).
typedef FavoriteAyahRef = ({int surahNumber, int ayahNumber});

/// Read access for the profile Favourites screen. Each getter returns the
/// user's favourites for one target type, newest first, joined with the content
/// rows needed to render the list. RLS already scopes the favourite tables to
/// the owner; we still pass `user_id` explicitly to match the other datasources.
class FavoritesRemoteDatasource {
  static const _favoriteAyahsTable = 'favorite_ayahs';
  static const _favoriteAdhkarsTable = 'favorite_adhkars';
  static const _favoriteDuasTable = 'favorite_duas';
  static const _favoriteHadithsTable = 'favorite_hadiths';
  static const _favoriteImpactProjectsTable = 'favorite_impact_projects';
  static const _impactProjectsTable = 'impact_projects';

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

  // ── Ayahs ──────────────────────────────────────────────────────────────────

  Future<List<FavoriteAyahRef>> getFavoriteAyahs() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteAyahsTable)
          .select('surah_number, ayah_number')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in response as List)
          (
            surahNumber: row['surah_number'] as int,
            ayahNumber: row['ayah_number'] as int,
          ),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.favoritesAyahsLoadFailed,
      );
    }
  }

  // ── Adhkars ─────────────────────────────────────────────────────────────────

  Future<List<AdhkarModel>> getFavoriteAdhkars() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteAdhkarsTable)
          .select('created_at, adhkars(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in response as List)
          if (row['adhkars'] != null)
            AdhkarModel.fromJson(row['adhkars'] as Map<String, dynamic>),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.favoritesAdhkarsLoadFailed,
      );
    }
  }

  // ── Duas ────────────────────────────────────────────────────────────────────

  Future<List<DuaModel>> getFavoriteDuas() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteDuasTable)
          .select('created_at, duas(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in response as List)
          if (row['duas'] != null)
            DuaModel.fromJson(row['duas'] as Map<String, dynamic>),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.favoritesDuasLoadFailed,
      );
    }
  }

  // ── Hadiths ─────────────────────────────────────────────────────────────────

  Future<List<FavoriteHadithItem>> getFavoriteHadiths() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteHadithsTable)
          .select(
            'created_at, hadiths(*, hadith_collections(title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru))',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in response as List)
          if (row['hadiths'] != null)
            FavoriteHadithItem.fromRow(row as Map<String, dynamic>),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.favoritesHadithsLoadFailed,
      );
    }
  }

  // ── Impact projects ─────────────────────────────────────────────────────────

  Future<List<ImpactProjectModel>> getFavoriteImpactProjects() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoriteImpactProjectsTable)
          .select(
            'created_at, $_impactProjectsTable(*, partner_organizations(*), project_categories(*))',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in response as List)
          if (row[_impactProjectsTable] != null)
            ImpactProjectModel.fromJson(
              row[_impactProjectsTable] as Map<String, dynamic>,
            ),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.favoritesProjectsLoadFailed,
      );
    }
  }
}
