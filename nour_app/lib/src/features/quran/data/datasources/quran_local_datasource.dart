import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';

import '../models/ayah_model.dart';

final quranLocalDataProvider = Provider((ref) => const QuranLocalDatasource());

/// Read-only access to the bundled Quran text (surah metadata, ayahs, audio
/// URLs). Thin wrapper over [QuranTool] so the repository depends on this
/// datasource rather than the package facade directly.
class QuranLocalDatasource {
  const QuranLocalDatasource();

  List<SurahInfo> getSurahs() => QuranTool.getAllSurahs();

  SurahInfo getSurah(int surahNumber) => QuranTool.getSurah(surahNumber);

  int versesCountOf(int surahNumber) => QuranTool.getVersesCount(surahNumber);

  /// All ayahs of [surahNumber] with localized translation.
  List<AyahModel> getSurahAyahs(int surahNumber) {
    final count = QuranTool.getVersesCount(surahNumber);
    return [
      for (int v = 1; v <= count; v++) getAyah(surahNumber, v),
    ];
  }

  AyahModel getAyah(int surahNumber, int ayahNumber) {
    final verse = QuranTool.getVerse(surahNumber, ayahNumber);
    return AyahModel(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      arabicText: verse.text,
      translation: QuranTool.getVerseTranslation(surahNumber, ayahNumber),
      juzNumber: verse.juzNumber,
      pageNumber: verse.pageNumber,
    );
  }

  /// Deterministic verse of the day (stable for the whole UTC day).
  AyahModel getDailyAyah() {
    final verse = QuranTool.getDailyVerse();
    return getAyah(verse.surahNumber, verse.verseNumber);
  }

  /// Network audio URL for [surahNumber]:[ayahNumber] using the user's
  /// selected [reciter].
  String audioUrl(
    int surahNumber,
    int ayahNumber, {
    required ReciterType reciter,
  }) =>
      QuranTool.getVerseAudioUrl(surahNumber, ayahNumber, reciter: reciter);
}
