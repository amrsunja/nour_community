import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/models/ayah_model.dart';
import '../../data/models/quran_progress_model.dart';
import '../../data/quran_repo.dart';
import 'quran_state.dart';

final quranProvider = StateNotifierProvider<QuranPresenter, QuranState>((ref) {
  return QuranPresenter(
    repo: ref.read(quranRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class QuranPresenter extends Presenter<QuranState> {
  final QuranRepo repo;
  final AppEvents appEvents;

  QuranPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const QuranState());

  /// Loads the surah catalogue (synchronous, bundled) and the user's reading
  /// position. Safe to call repeatedly — it no-ops once data is present.
  Future<void> init() async {
    if (state.surahs.isNotEmpty && state.progress != null) return;

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final surahs = repo.getSurahs();
      state = state.copyWith(surahs: surahs);
    } catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
      return;
    }

    final progressRes = await repo.getProgress();
    progressRes.when(
      (progress) => state = state.copyWith(progress: progress),
      (error) {
        // Reading still works from the start; surface the error but don't block.
        state = state.copyWith(progress: QuranProgressModel.initial);
        appEvents.send(ShowErrorEvent(error));
      },
    );

    state = state.copyWith(isLoading: false);
  }

  Future<void> retry() async {
    state = const QuranState();
    await init();
  }

  // ── Bundled Quran content (synchronous pass-throughs to the repo) ────────────
  // Exposed here so the UI layer talks only to the presenter, never the repo.

  SurahInfo getSurah(int surahNumber) => repo.getSurah(surahNumber);

  List<AyahModel> getSurahAyahs(int surahNumber, {required String langCode}) =>
      repo.getSurahAyahs(surahNumber, langCode: langCode);

  AyahModel getAyah(
    int surahNumber,
    int ayahNumber, {
    required String langCode,
  }) =>
      repo.getAyah(surahNumber, ayahNumber, langCode: langCode);

  /// Verse of the day (deterministic per UTC day, computed locally).
  AyahModel getDailyAyah({required String langCode}) =>
      repo.getDailyAyah(langCode: langCode);

  String ayahAudioUrl(
    int surahNumber,
    int ayahNumber, {
    required ReciterType reciter,
  }) =>
      repo.audioUrl(surahNumber, ayahNumber, reciter: reciter);

  /// Lazily fetches the transliteration for [surahNumber] once per edition and
  /// caches it under `"surah:edition"`. The bundled `quran` package has no
  /// transliteration, so this pulls the locale's edition (resolved by
  /// [QuranTool.transliterationEditionForLanguage]) from the public Quran API.
  /// Arabic readers need none (edition `null`). Failures are swallowed — the
  /// reader falls back to a label.
  Future<void> loadSurahTransliteration(
    int surahNumber, {
    required String langCode,
  }) async {
    final edition = QuranTool.transliterationEditionForLanguage(langCode);
    if (edition == null) return; // Arabic — verse already in Arabic.

    final key = '$surahNumber:$edition';
    if (state.transliterationsByKey.containsKey(key)) return;
    if (state.isLoadingTransliteration(surahNumber, edition)) return;

    state = state.copyWith(
      loadingTransliterationKeys: {...state.loadingTransliterationKeys, key},
    );

    final res = await repo.getSurahTransliteration(surahNumber, edition: edition);

    res.when(
      (map) {
        state = state.copyWith(
          transliterationsByKey: {...state.transliterationsByKey, key: map},
        );
      },
      (_) {/* silent: graceful fallback in the UI */},
    );

    state = state.copyWith(
      loadingTransliterationKeys: {...state.loadingTransliterationKeys}
        ..remove(key),
    );
  }

  /// Lazily fetches the tafsir for a single ayah in the locale's edition
  /// (resolved by [QuranTool.tafsirEditionForLanguage]) and caches it under
  /// `"surah:ayah:edition"`. No-ops when no tafsir edition exists for the
  /// locale — the UI then shows the meaning fallback. Failures are swallowed.
  Future<void> loadAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    required String langCode,
  }) async {
    final edition = QuranTool.tafsirEditionForLanguage(langCode);
    if (edition == null) return; // No tafsir published for this locale.

    final key = '$surahNumber:$ayahNumber:$edition';
    if (state.tafsirByKey.containsKey(key)) return;
    if (state.isLoadingTafsir(surahNumber, ayahNumber, edition)) return;

    state = state.copyWith(
      loadingTafsirKeys: {...state.loadingTafsirKeys, key},
    );

    final res = await repo.getAyahTafsir(surahNumber, ayahNumber, edition: edition);

    res.when(
      (text) {
        if (text != null && text.isNotEmpty) {
          state = state.copyWith(
            tafsirByKey: {...state.tafsirByKey, key: text},
          );
        }
      },
      (_) {/* silent: graceful fallback in the UI */},
    );

    state = state.copyWith(
      loadingTafsirKeys: {...state.loadingTafsirKeys}..remove(key),
    );
  }

  // ── Daily Ayah ─────────────────────────────────────────────────────────────

  /// Loads the all-time ayah ajr total + whether today's ayah is already done.
  /// Called when the Daily Ayah page opens.
  Future<void> loadDailyAyahStatus() async {
    state = state.copyWith(isLoadingDailyAyah: true);

    final res = await repo.getDailyAyahStatus();
    res.when(
      (status) => state = state.copyWith(
        dailyAyahTotalAjr: status.totalAjr,
        dailyAyahDoneToday: status.doneToday,
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoadingDailyAyah: false);
  }

  /// Awards the daily ayah ajr (server-side idempotent per UTC day) and syncs
  /// the all-time total. No-ops if already completed today.
  Future<void> completeDailyAyah() async {
    if (state.dailyAyahDoneToday) return;

    state = state.copyWith(isLoadingDailyAyah: true);

    final res = await repo.awardDailyAyahAjr(ajr: state.dailyAyahEarnableAjr);
    res.when(
      (total) => state = state.copyWith(
        dailyAyahTotalAjr: total,
        dailyAyahDoneToday: true,
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoadingDailyAyah: false);
  }

  // ── Reading progress ───────────────────────────────────────────────────────

  /// Persists the "continue reading" position. Called on "I'm done", on leaving
  /// the surah screen, and when popping the ayah reader. Skips the round-trip
  /// when nothing changed.
  Future<void> saveProgress({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final current = state.progress;
    if (current != null &&
        current.surahNumber == surahNumber &&
        current.ayahNumber == ayahNumber) {
      return;
    }

    // Optimistic local update so the "Continue reading" card reflects instantly.
    state = state.copyWith(
      progress: QuranProgressModel(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
    );

    final res = await repo.saveProgress(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    res.when(
      (saved) => state = state.copyWith(progress: saved),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }

  // ── Likes / favorites ────────────────────────────────────────────────────────

  /// Loads the current user's likes + global counts for [surahNumber] once.
  Future<void> loadSurahLikes(int surahNumber) async {
    if (state.likedAyahsBySurah.containsKey(surahNumber)) return;
    if (state.isLoadingLikes(surahNumber)) return;

    state = state.copyWith(
      loadingLikesSurahs: {...state.loadingLikesSurahs, surahNumber},
    );

    final likedRes = await repo.getLikedAyahs(surahNumber);
    final countsRes = await repo.getSurahLikeCounts(surahNumber);

    likedRes.when(
      (liked) {
        state = state.copyWith(
          likedAyahsBySurah: {...state.likedAyahsBySurah, surahNumber: liked},
        );
      },
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    countsRes.when(
      (counts) {
        state = state.copyWith(
          likeCountsBySurah: {...state.likeCountsBySurah, surahNumber: counts},
        );
      },
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(
      loadingLikesSurahs: {...state.loadingLikesSurahs}..remove(surahNumber),
    );
  }

  /// Likes / unlikes [ayahNumber]. The UI updates immediately (optimistic) and
  /// rolls back if the backend call fails.
  Future<void> toggleLike({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final wasLiked = state.isAyahLiked(surahNumber, ayahNumber);

    _applyLike(surahNumber, ayahNumber, liked: !wasLiked);

    final res = wasLiked
        ? await repo.unlikeAyah(surahNumber: surahNumber, ayahNumber: ayahNumber)
        : await repo.likeAyah(surahNumber: surahNumber, ayahNumber: ayahNumber);

    res.when(
      (_) {},
      (error) {
        // Roll back the optimistic change.
        _applyLike(surahNumber, ayahNumber, liked: wasLiked);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  /// Sets the like flag for an ayah and adjusts the local count by ±1.
  void _applyLike(int surahNumber, int ayahNumber, {required bool liked}) {
    final lia = {...state.likedAyahsBySurah};
    final set = {...(lia[surahNumber] ?? <int>{})};
    final alreadyLiked = set.contains(ayahNumber);
    if (liked) {
      set.add(ayahNumber);
    } else {
      set.remove(ayahNumber);
    }
    lia[surahNumber] = set;

    final counts = {...state.likeCountsBySurah};
    final surahCounts = {...(counts[surahNumber] ?? <int, int>{})};
    final base = surahCounts[ayahNumber] ?? 0;
    if (liked && !alreadyLiked) {
      surahCounts[ayahNumber] = base + 1;
    } else if (!liked && alreadyLiked) {
      surahCounts[ayahNumber] = (base - 1).clamp(0, 1 << 31);
    }
    counts[surahNumber] = surahCounts;

    state = state.copyWith(
      likedAyahsBySurah: lia,
      likeCountsBySurah: counts,
    );
  }
}
