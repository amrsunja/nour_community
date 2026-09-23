import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_post_model.dart';
import '../../data/mosque_repo.dart';

/// One mosque's news: its last [MyMosquesFeedPresenter.limit] posts, urgent
/// first then newest — rendered as a single horizontal list on the dashboard.
class MosqueFeedBlock extends Equatable {
  const MosqueFeedBlock({required this.mosque, required this.posts});

  final MosqueModel mosque;
  final List<MosquePostModel> posts;

  MosqueFeedBlock withPosts(List<MosquePostModel> next) => MosqueFeedBlock(mosque: mosque, posts: next);

  @override
  List<Object?> get props => [mosque.id, posts];
}

/// News of the worshipper's own mosques — one block per mosque, principal
/// first, for the dashboard "My mosque" section.
class MyMosquesFeedState extends Equatable {
  final bool isLoading;
  final bool loaded;

  /// One entry per mosque whose news loaded, in the order they were passed to
  /// [MyMosquesFeedPresenter.load] (principal, then secondary). A mosque with
  /// no published post keeps its block with an empty [MosqueFeedBlock.posts].
  final List<MosqueFeedBlock> blocks;

  const MyMosquesFeedState({
    this.isLoading = false,
    this.loaded = false,
    this.blocks = const [],
  });

  bool get hasPosts => blocks.any((b) => b.posts.isNotEmpty);

  MyMosquesFeedState copyWith({
    bool? isLoading,
    bool? loaded,
    List<MosqueFeedBlock>? blocks,
  }) =>
      MyMosquesFeedState(
        isLoading: isLoading ?? this.isLoading,
        loaded: loaded ?? this.loaded,
        blocks: blocks ?? this.blocks,
      );

  @override
  List<Object?> get props => [isLoading, loaded, blocks];
}

final myMosquesFeedProvider = StateNotifierProvider<MyMosquesFeedPresenter, MyMosquesFeedState>((ref) {
  return MyMosquesFeedPresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider));
});

class MyMosquesFeedPresenter extends Presenter<MyMosquesFeedState> {
  /// How many posts each mosque's list shows.
  static const int limit = 10;

  final MosqueRepo repo;
  final AppEvents appEvents;

  /// Ids the current state was built from — re-loading the same set is a no-op.
  String _key = '';
  int _seq = 0;

  MyMosquesFeedPresenter({required this.repo, required this.appEvents}) : super(const MyMosquesFeedState());

  /// Loads one list of up to [limit] posts per mosque, in the given order.
  /// Cheap to call again with the same mosques unless [force].
  Future<void> load(List<MosqueModel> mosques, {bool force = false}) async {
    final key = mosques.map((m) => m.id).join(',');
    if (!force && key == _key && state.loaded) return;
    _key = key;
    final seq = ++_seq;

    if (mosques.isEmpty) {
      state = const MyMosquesFeedState(loaded: true);
      return;
    }

    // Yield so a synchronous caller (widget lifecycle) can never mutate this
    // provider during a build.
    await Future<void>.delayed(Duration.zero);
    state = state.copyWith(isLoading: true);

    final pages = await Future.wait<SuccessOrError<List<MosquePostModel>>>(
      mosques.map((m) => repo.getPosts(m.id, limit: limit)),
    );
    if (seq != _seq || !mounted) return;

    final blocks = <MosqueFeedBlock>[];
    Failure? failure;
    for (final (i, page) in pages.indexed) {
      page.when(
        (posts) {
          // The backend already orders urgent first; re-sorting keeps the
          // guarantee if that ever changes.
          final sorted = [...posts]..sort(byUrgencyThenDate);
          blocks.add(MosqueFeedBlock(mosque: mosques[i], posts: sorted.take(limit).toList()));
        },
        (error) => failure ??= error,
      );
    }

    // Only shout when nothing at all came back — a single mosque failing is
    // not worth blocking the other one's news.
    if (blocks.isEmpty && failure != null) appEvents.send(ShowErrorEvent(failure));

    state = MyMosquesFeedState(loaded: true, blocks: blocks);
  }

  Future<void> refresh(List<MosqueModel> mosques) => load(mosques, force: true);

  /// Urgent posts first, then the most recently published.
  static int byUrgencyThenDate(MosquePostModel a, MosquePostModel b) {
    if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
    return b.publishedAt.compareTo(a.publishedAt);
  }

  void _patch(int postId, MosquePostModel Function(MosquePostModel) update) {
    state = state.copyWith(
      blocks: [
        for (final block in state.blocks)
          if (block.posts.any((p) => p.id == postId))
            block.withPosts([for (final p in block.posts) if (p.id == postId) update(p) else p])
          else
            block,
      ],
    );
  }

  Future<void> toggleAttend(MosquePostModel post) async {
    final next = !post.attending;
    _patch(post.id, (p) => p.copyWith(attending: next, attendeesCount: p.attendeesCount + (next ? 1 : -1)));
    final res = await repo.setAttending(post.id, next);
    res.when((_) {}, (error) {
      _patch(post.id, (p) => p.copyWith(attending: !next, attendeesCount: p.attendeesCount + (next ? -1 : 1)));
      appEvents.send(ShowErrorEvent(error));
    });
  }

  Future<void> applyVolunteer(MosquePostModel post) async {
    if (post.applied) return;
    _patch(post.id, (p) => p.copyWith(applied: true, applicantsCount: p.applicantsCount + 1));
    final res = await repo.apply(post.id);
    res.when((_) {}, (error) {
      _patch(post.id, (p) => p.copyWith(applied: false, applicantsCount: p.applicantsCount - 1));
      appEvents.send(ShowErrorEvent(error));
    });
  }

  Future<bool> sayDua(MosquePostModel post) async {
    if (post.duaSaid) return true;
    _patch(post.id, (p) => p.copyWith(duaSaid: true, duasCount: p.duasCount + 1));
    final res = await repo.sayDua(post.id);
    return res.when((_) => true, (error) {
      _patch(post.id, (p) => p.copyWith(duaSaid: false, duasCount: p.duasCount - 1));
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  void trackPostView(int postId) => unawaited(repo.trackPostView(postId));
}
