import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/hadith_repo.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/hadith_progress_model.dart';
import 'hadith_state.dart';

final hadithProvider =
    StateNotifierProvider<HadithPresenter, HadithState>((ref) {
  return HadithPresenter(
    repo: ref.read(hadithRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class HadithPresenter extends Presenter<HadithState> {
  final HadithRepo repo;
  final AppEvents appEvents;

  HadithPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const HadithState());

  /// Loads the collections + the user's per-collection reading progress and
  /// liked hadiths. Safe to call repeatedly — no-ops once data is present.
  Future<void> init() async {
    if (state.collections.isNotEmpty) return;

    state = state.copyWith(isLoading: true, hasError: false);

    final collectionsRes = await repo.getCollections();
    collectionsRes.when(
      (collections) => state = state.copyWith(collections: collections),
      (error) {
        state = state.copyWith(isLoading: false, hasError: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );

    if (state.hasError) return;

    final progressRes = await repo.getProgress();
    progressRes.when(
      (progress) => state = state.copyWith(
        progressByCollection: {for (final p in progress) p.collectionId: p},
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    final likedRes = await repo.getLikedHadiths();
    likedRes.when(
      (liked) => state = state.copyWith(likedHadiths: liked),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoading: false);
  }

  Future<void> retry() async {
    state = const HadithState();
    await init();
  }

  /// Lazily loads (and caches) the ordered hadiths of [collectionId]. Called
  /// when opening the collection detail page.
  Future<void> loadHadiths(int collectionId) async {
    if (state.hadithsByCollection.containsKey(collectionId)) return;
    if (state.isLoadingCollection(collectionId)) return;

    state = state.copyWith(
      loadingCollections: {...state.loadingCollections, collectionId},
    );

    final res = await repo.getHadiths(collectionId);
    res.when(
      (hadiths) {
        state = state.copyWith(
          hadithsByCollection: {
            ...state.hadithsByCollection,
            collectionId: hadiths,
          },
        );
      },
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(
      loadingCollections: {...state.loadingCollections}..remove(collectionId),
    );
  }

  /// Persists the reading position for [collectionId]. Called on "I'm done",
  /// on every hadith change in the reader, and on leaving the page. Skips the
  /// round-trip when nothing changed, and never regresses the saved position.
  Future<void> saveProgress({
    required int collectionId,
    required HadithModel hadith,
  }) async {
    final current = state.progressOf(collectionId);
    if (current != null && current.currentHadithId == hadith.id) return;

    // Optimistic local update so the "Continue" card reflects instantly.
    state = state.copyWith(
      progressByCollection: {
        ...state.progressByCollection,
        collectionId: HadithProgressModel(
          collectionId: collectionId,
          currentHadithId: hadith.id,
          currentPosition: hadith.position,
        ),
      },
    );

    final res = await repo.saveProgress(
      collectionId: collectionId,
      hadithId: hadith.id,
      position: hadith.position,
    );
    res.when(
      (saved) => state = state.copyWith(
        progressByCollection: {...state.progressByCollection, collectionId: saved},
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    // Award ajr once per hadith (server-side idempotent; degrades to no-op).
    await repo.awardHadithAjr(hadithId: hadith.id);
  }

  /// Likes / unlikes [hadith]. Updates the UI immediately (optimistic) and
  /// rolls back if the backend call fails. The global like count lives on the
  /// hadith row, so it's adjusted in [hadithsByCollection] too.
  Future<void> toggleLike(HadithModel hadith) async {
    final wasLiked = state.isHadithLiked(hadith.id);

    _applyLike(hadith, liked: !wasLiked);

    final res = wasLiked
        ? await repo.unlikeHadith(hadith.id)
        : await repo.likeHadith(hadith.id);

    res.when(
      (_) {},
      (error) {
        _applyLike(hadith, liked: wasLiked); // roll back
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  void _applyLike(HadithModel hadith, {required bool liked}) {
    final likes = {...state.likedHadiths};
    final alreadyLiked = likes.contains(hadith.id);
    if (liked) {
      likes.add(hadith.id);
    } else {
      likes.remove(hadith.id);
    }

    // Adjust the cached global count by ±1.
    final byCollection = {...state.hadithsByCollection};
    final list = byCollection[hadith.collectionId];
    if (list != null) {
      byCollection[hadith.collectionId] = [
        for (final h in list)
          if (h.id == hadith.id)
            h.copyWith(
              likesCount: liked && !alreadyLiked
                  ? h.likesCount + 1
                  : (!liked && alreadyLiked
                      ? (h.likesCount - 1).clamp(0, 1 << 31)
                      : h.likesCount),
            )
          else
            h,
      ];
    }

    state = state.copyWith(
      likedHadiths: likes,
      hadithsByCollection: byCollection,
    );
  }
}
