import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import '../../adhkar/data/models/adhkar_model.dart';
import '../../dua/data/models/dua_model.dart';
import '../../impact/data/models/impact_project_model.dart';
import 'datasources/favorites_remote_datasource.dart';
import 'models/favorite_hadith_item.dart';

final favoritesRepoProvider = Provider(
  (ref) => FavoritesRepo(
    remoteDatasource: ref.read(favoritesRemoteDataProvider),
  ),
);

/// Thin repository over [FavoritesRemoteDatasource]; wraps each call in
/// [Failure.exceptionsCatcher] so presenters get a `SuccessOrError`.
class FavoritesRepo {
  final FavoritesRemoteDatasource remoteDatasource;

  FavoritesRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<FavoriteAyahRef>>> getFavoriteAyahs() async {
    return Failure.exceptionsCatcher(remoteDatasource.getFavoriteAyahs);
  }

  Future<SuccessOrError<List<AdhkarModel>>> getFavoriteAdhkars() async {
    return Failure.exceptionsCatcher(remoteDatasource.getFavoriteAdhkars);
  }

  Future<SuccessOrError<List<DuaModel>>> getFavoriteDuas() async {
    return Failure.exceptionsCatcher(remoteDatasource.getFavoriteDuas);
  }

  Future<SuccessOrError<List<FavoriteHadithItem>>> getFavoriteHadiths() async {
    return Failure.exceptionsCatcher(remoteDatasource.getFavoriteHadiths);
  }

  Future<SuccessOrError<List<ImpactProjectModel>>>
  getFavoriteImpactProjects() async {
    return Failure.exceptionsCatcher(
      remoteDatasource.getFavoriteImpactProjects,
    );
  }
}
