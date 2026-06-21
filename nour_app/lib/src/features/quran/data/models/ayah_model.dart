import 'package:equatable/equatable.dart';

/// A single ayah ready for display. Built from the local `quran` package data
/// (via [QuranTool]) so the UI layer never depends on the upstream API.
class AyahModel extends Equatable {
  final int surahNumber;
  final int ayahNumber;

  /// Arabic text including the end-of-verse symbol.
  final String arabicText;

  /// Localized meaning.
  final String translation;

  final int juzNumber;
  final int pageNumber;

  const AyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    required this.juzNumber,
    required this.pageNumber,
  });

  /// Stable key used for like maps / sets: `"surah:ayah"`.
  String get key => '$surahNumber:$ayahNumber';

  @override
  List<Object?> get props =>
      [surahNumber, ayahNumber, arabicText, translation, juzNumber, pageNumber];
}
