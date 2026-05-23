import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/adhkar_remote_datasource.dart';
import 'models/adhkar_category_model.dart';
import 'models/adhkar_model.dart';
import 'models/adhkar_subcategory_model.dart';

final adhkarRepoProvider = Provider(
  (ref) => AdhkarRepo(
    remoteDatasource: ref.read(adhkarRemoteDataProvider),
  ),
);

class AdhkarRepo {
  final AdhkarRemoteDatasource remoteDatasource;

  AdhkarRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<AdhkarCategoryModel>>> getCategories() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getCategories();
    });
  }

  Future<SuccessOrError<List<AdhkarSubcategoryModel>>> getSubcategories() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getSubcategories();
    });
  }

  Future<SuccessOrError<List<AdhkarModel>>> getAdhkars(int subcategoryId) async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getAdhkarsBySubcategory(subcategoryId);
    });
  }
}
