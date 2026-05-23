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

  const QuranState({
    this.isLoading = false,
    this.surahs = const [],
    this.progress,
    this.hasError = false,
    this.likedAyahsBySurah = const {},
    this.likeCountsBySurah = const {},
    this.loadingLikesSurahs = const {},
  });

  bool get isEmpty => surahs.isEmpty;

  bool isAyahLiked(int surahNumber, int ayahNumber) =>
      likedAyahsBySurah[surahNumber]?.contains(ayahNumber) ?? false;

  int ayahLikeCount(int surahNumber, int ayahNumber) =>
      likeCountsBySurah[surahNumber]?[ayahNumber] ?? 0;

  bool isLoadingLikes(int surahNumber) =>
      loadingLikesSurahs.contains(surahNumber);

  QuranState copyWith({
    bool? isLoading,
    List<SurahInfo>? surahs,
    QuranProgressModel? progress,
    bool? hasError,
    Map<int, Set<int>>? likedAyahsBySurah,
    Map<int, Map<int, int>>? likeCountsBySurah,
    Set<int>? loadingLikesSurahs,
  }) =>
      QuranState(
        isLoading: isLoading ?? this.isLoading,
        surahs: surahs ?? this.surahs,
        progress: progress ?? this.progress,
        hasError: hasError ?? this.hasError,
        likedAyahsBySurah: likedAyahsBySurah ?? this.likedAyahsBySurah,
        likeCountsBySurah: likeCountsBySurah ?? this.likeCountsBySurah,
        loadingLikesSurahs: loadingLikesSurahs ?? this.loadingLikesSurahs,
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
      ];
}
