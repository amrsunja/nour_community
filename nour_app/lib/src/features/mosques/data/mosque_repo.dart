import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/mosque_onboarding/data/models/mosque_onboarding_draft.dart';

import 'datasources/mosque_admin_remote_datasource.dart';
import 'datasources/mosque_catalog_remote_datasource.dart';
import 'datasources/mosque_remote_datasource.dart';
import 'models/mosque_dashboard_stats_model.dart';
import 'models/mosque_enums.dart';
import 'models/mosque_imam_model.dart';
import 'models/mosque_member_model.dart';
import 'models/mosque_model.dart';
import 'models/mosque_post_model.dart';
import 'models/mosque_prayer_day_model.dart';
import 'models/mosque_search_item_model.dart';

final mosqueRepoProvider = Provider(
  (ref) => MosqueRepo(
    remote: ref.read(mosqueRemoteDataProvider),
    catalog: ref.read(mosqueCatalogRemoteDataProvider),
    admin: ref.read(mosqueAdminRemoteDataProvider),
  ),
);

/// Thin repository over the three mosque datasources; every call is wrapped
/// in [Failure.exceptionsCatcher] so presenters get a `SuccessOrError`.
class MosqueRepo {
  final MosqueRemoteDatasource remote;
  final MosqueCatalogRemoteDatasource catalog;
  final MosqueAdminRemoteDatasource admin;

  MosqueRepo({required this.remote, required this.catalog, required this.admin});

  // Account
  Future<SuccessOrError<int>> registerMosque(MosqueOnboardingDraft draft) =>
      Failure.exceptionsCatcher(() => remote.registerMosque(draft));
  Future<SuccessOrError<MyMosque?>> getMyMosque() => Failure.exceptionsCatcher(remote.getMyMosque);
  Stream<MosqueStatus> watchStatus(int mosqueId) => remote.watchStatus(mosqueId);
  Future<SuccessOrError<MosqueModel>> updateProfile(MosqueModel mosque) =>
      Failure.exceptionsCatcher(() => remote.updateProfile(mosque));

  // Catalog
  Future<SuccessOrError<List<MosqueSearchItemModel>>> search({String? query, double? lat, double? lng, int? radiusKm}) =>
      Failure.exceptionsCatcher(() => catalog.search(query: query, lat: lat, lng: lng, radiusKm: radiusKm));
  Future<SuccessOrError<MosqueModel>> getMosque(int id) => Failure.exceptionsCatcher(() => catalog.getMosque(id));
  Future<void> trackView(int id) => catalog.trackView(id);
  Future<SuccessOrError<MosquePrayerDayModel?>> getPrayerDay(int mosqueId, DateTime day, {required String timezone}) =>
      Failure.exceptionsCatcher(() => catalog.getPrayerDay(mosqueId, day, timezone: timezone));
  Future<SuccessOrError<MyMosquePrayerDays?>> getMyMosquePrayerDays({int days = 7}) =>
      Failure.exceptionsCatcher(() => catalog.getMyMosquePrayerDays(days: days));
  Future<SuccessOrError<List<MosquePostModel>>> getPosts(int mosqueId, {int limit = 30, int offset = 0, bool includeArchived = false}) =>
      Failure.exceptionsCatcher(() => catalog.getPosts(mosqueId, limit: limit, offset: offset, includeArchived: includeArchived));
  Future<SuccessOrError<MosquePostModel>> getPost(int postId) => Failure.exceptionsCatcher(() => catalog.getPost(postId));
  Future<SuccessOrError<void>> setAttending(int postId, bool on) => Failure.exceptionsCatcher(() => catalog.setAttending(postId, on));
  Future<SuccessOrError<void>> apply(int postId) => Failure.exceptionsCatcher(() => catalog.apply(postId));
  Future<SuccessOrError<void>> sayDua(int postId) => Failure.exceptionsCatcher(() => catalog.sayDua(postId));
  Future<void> trackPostView(int postId) => catalog.trackPostView(postId);
  Future<SuccessOrError<bool>> isFollowing(int mosqueId) => Failure.exceptionsCatcher(() => catalog.isFollowing(mosqueId));
  Future<SuccessOrError<void>> setFollowing(int mosqueId, bool follow) => Failure.exceptionsCatcher(() => catalog.setFollowing(mosqueId, follow));
  Future<SuccessOrError<Set<int>>> followedMosqueIds() => Failure.exceptionsCatcher(catalog.followedMosqueIds);
  Future<SuccessOrError<Map<int, MosqueModel>>> getUserMosques() => Failure.exceptionsCatcher(catalog.getUserMosques);
  Future<SuccessOrError<void>> setUserMosques({int? principal, int? secondary}) =>
      Failure.exceptionsCatcher(() => catalog.setUserMosques(principal: principal, secondary: secondary));
  Future<SuccessOrError<MosqueMemberModel?>> getMyMembership(int mosqueId) => Failure.exceptionsCatcher(() => catalog.getMyMembership(mosqueId));
  Future<SuccessOrError<MosqueMemberModel>> joinAsMember(Json payload) => Failure.exceptionsCatcher(() => catalog.joinAsMember(payload));

  // Admin
  Future<SuccessOrError<Map<DateTime, MosquePrayerDayModel>>> getPrayerRange(int mosqueId, DateTime from, DateTime to, {required String timezone}) =>
      Failure.exceptionsCatcher(() => admin.getPrayerRange(mosqueId, from, to, timezone: timezone));
  Future<SuccessOrError<MosquePrayerDayModel>> upsertPrayerDay(MosquePrayerDayModel day) => Failure.exceptionsCatcher(() => admin.upsertPrayerDay(day));
  Future<SuccessOrError<int>> copyPrayerTimes({required int mosqueId, required DateTime from, required DateTime toStart, required DateTime toEnd}) =>
      Failure.exceptionsCatcher(() => admin.copyPrayerTimes(mosqueId: mosqueId, from: from, toStart: toStart, toEnd: toEnd));
  Future<SuccessOrError<List<MosquePrayerOverride>>> getOverrides(int mosqueId, {DateTime? from}) =>
      Failure.exceptionsCatcher(() => admin.getOverrides(mosqueId, from: from));
  Future<SuccessOrError<MosquePrayerOverride>> upsertOverride({required int mosqueId, required DateTime day, required PrayerSlot slot, required String time, String? reason}) =>
      Failure.exceptionsCatcher(() => admin.upsertOverride(mosqueId: mosqueId, day: day, slot: slot, time: time, reason: reason));
  Future<SuccessOrError<void>> deleteOverride(int id) => Failure.exceptionsCatcher(() => admin.deleteOverride(id));
  Future<SuccessOrError<MosquePostModel>> createPost(MosquePostDraft draft) => Failure.exceptionsCatcher(() => admin.createPost(draft));
  Future<SuccessOrError<MosquePostModel>> updatePost(int postId, Json patch) => Failure.exceptionsCatcher(() => admin.updatePost(postId, patch));
  Future<SuccessOrError<void>> archivePost(int postId) => Failure.exceptionsCatcher(() => admin.archivePost(postId));
  Future<SuccessOrError<void>> deletePost(int postId) => Failure.exceptionsCatcher(() => admin.deletePost(postId));
  Future<SuccessOrError<BroadcastQuota>> getBroadcastQuota(int mosqueId) => Failure.exceptionsCatcher(() => admin.getBroadcastQuota(mosqueId));
  Future<SuccessOrError<int>> notifyFollowers({required int mosqueId, int? postId, int? campaignId, String? title, String? body}) =>
      Failure.exceptionsCatcher(() => admin.notifyFollowers(mosqueId: mosqueId, postId: postId, campaignId: campaignId, title: title, body: body));
  Future<SuccessOrError<MosqueImamModel>> upsertImam(MosqueImamModel imam) => Failure.exceptionsCatcher(() => admin.upsertImam(imam));
  Future<SuccessOrError<void>> deleteImam(int id) => Failure.exceptionsCatcher(() => admin.deleteImam(id));
  Future<SuccessOrError<String>> uploadMedia({required int mosqueId, required String folder, required File file}) =>
      Failure.exceptionsCatcher(() => admin.uploadMedia(mosqueId: mosqueId, folder: folder, file: file));
  Future<SuccessOrError<List<MosqueCommunityMember>>> getCommunity(int mosqueId, {String filter = 'all', String? query, int limit = 30, int offset = 0}) =>
      Failure.exceptionsCatcher(() => admin.getCommunity(mosqueId, filter: filter, query: query, limit: limit, offset: offset));
  Future<SuccessOrError<List<MosqueMemberModel>>> getMembers(int mosqueId) => Failure.exceptionsCatcher(() => admin.getMembers(mosqueId));
  Future<SuccessOrError<void>> removeMember(int memberId) => Failure.exceptionsCatcher(() => admin.removeMember(memberId));
  Future<SuccessOrError<MosqueDashboardStats>> getDashboardStats(int mosqueId) => Failure.exceptionsCatcher(() => admin.getDashboardStats(mosqueId));
}
