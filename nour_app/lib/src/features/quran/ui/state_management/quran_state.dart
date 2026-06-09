import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';

import '../../data/models/quran_progress_model.dart';

/// Hand-written immutable state (no freezed codegen) — same convention as the
/// dhikr feature — so the feature builds without running build_runner.
class QuranState extends Equatable {
  /// True while the initial surah list / progress load is in flight.
  final bool isLoading;

  /// Bundled surah catalogue (loaded synchronously from [QuranTool]).
  final List<SurahInfo> surahs;

  /// The user's "continue reading" position.
  final QuranProgressModel? progress;

  /// True if the initial load failed (drives the error state).
  final bool hasError;

  // ── Per-surah likes (lazy, keyed by surah number) ────────────────────────────

  /// Ayah numbers the current user has liked, per surah.
  final Map<int, Set<int>> likedAyahsBySurah;

  /// Global like counts (`{ayahNumber: count}`), per surah.
  final Map<int, Map<int, int>> likeCountsBySurah;

  /// Surah numbers whose like data is currently loading.
  final Set<int> loadingLikesSurahs;

  /// Transliteration per surah, keyed by `"surah:edition"` so a locale change
  /// (different edition) fetches its own copy instead of reusing a stale one.
  /// Value is `{ayah: text}`.
  final Map<String, Map<int, String>> transliterationsByKey;

  /// `"surah:edition"` keys whose transliteration is currently loading.
  final Set<String> loadingTransliterationKeys;

  /// Tafsir per ayah, keyed by `"surah:ayah:edition"`. Lazily fetched; absent
  /// when no tafsir is published for the locale.
  final Map<String, String> tafsirByKey;

  /// `"surah:ayah:edition"` keys whose tafsir is currently loading.
  final Set<String> loadingTafsirKeys;

  // ── Daily Ayah ───────────────────────────────────────────────────────────

  /// Ajr awarded for completing the Daily Ayah (the "+N" shown before done).
  final int dailyAyahEarnableAjr;

  /// All-time ajr the user has earned from ayahs (source = 'ayah').
  final int dailyAyahTotalAjr;

  /// Whether today's ayah was already completed (button disabled afterwards).
  final bool dailyAyahDoneToday;

  /// True while the daily ayah status / award round-trip is in flight.
  final bool isLoadingDailyAyah;

  const QuranState({
    this.isLoading = false,
    this.surahs = const [],
    this.progress,
    this.hasError = false,
    this.likedAyahsBySurah = const {},
    this.likeCountsBySurah = const {},
    this.loadingLikesSurahs = const {},
    this.transliterationsByKey = const {},
    this.loadingTransliterationKeys = const {},
    this.tafsirByKey = const {},
    this.loadingTafsirKeys = const {},
    this.dailyAyahEarnableAjr = 5,
    this.dailyAyahTotalAjr = 0,
    this.dailyAyahDoneToday = false,
    this.isLoadingDailyAyah = false,
  });

  bool get isEmpty => surahs.isEmpty;

  bool isAyahLiked(int surahNumber, int ayahNumber) =>
      likedAyahsBySurah[surahNumber]?.contains(ayahNumber) ?? false;

  int ayahLikeCount(int surahNumber, int ayahNumber) =>
      likeCountsBySurah[surahNumber]?[ayahNumber] ?? 0;

  bool isLoadingLikes(int surahNumber) =>
      loadingLikesSurahs.contains(surahNumber);

  /// Transliteration for a single ayah in [edition], or `null` if not loaded /
  /// unavailable (e.g. Arabic locale, where [edition] is `null`).
  String? transliterationOf(int surahNumber, int ayahNumber, String? edition) {
    if (edition == null) return null;
    return transliterationsByKey['$surahNumber:$edition']?[ayahNumber];
  }

  bool isLoadingTransliteration(int surahNumber, String? edition) =>
      edition != null &&
      loadingTransliterationKeys.contains('$surahNumber:$edition');

  /// Tafsir for a single ayah in [edition], or `null` if not loaded / no tafsir
  /// exists for the locale (edition `null`).
  String? tafsirOf(int surahNumber, int ayahNumber, String? edition) {
    if (edition == null) return null;
    return tafsirByKey['$surahNumber:$ayahNumber:$edition'];
  }

  bool isLoadingTafsir(int surahNumber, int ayahNumber, String? edition) =>
      edition != null &&
      loadingTafsirKeys.contains('$surahNumber:$ayahNumber:$edition');

  QuranState copyWith({
    bool? isLoading,
    List<SurahInfo>? surahs,
    QuranProgressModel? progress,
    bool? hasError,
    Map<int, Set<int>>? likedAyahsBySurah,
    Map<int, Map<int, int>>? likeCountsBySurah,
    Set<int>? loadingLikesSurahs,
    Map<String, Map<int, String>>? transliterationsByKey,
    Set<String>? loadingTransliterationKeys,
    Map<String, String>? tafsirByKey,
    Set<String>? loadingTafsirKeys,
    int? dailyAyahEarnableAjr,
    int? dailyAyahTotalAjr,
    bool? dailyAyahDoneToday,
    bool? isLoadingDailyAyah,
  }) =>
      QuranState(
        isLoading: isLoading ?? this.isLoading,
        surahs: surahs ?? this.surahs,
        progress: progress ?? this.progress,
        hasError: hasError ?? this.hasError,
        likedAyahsBySurah: likedAyahsBySurah ?? this.likedAyahsBySurah,
        likeCountsBySurah: likeCountsBySurah ?? this.likeCountsBySurah,
        loadingLikesSurahs: loadingLikesSurahs ?? this.loadingLikesSurahs,
        transliterationsByKey:
            transliterationsByKey ?? this.transliterationsByKey,
        loadingTransliterationKeys:
            loadingTransliterationKeys ?? this.loadingTransliterationKeys,
        tafsirByKey: tafsirByKey ?? this.tafsirByKey,
        loadingTafsirKeys: loadingTafsirKeys ?? this.loadingTafsirKeys,
        dailyAyahEarnableAjr: dailyAyahEarnableAjr ?? this.dailyAyahEarnableAjr,
        dailyAyahTotalAjr: dailyAyahTotalAjr ?? this.dailyAyahTotalAjr,
        dailyAyahDoneToday: dailyAyahDoneToday ?? this.dailyAyahDoneToday,
        isLoadingDailyAyah: isLoadingDailyAyah ?? this.isLoadingDailyAyah,
      );

  @override
  List<Object?> get props => [
        isLoading,
        surahs,
        progress,
        hasError,
        likedAyahsBySurah,
        likeCountsBySurah,
        loadingLikesSurahs,
        transliterationsByKey,
        loadingTransliterationKeys,
        tafsirByKey,
        loadingTafsirKeys,
        dailyAyahEarnableAjr,
        dailyAyahTotalAjr,
        dailyAyahDoneToday,
        isLoadingDailyAyah,
      ];
}
