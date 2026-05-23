import 'dart:math';

import 'package:quran/quran.dart' as q;

import '../enums/reciter_type.dart';

enum RevelationPlace { makkah, madinah }

/// Lightweight surah descriptor.
class SurahInfo {
  final int number;
  final String name;
  final String nameArabic;
  final String nameEnglish;
  final int versesCount;
  final RevelationPlace place;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameEnglish,
    required this.versesCount,
    required this.place,
  });

  bool get isMakki => place == RevelationPlace.makkah;
  bool get isMadani => place == RevelationPlace.madinah;
}

/// Single verse descriptor.
class VerseInfo {
  final int surahNumber;
  final int verseNumber;
  final String text;
  final String textWithoutSymbols;
  final int juzNumber;
  final int pageNumber;

  const VerseInfo({
    required this.surahNumber,
    required this.verseNumber,
    required this.text,
    required this.textWithoutSymbols,
    required this.juzNumber,
    required this.pageNumber,
  });
}

/// Facade over the `quran` package. Centralises all read-only Quran access
/// (surah metadata, verse text, audio URLs) so callers don't depend on the
/// upstream API directly.
class QuranTool {
  const QuranTool._();

  // ── Constants ─────────────────────────────────────────────────────────────

  static int get totalSurahs => q.totalSurahCount;
  static int get totalVerses => q.totalVerseCount;
  static int get totalJuz => q.totalJuzCount;
  static int get totalPages => q.totalPagesCount;
  static int get totalMakkiSurahs => q.totalMakkiSurahs;
  static int get totalMadaniSurahs => q.totalMadaniSurahs;
  static String get basmala => q.basmala;

  // ── Surah metadata ────────────────────────────────────────────────────────

  static SurahInfo getSurah(int surahNumber) {
    _assertSurah(surahNumber);
    return SurahInfo(
      number: surahNumber,
      name: q.getSurahName(surahNumber),
      nameArabic: q.getSurahNameArabic(surahNumber),
      nameEnglish: q.getSurahNameEnglish(surahNumber),
      versesCount: q.getVerseCount(surahNumber),
      place: q.getPlaceOfRevelation(surahNumber).toLowerCase() == 'makkah'
          ? RevelationPlace.makkah
          : RevelationPlace.madinah,
    );
  }

  static List<SurahInfo> getAllSurahs() => [
        for (int i = 1; i <= q.totalSurahCount; i++) getSurah(i),
      ];

  static int getVersesCount(int surahNumber) {
    _assertSurah(surahNumber);
    return q.getVerseCount(surahNumber);
  }

  // ── Verses ────────────────────────────────────────────────────────────────

  static VerseInfo getVerse(
    int surahNumber,
    int verseNumber, {
    bool verseEndSymbol = true,
  }) {
    _assertVerse(surahNumber, verseNumber);
    return VerseInfo(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      text: q.getVerse(surahNumber, verseNumber, verseEndSymbol: verseEndSymbol),
      textWithoutSymbols:
          q.getVerse(surahNumber, verseNumber, verseEndSymbol: false),
      juzNumber: q.getJuzNumber(surahNumber, verseNumber),
      pageNumber: q.getPageNumber(surahNumber, verseNumber),
    );
  }

  static String getVerseTranslation(
    int surahNumber,
    int verseNumber, {
    q.Translation translation = q.Translation.enSaheeh,
  }) {
    _assertVerse(surahNumber, verseNumber);
    return q.getVerseTranslation(
      surahNumber,
      verseNumber,
      translation: translation,
    );
  }

  static List<VerseInfo> getSurahVerses(int surahNumber) {
    _assertSurah(surahNumber);
    final count = q.getVerseCount(surahNumber);
    return [
      for (int v = 1; v <= count; v++) getVerse(surahNumber, v),
    ];
  }

  /// Random verse — useful for the "Daily Ayah" feature.
  static VerseInfo getRandomVerse() {
    final r = q.RandomVerse();
    return VerseInfo(
      surahNumber: r.surahNumber,
      verseNumber: r.verseNumber,
      text: r.verse,
      textWithoutSymbols: r.verse,
      juzNumber: q.getJuzNumber(r.surahNumber, r.verseNumber),
      pageNumber: q.getPageNumber(r.surahNumber, r.verseNumber),
    );
  }

  /// Deterministic "verse of the day": the same verse for every call within a
  /// single UTC day, reshuffled the next day. Seeding [Random] with the day
  /// ordinal makes it stable across app restarts without persisting anything.
  /// Pass [date] to override (testing / previews).
  static VerseInfo getDailyVerse({DateTime? date}) {
    final day = (date ?? DateTime.now()).toUtc();
    final seed = DateTime.utc(day.year, day.month, day.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final rng = Random(seed);

    final surah = 1 + rng.nextInt(q.totalSurahCount);
    final verse = 1 + rng.nextInt(q.getVerseCount(surah));
    return getVerse(surah, verse);
  }

  static bool isSajdahVerse(int surahNumber, int verseNumber) =>
      q.isSajdahVerse(surahNumber, verseNumber);

  // ── Juz / Page ────────────────────────────────────────────────────────────

  static int getJuzNumber(int surahNumber, int verseNumber) =>
      q.getJuzNumber(surahNumber, verseNumber);

  static int getPageNumber(int surahNumber, int verseNumber) =>
      q.getPageNumber(surahNumber, verseNumber);

  // ── Audio URLs ────────────────────────────────────────────────────────────

  static String getVerseAudioUrl(
    int surahNumber,
    int verseNumber, {
    ReciterType reciter = ReciterType.defaultReciter,
    int bitrate = 128,
  }) {
    _assertVerse(surahNumber, verseNumber);
    return q.getAudioURLByVerse(
      surahNumber,
      verseNumber,
      reciter: reciter.reciter,
      bitrate: bitrate,
    );
  }

  static String getSurahAudioUrl(
    int surahNumber, {
    ReciterType reciter = ReciterType.defaultReciter,
    int bitrate = 128,
  }) {
    _assertSurah(surahNumber);
    return q.getAudioURLBySurah(
      surahNumber,
      reciter: reciter.reciter,
      bitrate: bitrate,
    );
  }

  /// Quick preview URL — first verse of Al-Fatiha for the given reciter.
  /// Used for previewing a reciter's voice on the selection screen.
  static String getReciterPreviewUrl(ReciterType reciter) =>
      getVerseAudioUrl(1, 1, reciter: reciter);

  // ── Guards ────────────────────────────────────────────────────────────────

  static void _assertSurah(int n) {
    if (n < 1 || n > q.totalSurahCount) {
      throw RangeError('Surah $n out of range [1..${q.totalSurahCount}]');
    }
  }

  static void _assertVerse(int s, int v) {
    _assertSurah(s);
    final max = q.getVerseCount(s);
    if (v < 1 || v > max) {
      throw RangeError('Verse $v out of range for surah $s [1..$max]');
    }
  }
}
