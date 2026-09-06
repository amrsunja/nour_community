import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mosque_dashboard_stats_model.dart';
import '../models/mosque_imam_model.dart';
import '../models/mosque_member_model.dart';
import '../models/mosque_post_model.dart';
import '../models/mosque_prayer_day_model.dart';
import 'mosque_catalog_remote_datasource.dart';

final mosqueAdminRemoteDataProvider = Provider((ref) => MosqueAdminRemoteDatasource());

/// Broadcast quota (`fn_mosque_broadcast_quota`).
class BroadcastQuota {
  const BroadcastQuota({required this.used, required this.limit, required this.remaining, this.nextAllowedAt});
  final int used;
  final int limit;
  final int remaining;
  final DateTime? nextAllowedAt;
  bool get exhausted => remaining <= 0;

  factory BroadcastQuota.fromJson(Json json) => BroadcastQuota(
        used: (json['used'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ?? 2,
        remaining: (json['remaining'] as num?)?.toInt() ?? 0,
        nextAllowedAt: DateTime.tryParse(json['next_allowed_at']?.toString() ?? ''),
      );
}

/// Mosque-admin writes: prayer schedule, overrides, posts, imams, media,
/// community, stats, broadcasts. RLS enforces `is_mosque_admin`.
class MosqueAdminRemoteDatasource {
  static const _prayerTimes = 'mosque_prayer_times';
  static const _overrides = 'mosque_prayer_overrides';
  static const _posts = 'mosque_posts';
  static const _imams = 'mosque_imams';
  static const _members = 'mosque_members';
  static const _bucket = 'mosque-media';

  static const _contentTypes = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'webp': 'image/webp', 'heic': 'image/heic'};

  ServerException _wrap(Object e, ApiErrorKey fallback) {
    talker.error(e);
    if (e is PostgrestException) {
      if (e.message.contains('post_limit_reached')) return ServerException(type: .badRequest, messageKey: ApiErrorKey.mosquePostLimitReached);
      if (e.message.contains('forbidden') || e.code == '42501') return ServerException(type: .forbiden, messageKey: ApiErrorKey.mosqueNotApproved);
      return ServerException(type: .badRequest, message: e.message);
    }
    return ServerException(type: .badRequest, messageKey: fallback);
  }

  // ── Prayer schedule ───────────────────────────────────────────────────────

  /// Rows for [from]..[to] inclusive (raw rows, no overrides).
  Future<Map<DateTime, MosquePrayerDayModel>> getPrayerRange(int mosqueId, DateTime from, DateTime to, {required String timezone}) async {
    try {
      final rows = await supabaseClient
          .from(_prayerTimes)
          .select()
          .eq('mosque_id', mosqueId)
          .gte('day', MosqueCatalogRemoteDatasource.dayKey(from))
          .lte('day', MosqueCatalogRemoteDatasource.dayKey(to));
      final out = <DateTime, MosquePrayerDayModel>{};
      for (final r in rows as List) {
        final m = MosquePrayerDayModel.fromRow(r as Map<String, dynamic>, timezone: timezone);
        out[m.day] = m;
      }
      return out;
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<MosquePrayerDayModel> upsertPrayerDay(MosquePrayerDayModel day) async {
    try {
      final row = await supabaseClient
          .from(_prayerTimes)
          .upsert(day.toUpsertJson(), onConflict: 'mosque_id,day')
          .select()
          .single();
      return MosquePrayerDayModel.fromRow(row, timezone: day.timezone, overrides: {
        for (final e in day.overrides.entries) e.key.name: MosquePrayerDayModel.toDb(e.value),
      });
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<int> copyPrayerTimes({required int mosqueId, required DateTime from, required DateTime toStart, required DateTime toEnd}) async {
    try {
      final n = await supabaseClient.rpc('fn_copy_mosque_prayer_times', params: {
        'p_mosque_id': mosqueId,
        'p_from': MosqueCatalogRemoteDatasource.dayKey(from),
        'p_to_start': MosqueCatalogRemoteDatasource.dayKey(toStart),
        'p_to_end': MosqueCatalogRemoteDatasource.dayKey(toEnd),
      });
      return (n as num).toInt();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<List<MosquePrayerOverride>> getOverrides(int mosqueId, {DateTime? from}) async {
    try {
      var q = supabaseClient.from(_overrides).select().eq('mosque_id', mosqueId);
      if (from != null) q = q.gte('day', MosqueCatalogRemoteDatasource.dayKey(from));
      final rows = await q.order('day');
      return (rows as List).map((e) => MosquePrayerOverride.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<MosquePrayerOverride> upsertOverride({
    required int mosqueId,
    required DateTime day,
    required PrayerSlot slot,
    required String time, // HH:MM:SS
    String? reason,
  }) async {
    try {
      final row = await supabaseClient
          .from(_overrides)
          .upsert({
            'mosque_id': mosqueId,
            'day': MosqueCatalogRemoteDatasource.dayKey(day),
            'slot': slot.name,
            'time': time,
            'reason': reason,
            'created_by': supabaseClient.auth.currentUser?.id,
          }, onConflict: 'mosque_id,day,slot')
          .select()
          .single();
      return MosquePrayerOverride.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<void> deleteOverride(int id) async {
    try {
      await supabaseClient.from(_overrides).delete().eq('id', id);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<MosquePostModel> createPost(MosquePostDraft draft) async {
    try {
      final row = await supabaseClient
          .from(_posts)
          .insert({...draft.toJson(), 'created_by': supabaseClient.auth.currentUser?.id})
          .select(MosquePostModel.selectColumns)
          .single();
      return MosquePostModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosquePostModel> updatePost(int postId, Json patch) async {
    try {
      final row = await supabaseClient.from(_posts).update(patch).eq('id', postId).select(MosquePostModel.selectColumns).single();
      return MosquePostModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<void> archivePost(int postId) => updatePost(postId, {'status': 'archived', 'archived_at': DateTime.now().toUtc().toIso8601String()});

  Future<void> deletePost(int postId) async {
    try {
      await supabaseClient.from(_posts).delete().eq('id', postId);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  // ── Broadcasts ────────────────────────────────────────────────────────────

  Future<BroadcastQuota> getBroadcastQuota(int mosqueId) async {
    try {
      final res = await supabaseClient.rpc('fn_mosque_broadcast_quota', params: {'p_mosque_id': mosqueId});
      return BroadcastQuota.fromJson((res as Map).cast<String, dynamic>());
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  /// Returns the number of recipients notified.
  Future<int> notifyFollowers({required int mosqueId, int? postId, int? campaignId, String? title, String? body}) async {
    try {
      final res = await supabaseClient.functions.invoke('notify-mosque-followers', body: {
        'mosqueId': mosqueId,
        if (postId != null) 'postId': postId,
        if (campaignId != null) 'campaignId': campaignId,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
      });
      final data = res.data;
      return (data?['recipients'] as num?)?.toInt() ?? 0;
    } on FunctionException catch (e) {
      talker.error('[mosque] notify ${e.status}', e);
      final err = (e.details is Map ? (e.details as Map)['error'] : null)?.toString();
      if (e.status == 429 || err == 'quota_exceeded') {
        throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueBroadcastQuotaExceeded);
      }
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  // ── Imams ─────────────────────────────────────────────────────────────────

  Future<MosqueImamModel> upsertImam(MosqueImamModel imam) async {
    try {
      final json = imam.toInsertJson();
      if (imam.id > 0) json['id'] = imam.id;
      final row = await supabaseClient.from(_imams).upsert(json).select().single();
      return MosqueImamModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<void> deleteImam(int id) async {
    try {
      await supabaseClient.from(_imams).delete().eq('id', id);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  // ── Media ─────────────────────────────────────────────────────────────────

  /// Uploads to `mosque-media/<mosqueId>/<folder>/<ts>.<ext>` and returns the public URL.
  Future<String> uploadMedia({required int mosqueId, required String folder, required File file}) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final path = '$mosqueId/$folder/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await supabaseClient.storage.from(_bucket).upload(
            path,
            file,
            fileOptions: FileOptions(upsert: true, contentType: _contentTypes[ext] ?? 'image/jpeg'),
          );
      return supabaseClient.storage.from(_bucket).getPublicUrl(path);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  // ── Community & stats ─────────────────────────────────────────────────────

  Future<List<MosqueCommunityMember>> getCommunity(int mosqueId, {String filter = 'all', String? query, int limit = 30, int offset = 0}) async {
    try {
      final rows = await supabaseClient.rpc('fn_mosque_community', params: {
        'p_mosque_id': mosqueId,
        'p_filter': filter,
        'p_query': query,
        'p_limit': limit,
        'p_offset': offset,
      }) as List;
      return rows.map((e) => MosqueCommunityMember.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<List<MosqueMemberModel>> getMembers(int mosqueId) async {
    try {
      final rows = await supabaseClient.from(_members).select().eq('mosque_id', mosqueId).eq('status', 'active').order('created_at');
      return (rows as List).map((e) => MosqueMemberModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<void> removeMember(int memberId) async {
    try {
      await supabaseClient.from(_members).update({'status': 'left'}).eq('id', memberId);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueDashboardStats> getDashboardStats(int mosqueId) async {
    try {
      final res = await supabaseClient.rpc('fn_mosque_dashboard_stats', params: {'p_mosque_id': mosqueId});
      return MosqueDashboardStats.fromJson((res as Map).cast<String, dynamic>());
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }
}
