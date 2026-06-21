import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/quran_local_datasource.dart';
import 'datasources/quran_remote_datasource.dart';
import 'models/ayah_model.dart';
import 'models/daily_ayah_status_model.dart';
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

  List<AyahModel> getSurahAyahs(int surahNumber, {required String langCode}) =>
      localDatasource.getSurahAyahs(surahNumber, langCode: langCode);

  AyahModel getAyah(
    int surahNumber,
    int ayahNumber, {
    required String langCode,
  }) =>
      localDatasource.getAyah(surahNumber, ayahNumber, langCode: langCode);

  AyahModel getDailyAyah({required String langCode}) =>
      localDatasource.getDailyAyah(langCode: langCode);

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

  Future<SuccessOrError<DailyAyahStatusModel>> getDailyAyahStatus() async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getDailyAyahStatus(),
    );
  }

  Future<SuccessOrError<int>> awardDailyAyahAjr({int ajr = 5}) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.awardDailyAyahAjr(ajr: ajr),
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

  Future<SuccessOrError<Map<int, String>>> getSurahTransliteration(
    int surahNumber, {
    String edition = 'en.transliteration',
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getSurahTransliteration(surahNumber, edition: edition),
    );
  }

  Future<SuccessOrError<String?>> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    required String edition,
  }) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getAyahTafsir(
        surahNumber,
        ayahNumber,
        edition: edition,
      ),
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
