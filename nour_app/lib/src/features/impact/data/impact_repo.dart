import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/impact_remote_datasource.dart';
import 'models/impact_project_model.dart';
import 'models/project_category_model.dart';

final impactRepoProvider = Provider(
  (ref) => ImpactRepo(remoteDatasource: ref.read(impactRemoteDataProvider)),
);

/// Thin repository over [ImpactRemoteDatasource]; wraps each call in
/// [Failure.exceptionsCatcher] so presenters get a `SuccessOrError`.
class ImpactRepo {
  final ImpactRemoteDatasource remoteDatasource;

  ImpactRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<ProjectCategoryModel>>> getCategories() async {
    return Failure.exceptionsCatcher(remoteDatasource.getCategories);
  }

  Future<SuccessOrError<List<ImpactProjectModel>>> getProjects({
    int? categoryId,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getProjects(categoryId: categoryId),
    );
  }

  Future<SuccessOrError<ImpactProjectModel>> getProjectDetail(
    int projectId,
  ) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getProjectDetail(projectId),
    );
  }

  Future<SuccessOrError<Set<int>>> getFavoriteProjectIds() async {
    return Failure.exceptionsCatcher(remoteDatasource.getFavoriteProjectIds);
  }

  Future<SuccessOrError<List<ImpactProjectModel>>> getFavoriteProjects() async {
    return Failure.exceptionsCatcher(remoteDatasource.getFavoriteProjects);
  }

  Future<SuccessOrError<void>> addFavorite(int projectId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.addFavorite(projectId),
    );
  }

  Future<SuccessOrError<void>> removeFavorite(int projectId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.removeFavorite(projectId),
    );
  }
}
