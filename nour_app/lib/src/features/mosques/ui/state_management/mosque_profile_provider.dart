import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosques_provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_member_model.dart';
import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_post_model.dart';
import '../../data/models/mosque_prayer_day_model.dart';
import '../../data/mosque_repo.dart';

class MosqueProfileState extends Equatable {
  final bool isLoading;
  final MosqueModel? mosque;
  final MosquePrayerDayModel? today;   // null = mosque has no row → computed fallback in UI
  final DateTime? todayDate;           // "today" in the mosque timezone
  final List<MosquePostModel> posts;
  final bool postsLoaded;
  final bool isFollowing;
  final MosqueMemberModel? membership;
  final MosqueTab tab;
  final bool followBusy;

  const MosqueProfileState({
    this.isLoading = false,
    this.mosque,
    this.today,
    this.todayDate,
    this.posts = const [],
    this.postsLoaded = false,
    this.isFollowing = false,
    this.membership,
    this.tab = MosqueTab.prayers,
    this.followBusy = false,
  });

  bool get isMember => membership?.isActive ?? false;

  MosqueProfileState copyWith({
    bool? isLoading,
    MosqueModel? mosque,
    MosquePrayerDayModel? today,
    DateTime? todayDate,
    List<MosquePostModel>? posts,
    bool? postsLoaded,
    bool? isFollowing,
    MosqueMemberModel? membership,
    MosqueTab? tab,
    bool? followBusy,
    bool clearToday = false,
  }) =>
      MosqueProfileState(
        isLoading: isLoading ?? this.isLoading,
        mosque: mosque ?? this.mosque,
        today: clearToday ? null : (today ?? this.today),
        todayDate: todayDate ?? this.todayDate,
        posts: posts ?? this.posts,
        postsLoaded: postsLoaded ?? this.postsLoaded,
        isFollowing: isFollowing ?? this.isFollowing,
        membership: membership ?? this.membership,
        tab: tab ?? this.tab,
        followBusy: followBusy ?? this.followBusy,
      );

  @override
  List<Object?> get props => [isLoading, mosque, today, todayDate, posts, postsLoaded, isFollowing, membership, tab, followBusy];
}

final mosqueProfileProvider =
    StateNotifierProvider.autoDispose.family<MosqueProfilePresenter, MosqueProfileState, int>((ref, mosqueId) {
  return MosqueProfilePresenter(
    mosqueId: mosqueId,
    repo: ref.read(mosqueRepoProvider),
    appEvents: ref.read(appEventProvider),
    ref: ref,
  );
});

/// Public mosque profile (worshipper POV) — also reused by the admin editor
/// for the read parts (§8.3).
class MosqueProfilePresenter extends Presenter<MosqueProfileState> {
  final int mosqueId;
  final MosqueRepo repo;
  final AppEvents appEvents;
  final Ref ref;

  MosqueProfilePresenter({required this.mosqueId, required this.repo, required this.appEvents, required this.ref})
      : super(const MosqueProfileState());

  static DateTime todayIn(String timezone) {
    try {
      final now = tz.TZDateTime.now(tz.getLocation(timezone));
      return DateTime(now.year, now.month, now.day);
    } catch (_) {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day);
    }
  }

  Future<void> init({MosqueTab? tab, bool trackView = true}) async {
    state = state.copyWith(isLoading: true, tab: tab);
    final res = await repo.getMosque(mosqueId);
    await res.when(
      (mosque) async {
        state = state.copyWith(mosque: mosque);
        await Future.wait([
          _loadToday(mosque),
          _loadFollow(),
          _loadMembership(),
          loadPosts(),
        ]);
        state = state.copyWith(isLoading: false);
        if (trackView) unawaited(repo.trackView(mosqueId));
      },
      (error) async {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  Future<void> refresh() async {
    final mosque = state.mosque;
    if (mosque == null) return init(trackView: false);
    final res = await repo.getMosque(mosqueId);
    res.when((m) => state = state.copyWith(mosque: m), (_) {});
    await Future.wait([_loadToday(state.mosque!), loadPosts()]);
  }

  Future<void> _loadToday(MosqueModel mosque) async {
    final today = todayIn(mosque.timezone);
    final res = await repo.getPrayerDay(mosqueId, today, timezone: mosque.timezone);
    res.when(
      (day) => state = state.copyWith(today: day, todayDate: today, clearToday: day == null),
      (error) => talker.warning('prayer day: $error'),
    );
  }

  Future<void> _loadFollow() async {
    final res = await repo.isFollowing(mosqueId);
    res.when((v) => state = state.copyWith(isFollowing: v), (_) {});
  }

  Future<void> _loadMembership() async {
    final res = await repo.getMyMembership(mosqueId);
    res.when((m) => state = state.copyWith(membership: m), (_) {});
  }

  Future<void> loadPosts() async {
    final res = await repo.getPosts(mosqueId);
    res.when(
      (posts) => state = state.copyWith(posts: posts, postsLoaded: true),
      (error) {
        state = state.copyWith(postsLoaded: true);
        talker.warning('posts: $error');
      },
    );
  }

  void setTab(MosqueTab tab) => state = state.copyWith(tab: tab);

  Future<void> toggleFollow() async {
    if (state.followBusy) return;
    final next = !state.isFollowing;
    final mosque = state.mosque;
    state = state.copyWith(
      followBusy: true,
      isFollowing: next,
      mosque: mosque == null ? null : mosque.copyWith(followersCount: (mosque.followersCount + (next ? 1 : -1)).clamp(0, 1 << 30)),
    );
    final res = await repo.setFollowing(mosqueId, next);
    res.when(
      (_) => state = state.copyWith(followBusy: false),
      (error) {
        state = state.copyWith(
          followBusy: false,
          isFollowing: !next,
          mosque: mosque,
        );
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  void _patchPost(int postId, MosquePostModel Function(MosquePostModel) fn) {
    state = state.copyWith(posts: [for (final p in state.posts) p.id == postId ? fn(p) : p]);
  }

  Future<void> toggleAttend(MosquePostModel post) async {
    final next = !post.attending;
    _patchPost(post.id, (p) => p.copyWith(attending: next, attendeesCount: p.attendeesCount + (next ? 1 : -1)));
    final res = await repo.setAttending(post.id, next);
    res.when((_) {}, (error) {
      _patchPost(post.id, (p) => p.copyWith(attending: !next, attendeesCount: p.attendeesCount + (next ? -1 : 1)));
      appEvents.send(ShowErrorEvent(error));
    });
  }

  Future<void> applyVolunteer(MosquePostModel post) async {
    if (post.applied) return;
    _patchPost(post.id, (p) => p.copyWith(applied: true, applicantsCount: p.applicantsCount + 1));
    final res = await repo.apply(post.id);
    res.when((_) {}, (error) {
      _patchPost(post.id, (p) => p.copyWith(applied: false, applicantsCount: p.applicantsCount - 1));
      appEvents.send(ShowErrorEvent(error));
    });
  }

  Future<bool> sayDua(MosquePostModel post) async {
    if (post.duaSaid) return true;
    _patchPost(post.id, (p) => p.copyWith(duaSaid: true, duasCount: p.duasCount + 1));
    final res = await repo.sayDua(post.id);
    return res.when((_) => true, (error) {
      _patchPost(post.id, (p) => p.copyWith(duaSaid: false, duasCount: p.duasCount - 1));
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  void trackPostView(int postId) => unawaited(repo.trackPostView(postId));

  void setMembership(MosqueMemberModel m) {
    final mosque = state.mosque;
    state = state.copyWith(
      membership: m,
      mosque: state.membership == null && mosque != null ? mosque.copyWith(membersCount: mosque.membersCount + 1) : mosque,
    );
  }

  /// Admin editor: replace the mosque row after a save.
  void setMosque(MosqueModel m) => state = state.copyWith(mosque: m);

  /// Admin editor: replace today's schedule after a save.
  void setToday(MosquePrayerDayModel? d) => state = state.copyWith(today: d, clearToday: d == null);

  Future<bool> addToMyMosques() => ref.read(myMosquesProvider.notifier).add(mosqueId);
}
