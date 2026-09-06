import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mosque_member_model.dart';
import '../models/mosque_model.dart';
import '../models/mosque_post_model.dart';
import '../models/mosque_prayer_day_model.dart';
import '../models/mosque_search_item_model.dart';

final mosqueCatalogRemoteDataProvider = Provider((ref) => MosqueCatalogRemoteDatasource());

/// The user's principal mosque + its prayer days (from `fn_my_mosque_prayer_days`).
class MyMosquePrayerDays {
  const MyMosquePrayerDays({required this.mosqueId, required this.name, this.city, required this.timezone, required this.days});
  final int mosqueId;
  final String name;
  final String? city;
  final String timezone;
  /// Only the days the mosque has filled.
  final Map<DateTime, MosquePrayerDayModel> days;
}

/// Worshipper-side reads/writes: search, public profile, prayer days, posts,
/// follow, "my mosques", interactions, membership.
class MosqueCatalogRemoteDatasource {
  static const _mosques = 'mosques';
  static const _followers = 'mosque_followers';
  static const _userMosques = 'user_mosques';
  static const _members = 'mosque_members';
  static const _posts = 'mosque_posts';

  String _requireUserId() {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(type: .unauthorized, messageKey: ApiErrorKey.userNotAuthenticated);
    }
    return authUser.id;
  }

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Search ────────────────────────────────────────────────────────────────

  Future<List<MosqueSearchItemModel>> search({String? query, double? lat, double? lng, int? radiusKm, int limit = 30}) async {
    try {
      final rows = await supabaseClient.rpc('fn_search_mosques', params: {
        'p_query': query,
        'p_lat': lat,
        'p_lng': lng,
        'p_radius_km': radiusKm,
        'p_limit': limit,
      }) as List;
      return rows.map((e) => MosqueSearchItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSearchFailed);
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<MosqueModel> getMosque(int id) async {
    try {
      final row = await supabaseClient.from(_mosques).select('*, mosque_imams(*)').eq('id', id).single();
      return MosqueModel.fromJson(row);
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<void> trackView(int mosqueId) async {
    try {
      await supabaseClient.rpc('fn_track_mosque_view', params: {'p_mosque_id': mosqueId});
    } catch (e) {
      talker.warning('track view: $e');
    }
  }

  /// Effective day (row + overrides) or `null` when the mosque has no row.
  Future<MosquePrayerDayModel?> getPrayerDay(int mosqueId, DateTime day, {required String timezone}) async {
    try {
      final key = dayKey(day);
      final rows = await supabaseClient.from('mosque_prayer_times').select().eq('mosque_id', mosqueId).eq('day', key);
      if ((rows as List).isEmpty) return null;
      final ov = await supabaseClient.from('mosque_prayer_overrides').select('slot, time').eq('mosque_id', mosqueId).eq('day', key);
      final overrides = {for (final o in (ov as List)) o['slot'].toString(): o['time']};
      return MosquePrayerDayModel.fromRow(rows.first as Map<String, dynamic>, timezone: timezone, overrides: overrides);
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  /// Principal mosque's next [days] days in one round-trip.
  Future<MyMosquePrayerDays?> getMyMosquePrayerDays({int days = 7}) async {
    if (supabaseClient.auth.currentUser == null) return null;
    try {
      final rows = await supabaseClient.rpc('fn_my_mosque_prayer_days', params: {'p_days': days}) as List;
      if (rows.isEmpty) return null;
      final first = rows.first as Map<String, dynamic>;
      final tzName = first['timezone'] as String? ?? 'Europe/Paris';
      final mosqueId = first['mosque_id'] as int;
      final map = <DateTime, MosquePrayerDayModel>{};
      for (final r in rows) {
        final row = r as Map<String, dynamic>;
        final day = DateTime.parse(row['day'] as String);
        final json = row['row_json'];
        if (json is! Map) continue;
        map[DateTime(day.year, day.month, day.day)] = MosquePrayerDayModel.fromRow(
          json.cast<String, dynamic>(),
          timezone: tzName,
          overrides: (row['overrides'] as Map?)?.cast<String, dynamic>(),
          mosqueId: mosqueId,
          day: day,
        );
      }
      return MyMosquePrayerDays(
        mosqueId: mosqueId,
        name: first['mosque_name'] as String? ?? '',
        city: first['city'] as String?,
        timezone: tzName,
        days: map,
      );
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<List<MosquePostModel>> getPosts(int mosqueId, {int limit = 30, int offset = 0, bool includeArchived = false}) async {
    try {
      var q = supabaseClient.from(_posts).select(MosquePostModel.selectColumns).eq('mosque_id', mosqueId);
      if (!includeArchived) q = q.eq('status', 'published');
      final rows = await q
          .order('is_urgent', ascending: false)
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);
      final me = supabaseClient.auth.currentUser?.id;
      return (rows as List).map((e) => MosquePostModel.fromJson(e as Map<String, dynamic>, viewerId: me)).toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<MosquePostModel> getPost(int postId) async {
    try {
      final row = await supabaseClient.from(_posts).select(MosquePostModel.selectColumns).eq('id', postId).single();
      return MosquePostModel.fromJson(row, viewerId: supabaseClient.auth.currentUser?.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<void> _toggleInteraction(String table, int postId, bool on) async {
    final uid = _requireUserId();
    try {
      if (on) {
        await supabaseClient.from(table).upsert({'post_id': postId, 'user_id': uid}, onConflict: 'post_id,user_id');
      } else {
        await supabaseClient.from(table).delete().eq('post_id', postId).eq('user_id', uid);
      }
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<void> setAttending(int postId, bool on) => _toggleInteraction('mosque_post_attendees', postId, on);
  Future<void> apply(int postId) => _toggleInteraction('mosque_post_applicants', postId, true);
  Future<void> sayDua(int postId) => _toggleInteraction('mosque_post_duas', postId, true);

  Future<void> trackPostView(int postId) async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabaseClient.from('mosque_post_views').upsert({'post_id': postId, 'user_id': uid}, onConflict: 'post_id,user_id', ignoreDuplicates: true);
    } catch (_) {}
  }

  // ── Follow ────────────────────────────────────────────────────────────────

  Future<bool> isFollowing(int mosqueId) async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid == null) return false;
    final rows = await supabaseClient.from(_followers).select('mosque_id').eq('mosque_id', mosqueId).eq('user_id', uid);
    return (rows as List).isNotEmpty;
  }

  Future<void> setFollowing(int mosqueId, bool follow) async {
    final uid = _requireUserId();
    try {
      if (follow) {
        await supabaseClient.from(_followers).upsert({'mosque_id': mosqueId, 'user_id': uid}, onConflict: 'mosque_id,user_id');
      } else {
        await supabaseClient.from(_followers).delete().eq('mosque_id', mosqueId).eq('user_id', uid);
      }
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<Set<int>> followedMosqueIds() async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid == null) return {};
    final rows = await supabaseClient.from(_followers).select('mosque_id').eq('user_id', uid);
    return (rows as List).map((e) => e['mosque_id'] as int).toSet();
  }

  // ── My mosques (principal / secondary) ────────────────────────────────────

  /// `{1: mosque, 2: mosque}`
  Future<Map<int, MosqueModel>> getUserMosques() async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid == null) return {};
    try {
      final rows = await supabaseClient.from(_userMosques).select('rank, mosques(*)').eq('user_id', uid);
      final out = <int, MosqueModel>{};
      for (final r in rows as List) {
        final m = r['mosques'];
        if (m is Map) out[r['rank'] as int] = MosqueModel.fromJson(m.cast<String, dynamic>());
      }
      return out;
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<void> setUserMosques({int? principal, int? secondary}) async {
    _requireUserId();
    try {
      await supabaseClient.rpc('fn_set_user_mosques', params: {'p_principal': principal, 'p_secondary': secondary});
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    }
  }

  // ── Membership ────────────────────────────────────────────────────────────

  Future<MosqueMemberModel?> getMyMembership(int mosqueId) async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid == null) return null;
    final rows = await supabaseClient.from(_members).select().eq('mosque_id', mosqueId).eq('user_id', uid);
    if ((rows as List).isEmpty) return null;
    return MosqueMemberModel.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<MosqueMemberModel> joinAsMember(Json payload) async {
    final uid = _requireUserId();
    try {
      final row = await supabaseClient
          .from(_members)
          .upsert({...payload, 'user_id': uid, 'status': 'active', 'consent_at': DateTime.now().toUtc().toIso8601String()},
              onConflict: 'mosque_id,user_id')
          .select()
          .single();
      return MosqueMemberModel.fromJson(row);
    } on PostgrestException catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    }
  }
}
