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

  /// Localized surah names shipped by the `quran` package. Only these four
  /// scripts are bundled; every other locale falls back to [nameEnglish].
  final String nameTurkish;
  final String nameFrench;
  final String nameRussian;

  final int versesCount;
  final RevelationPlace place;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTurkish,
    required this.nameFrench,
    required this.nameRussian,
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
      nameTurkish: q.getSurahNameTurkish(surahNumber),
      nameFrench: q.getSurahNameFrench(surahNumber),
      nameRussian: q.getSurahNameRussian(surahNumber),
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
    String langCode = 'en',
  }) {
    _assertVerse(surahNumber, verseNumber);
    return q.getVerseTranslation(
      surahNumber,
      verseNumber,
      translation: translationForLanguage(langCode),
    );
  }

  // ── Language mapping ──────────────────────────────────────────────────────

  /// Maps an app language code to a bundled translation edition shipped with the
  /// `quran` package. Codes with no matching edition (e.g. `ar` — Arabic is the
  /// source text, not a translation; `de`, `ms`) fall back to English Saheeh.
  /// Normalises region suffixes (`pt_BR` → `pt`) and lower-cases before matching.
  static q.Translation translationForLanguage(String langCode) {
    final code = langCode.toLowerCase().split(RegExp('[-_]')).first;
    switch (code) {
      case 'fr':
        return q.Translation.frHamidullah;
      case 'tr':
        return q.Translation.trSaheeh;
      case 'ml':
        return q.Translation.mlAbdulHameed;
      case 'fa':
        return q.Translation.faHusseinDari;
      case 'pt':
        return q.Translation.portuguese;
      case 'it':
        return q.Translation.itPiccardo;
      case 'nl':
        return q.Translation.nlSiregar;
      case 'ru':
        return q.Translation.ruKuliev;
      case 'bn':
        return q.Translation.bengali;
      case 'zh':
        return q.Translation.chinese;
      case 'sv':
        return q.Translation.swedish;
      case 'es':
        return q.Translation.spanish;
      case 'ur':
        return q.Translation.urdu;
      case 'id':
        return q.Translation.indonesian;
      case 'en':
      case 'ar':
      default:
        return q.Translation.enSaheeh;
    }
  }

  /// Surah name to display for [langCode]. The `quran` package ships localized
  /// names only for Arabic, Turkish, French and Russian; every other locale
  /// falls back to the (transliterated) English name.
  static String localizedSurahName(SurahInfo surah, String langCode) {
    switch (langCode.toLowerCase().split(RegExp('[-_]')).first) {
      case 'ar':
        return surah.nameArabic;
      case 'tr':
        return surah.nameTurkish;
      case 'fr':
        return surah.nameFrench;
      case 'ru':
        return surah.nameRussian;
      default:
        return surah.nameEnglish;
    }
  }

  // ── Edition mapping (remote alquran.cloud editions) ─────────────────────────

  /// alquran.cloud tafsir edition id for [langCode], or `null` when no tafsir
  /// is published for that language (caller then shows the meaning fallback).
  /// alquran.cloud's text tafsir catalogue is limited, hence the short map.
  static String? tafsirEditionForLanguage(String langCode) {
    switch (langCode.toLowerCase().split(RegExp('[-_]')).first) {
      case 'ar':
        return 'ar.muyassar';
      case 'en':
        return 'en.maududi';
      default:
        return null;
    }
  }

  /// alquran.cloud transliteration edition for [langCode]. Only a Latin
  /// transliteration is published (it is script-, not language-, specific), so
  /// every non-Arabic locale shares `en.transliteration`. Arabic needs none.
  static String? transliterationEditionForLanguage(String langCode) {
    final code = langCode.toLowerCase().split(RegExp('[-_]')).first;
    if (code == 'ar') {
      return null;
    } else if (code == 'ru') {
      return 'ru.transliteration';
    } else if (code == 'tr') {
      return 'tr.transliteration';
    }
    return 'en.transliteration';
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
