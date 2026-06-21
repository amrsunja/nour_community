import 'package:equatable/equatable.dart';

import '../../data/models/adhkar_category_model.dart';
import '../../data/models/adhkar_model.dart';
import '../../data/models/adhkar_subcategory_model.dart';

/// Hand-written immutable state (no freezed codegen) to keep the feature
/// buildable without running build_runner — mirrors `DhikrState`.
class AdhkarState extends Equatable {
  final bool isLoading;
  final List<AdhkarCategoryModel> categories;
  final List<AdhkarSubcategoryModel> subcategories;

  /// Lazily-loaded adhkars keyed by `subcategoryId` (filled by the detail page).
  final Map<int, List<AdhkarModel>> adhkarsBySubcategory;

  /// Subcategory ids whose adhkars are currently being fetched.
  final Set<int> loadingSubcategoryIds;

  /// Free-text search query against subcategory titles (any language).
  final String query;

  const AdhkarState({
    this.isLoading = false,
    this.categories = const [],
    this.subcategories = const [],
    this.adhkarsBySubcategory = const {},
    this.loadingSubcategoryIds = const {},
    this.query = '',
  });

  bool get isSearching => query.trim().isNotEmpty;

  List<AdhkarSubcategoryModel> subcategoriesOf(int categoryId) =>
      subcategories.where((s) => s.categoryId == categoryId).toList();

  /// Subcategories matching the current [query] across all localized titles.
  List<AdhkarSubcategoryModel> get searchResults {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return subcategories.where((s) {
      return s.titleEn.toLowerCase().contains(q) ||
          s.titleFr.toLowerCase().contains(q) ||
          s.titleAr.toLowerCase().contains(q) ||
          (s.titleDe?.toLowerCase().contains(q) ?? false) ||
          (s.titleNl?.toLowerCase().contains(q) ?? false) ||
          (s.titleTr?.toLowerCase().contains(q) ?? false) ||
          (s.titleId?.toLowerCase().contains(q) ?? false) ||
          (s.titleUr?.toLowerCase().contains(q) ?? false) ||
          (s.titleBn?.toLowerCase().contains(q) ?? false) ||
          (s.titleMs?.toLowerCase().contains(q) ?? false) ||
          (s.titleRu?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  /// The subcategory recommended for [nowMinute] (local wall-clock minutes).
  /// Returns the first windowed match in display order, or null.
  AdhkarSubcategoryModel? recommendedAt(int nowMinute) {
    for (final s in subcategories) {
      if (s.hasRecommendedWindow && s.isRecommendedAt(nowMinute)) return s;
    }
    return null;
  }

  List<AdhkarModel> adhkarsOf(int subcategoryId) =>
      adhkarsBySubcategory[subcategoryId] ?? const [];

  bool isLoadingAdhkars(int subcategoryId) =>
      loadingSubcategoryIds.contains(subcategoryId);

  AdhkarState copyWith({
    bool? isLoading,
    List<AdhkarCategoryModel>? categories,
    List<AdhkarSubcategoryModel>? subcategories,
    Map<int, List<AdhkarModel>>? adhkarsBySubcategory,
    Set<int>? loadingSubcategoryIds,
    String? query,
  }) => AdhkarState(
    isLoading: isLoading ?? this.isLoading,
    categories: categories ?? this.categories,
    subcategories: subcategories ?? this.subcategories,
    adhkarsBySubcategory: adhkarsBySubcategory ?? this.adhkarsBySubcategory,
    loadingSubcategoryIds: loadingSubcategoryIds ?? this.loadingSubcategoryIds,
    query: query ?? this.query,
  );

  @override
  List<Object?> get props => [
    isLoading,
    categories,
    subcategories,
    adhkarsBySubcategory,
    loadingSubcategoryIds,
    query,
  ];
}
