import 'package:equatable/equatable.dart';

import '../../data/models/impact_project_model.dart';

/// State for a single project detail page.
class ImpactProjectDetailState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final ImpactProjectModel? project;
  final bool isFavorite;

  const ImpactProjectDetailState({
    this.isLoading = false,
    this.hasError = false,
    this.project,
    this.isFavorite = false,
  });

  ImpactProjectDetailState copyWith({
    bool? isLoading,
    bool? hasError,
    ImpactProjectModel? project,
    bool? isFavorite,
  }) => ImpactProjectDetailState(
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
    project: project ?? this.project,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  @override
  List<Object?> get props => [isLoading, hasError, project, isFavorite];
}
