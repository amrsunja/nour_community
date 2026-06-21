import 'package:equatable/equatable.dart';

/// A favourited ayah, resolved for display in the profile Favourites list.
///
/// Ayahs are local to the app (the `favorite_ayahs` table only stores the
/// surah / ayah numbers), so the surah names and [translation] are filled in by
/// the presenter from the local Quran data. Both surah names are carried so the
/// view can localize without reloading. Tapping the row opens the ayah reader
/// at `surahNumber` / `ayahNumber` in read-only mode (no progress write).
class FavoriteAyahItem extends Equatable {
  const FavoriteAyahItem({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahNameEn,
    required this.surahNameAr,
    required this.translation,
  });

  final int surahNumber;
  final int ayahNumber;
  final String surahNameEn;
  final String surahNameAr;

  /// Fixed English-Saheeh meaning (the app's translation edition), shown as the
  /// single-line preview under the heading.
  final String translation;

  /// Localized surah name for the card heading.
  String surahName(String langCode) => langCode == 'ar' ? surahNameAr : surahNameEn;

  @override
  List<Object?> get props =>
      [surahNumber, ayahNumber, surahNameEn, surahNameAr, translation];
}
