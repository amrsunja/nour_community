import 'package:equatable/equatable.dart';

import '../../../../../impact/data/models/impact_project_model.dart';

/// See [FavoriteAyahsState] for the [loaded] / refresh convention.
class FavoriteImpactProjectsState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final List<ImpactProjectModel> items;

  const FavoriteImpactProjectsState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  FavoriteImpactProjectsState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    List<ImpactProjectModel>? items,
  }) => FavoriteImpactProjectsState(
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
    loaded: loaded ?? this.loaded,
    items: items ?? this.items,
  );

  @override
  List<Object?> get props => [isLoading, hasError, loaded, items];
}
