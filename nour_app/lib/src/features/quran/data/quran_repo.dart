import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/quran_local_datasource.dart';
import 'datasources/quran_remote_datasource.dart';
import 'models/ayah_model.dart';
import 'models/quran_progress_model.dart';

final quranRepoProvider = Provider(
  (ref) => QuranRepo(
    localDatasource: ref.read(quranLocalDataProvider),
    remoteDatasource: ref.read(quranRemoteDataProvider),
  ),
);

class QuranRepo {
  final QuranLocalDatasource localDatasource;
  final QuranRemoteDatasource remoteDatasource;

  QuranRepo({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  // ── Local (bundled) Quran content — synchronous, never fails. ───────────────

  List<SurahInfo> getSurahs() => localDatasource.getSurahs();

  SurahInfo getSurah(int surahNumber) => localDatasource.getSurah(surahNumber);

  List<AyahModel> getSurahAyahs(int surahNumber) =>
      localDatasource.getSurahAyahs(surahNumber);

  AyahModel getAyah(int surahNumber, int ayahNumber) =>
      localDatasource.getAyah(surahNumber, ayahNumber);

  String audioUrl(
    int surahNumber,
    int ayahNumber, {
    required ReciterType reciter,
  }) =>
      localDatasource.audioUrl(surahNumber, ayahNumber, reciter: reciter);

  // ── Remote (per-user) — wrapped in Failure for the presenter. ───────────────

  Future<SuccessOrError<QuranProgressModel>> getProgress() async {
    return Failure.exceptionsCatcher(() => remoteDatasource.getProgress());
  }

  Future<SuccessOrError<QuranProgressModel>> saveProgress({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.saveProgress(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
    );
  }

  Future<SuccessOrError<Set<int>>> getLikedAyahs(int surahNumber) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getLikedAyahs(surahNumber),
    );
  }

  Future<SuccessOrError<Map<int, int>>> getSurahLikeCounts(
    int surahNumber,
  ) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getSurahLikeCounts(surahNumber),
    );
  }

  Future<SuccessOrError<void>> likeAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.likeAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
    );
  }

  Future<SuccessOrError<void>> unlikeAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.unlikeAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
    );
  }
}
