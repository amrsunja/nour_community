import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/dua_repo.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/dua_progress_model.dart';
import 'dua_state.dart';

final duaProvider = StateNotifierProvider<DuaPresenter, DuaState>((ref) {
  return DuaPresenter(
    repo: ref.read(duaRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class DuaPresenter extends Presenter<DuaState> {
  final DuaRepo repo;
  final AppEvents appEvents;

  DuaPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const DuaState());

  /// Loads the dua library + the user's reading progress and liked duas.
  /// Safe to call repeatedly — no-ops once the library is present.
  Future<void> init() async {
    if (state.library.isNotEmpty) return;

    state = state.copyWith(isLoading: true, hasError: false);

    final duasRes = await repo.getDuas();
    duasRes.when(
      (duas) => state = state.copyWith(library: duas),
      (error) {
        state = state.copyWith(isLoading: false, hasError: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );

    if (state.hasError) return;

    final progressRes = await repo.getProgress();
    progressRes.when(
      (progress) => state = state.copyWith(progress: progress),
      (error) {
        state = state.copyWith(progress: DuaProgressModel.empty);
        appEvents.send(ShowErrorEvent(error));
      },
    );

    final likedRes = await repo.getLikedDuas();
    likedRes.when(
      (liked) => state = state.copyWith(likedDuas: liked),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoading: false);
  }

  Future<void> retry() async {
    state = const DuaState();
    await init();
  }

  /// Dua of the day: a deterministic pick from the library per UTC day, so the
  /// Daily Dua page is stable across the day and across devices.
  DuaModel? getDailyDua() {
    if (state.library.isEmpty) return null;
    final epochDay =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 86400000);
    return state.library[epochDay % state.library.length];
  }

  /// Persists the reading position. Called on every dua change in the reader,
  /// on "I'm done", and on leaving the page. Skips the round-trip when nothing
  /// changed, and awards ajr once per dua (server-side idempotent).
  Future<void> saveProgress(DuaModel dua) async {
    final current = state.progress;
    if (current != null && current.currentDuaId == dua.id) return;

    // Optimistic local update so the "Continue" card reflects instantly.
    state = state.copyWith(
      progress: DuaProgressModel(
        currentDuaId: dua.id,
        currentPosition: state.positionOf(dua.id),
      ),
    );

    final res = await repo.saveProgress(duaId: dua.id);
    res.when(
      (saved) => state = state.copyWith(progress: saved),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    // Award ajr once per dua (server-side idempotent; degrades to no-op).
    await repo.awardDuaAjr(duaId: dua.id);
  }

  // ── Daily Dua ─────────────────────────────────────────────────────────────

  /// Loads the all-time dua ajr total + whether today's daily dua is done.
  Future<void> loadDailyDuaStatus() async {
    state = state.copyWith(isLoadingDailyDua: true);

    final res = await repo.getDailyDuaStatus();
    res.when(
      (status) => state = state.copyWith(
        dailyDuaTotalAjr: status.totalAjr,
        dailyDuaDoneToday: status.doneToday,
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoadingDailyDua: false);
  }

  /// Awards the daily dua ajr (server-side idempotent per UTC day) and syncs the
  /// all-time total. No-ops if already completed today.
  Future<void> completeDailyDua() async {
    if (state.dailyDuaDoneToday) return;

    state = state.copyWith(isLoadingDailyDua: true);

    final res = await repo.awardDailyDuaAjr(ajr: state.dailyDuaEarnableAjr);
    res.when(
      (total) => state = state.copyWith(
        dailyDuaTotalAjr: total,
        dailyDuaDoneToday: true,
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoadingDailyDua: false);
  }

  // ── Likes / favorites ────────────────────────────────────────────────────

  /// Likes / unlikes [dua]. Updates the UI immediately (optimistic) and rolls
  /// back if the backend call fails. The global like count lives on the dua
  /// row, so it's adjusted in [DuaState.library] too.
  Future<void> toggleLike(DuaModel dua) async {
    final wasLiked = state.isDuaLiked(dua.id);

    _applyLike(dua, liked: !wasLiked);

    final res = wasLiked
        ? await repo.unlikeDua(dua.id)
        : await repo.likeDua(dua.id);

    res.when(
      (_) {},
      (error) {
        _applyLike(dua, liked: wasLiked); // roll back
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  void _applyLike(DuaModel dua, {required bool liked}) {
    final likes = {...state.likedDuas};
    final alreadyLiked = likes.contains(dua.id);
    if (liked) {
      likes.add(dua.id);
    } else {
      likes.remove(dua.id);
    }

    // Adjust the cached global count by ±1.
    final library = [
      for (final d in state.library)
        if (d.id == dua.id)
          d.copyWith(
            likesCount: liked && !alreadyLiked
                ? d.likesCount + 1
                : (!liked && alreadyLiked
                    ? (d.likesCount - 1).clamp(0, 1 << 31)
                    : d.likesCount),
          )
        else
          d,
    ];

    state = state.copyWith(likedDuas: likes, library: library);
  }
}
