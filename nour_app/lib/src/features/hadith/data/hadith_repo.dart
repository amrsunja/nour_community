import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/hadith_remote_datasource.dart';
import 'models/hadith_collection_model.dart';
import 'models/hadith_model.dart';
import 'models/hadith_progress_model.dart';

final hadithRepoProvider = Provider(
  (ref) => HadithRepo(
    remoteDatasource: ref.read(hadithRemoteDataProvider),
  ),
);

class HadithRepo {
  final HadithRemoteDatasource remoteDatasource;

  HadithRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<HadithCollectionModel>>> getCollections() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getCollections());
  }

  Future<SuccessOrError<List<HadithModel>>> getHadiths(int collectionId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getHadiths(collectionId),
    );
  }

  Future<SuccessOrError<List<HadithProgressModel>>> getProgress() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getProgress());
  }

  Future<SuccessOrError<HadithProgressModel>> saveProgress({
    required int collectionId,
    required int hadithId,
    required int position,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.saveProgress(
        collectionId: collectionId,
        hadithId: hadithId,
        position: position,
      ),
    );
  }

  Future<SuccessOrError<void>> awardHadithAjr({required int hadithId}) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.awardHadithAjr(hadithId: hadithId),
    );
  }

  Future<SuccessOrError<Set<int>>> getLikedHadiths() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getLikedHadiths());
  }

  Future<SuccessOrError<void>> likeHadith(int hadithId) async {
    return Failure.exceptionsCatcher(() => remoteDatasource.likeHadith(hadithId));
  }

  Future<SuccessOrError<void>> unlikeHadith(int hadithId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.unlikeHadith(hadithId),
    );
  }
}
