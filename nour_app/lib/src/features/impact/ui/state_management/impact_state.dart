import 'package:equatable/equatable.dart';

import '../../data/models/impact_project_model.dart';
import '../../data/models/project_category_model.dart';

/// State for the Impact list page. [categories] always leads with the synthetic
/// "All" tab; [selectedCategoryId] is [ProjectCategoryModel.allId] for it.
/// [favoriteIds] is the set of project ids the user has favourited (drives the
/// heart on every card).
class ImpactState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final List<ProjectCategoryModel> categories;
  final List<ImpactProjectModel> projects;
  final int selectedCategoryId;
  final Set<int> favoriteIds;

  const ImpactState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.categories = const [],
    this.projects = const [],
    this.selectedCategoryId = ProjectCategoryModel.allId,
    this.favoriteIds = const {},
  });

  bool get isEmpty => projects.isEmpty;

  bool isFavorite(int projectId) => favoriteIds.contains(projectId);

  ImpactState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    List<ProjectCategoryModel>? categories,
    List<ImpactProjectModel>? projects,
    int? selectedCategoryId,
    Set<int>? favoriteIds,
  }) => ImpactState(
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
    loaded: loaded ?? this.loaded,
    categories: categories ?? this.categories,
    projects: projects ?? this.projects,
    selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    favoriteIds: favoriteIds ?? this.favoriteIds,
  );

  @override
  List<Object?> get props => [
    isLoading,
    hasError,
    loaded,
    categories,
    projects,
    selectedCategoryId,
    favoriteIds,
  ];
}
