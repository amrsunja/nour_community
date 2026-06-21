import 'package:equatable/equatable.dart';

import '../../data/models/hadith_collection_model.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/hadith_progress_model.dart';

/// Hand-written immutable state (no freezed codegen) — same convention as the
/// quran / dhikr features — so the feature builds without running build_runner.
class HadithState extends Equatable {
  /// True while the initial collections / progress load is in flight.
  final bool isLoading;

  /// True if the initial load failed (drives the error state).
  final bool hasError;

  /// Active collections (with their total-hadith counts).
  final List<HadithCollectionModel> collections;

  /// Reading progress keyed by `collectionId`.
  final Map<int, HadithProgressModel> progressByCollection;

  // ── Per-collection hadiths (lazy, keyed by collection id) ──────────────────

  /// Loaded hadiths per collection (ordered by position).
  final Map<int, List<HadithModel>> hadithsByCollection;

  /// Collection ids whose hadith list is currently loading.
  final Set<int> loadingCollections;

  /// Hadith ids the current user has liked.
  final Set<int> likedHadiths;

  const HadithState({
    this.isLoading = false,
    this.hasError = false,
    this.collections = const [],
    this.progressByCollection = const {},
    this.hadithsByCollection = const {},
    this.loadingCollections = const {},
    this.likedHadiths = const {},
  });

  bool get isEmpty => collections.isEmpty;

  HadithProgressModel? progressOf(int collectionId) =>
      progressByCollection[collectionId];

  List<HadithModel> hadithsOf(int collectionId) =>
      hadithsByCollection[collectionId] ?? const [];

  bool isLoadingCollection(int collectionId) =>
      loadingCollections.contains(collectionId);

  bool isHadithLiked(int hadithId) => likedHadiths.contains(hadithId);

  HadithState copyWith({
    bool? isLoading,
    bool? hasError,
    List<HadithCollectionModel>? collections,
    Map<int, HadithProgressModel>? progressByCollection,
    Map<int, List<HadithModel>>? hadithsByCollection,
    Set<int>? loadingCollections,
    Set<int>? likedHadiths,
  }) =>
      HadithState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        collections: collections ?? this.collections,
        progressByCollection: progressByCollection ?? this.progressByCollection,
        hadithsByCollection: hadithsByCollection ?? this.hadithsByCollection,
        loadingCollections: loadingCollections ?? this.loadingCollections,
        likedHadiths: likedHadiths ?? this.likedHadiths,
      );

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        collections,
        progressByCollection,
        hadithsByCollection,
        loadingCollections,
        likedHadiths,
      ];
}
