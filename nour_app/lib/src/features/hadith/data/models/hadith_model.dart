import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A single hadith ready for display. Mirrors `public.hadiths`.
///
/// [position] is the 1-based order inside its collection — used both for the
/// numbered badge in the list and to derive reading progress ("x/total").
/// [audioUrl] is optional (a recitation), [likesCount] is the global favorite
/// count (maintained by a DB trigger on `favorite_hadiths`).
class HadithModel extends Equatable {
  final int id;
  final int collectionId;

  final String titleEn;
  final String titleFr;
  final String titleAr;

  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;

  final String arabicText;

  final String transcriptionEn;
  final String transcriptionFr;

  final String translationEn;
  final String translationFr;

  final String referenceEn;
  final String referenceFr;
  final String referenceAr;

  final String tafsirEn;
  final String tafsirFr;
  final String tafsirAr;

  final String? audioUrl;
  final int ajr;
  final int likesCount;
  final int position;
  final bool isActive;

  const HadithModel({
    required this.id,
    required this.collectionId,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    this.descriptionEn = '',
    this.descriptionFr = '',
    this.descriptionAr = '',
    required this.arabicText,
    this.transcriptionEn = '',
    this.transcriptionFr = '',
    this.translationEn = '',
    this.translationFr = '',
    this.referenceEn = '',
    this.referenceFr = '',
    this.referenceAr = '',
    this.tafsirEn = '',
    this.tafsirFr = '',
    this.tafsirAr = '',
    this.audioUrl,
    this.ajr = 5,
    this.likesCount = 0,
    this.position = 0,
    this.isActive = true,
  });

  factory HadithModel.fromJson(Json json) => HadithModel(
        id: json['id'] as int,
        collectionId: json['hadith_collection_id'] as int,
        titleEn: json['title_en'] ?? '',
        titleFr: json['title_fr'] ?? '',
        titleAr: json['title_ar'] ?? '',
        descriptionEn: json['description_en'] ?? '',
        descriptionFr: json['description_fr'] ?? '',
        descriptionAr: json['description_ar'] ?? '',
        arabicText: json['arabic_text'] ?? '',
        transcriptionEn: json['transcription_en'] ?? '',
        transcriptionFr: json['transcription_fr'] ?? '',
        translationEn: json['translation_en'] ?? '',
        translationFr: json['translation_fr'] ?? '',
        referenceEn: json['reference_en'] ?? '',
        referenceFr: json['reference_fr'] ?? '',
        referenceAr: json['reference_ar'] ?? '',
        tafsirEn: json['tafsir_en'] ?? '',
        tafsirFr: json['tafsir_fr'] ?? '',
        tafsirAr: json['tafsir_ar'] ?? '',
        audioUrl: (json['audio_url'] as String?)?.trim().isEmpty ?? true
            ? null
            : json['audio_url'] as String,
        ajr: json['ajr'] ?? 5,
        likesCount: json['likes_count'] ?? 0,
        position: json['position'] ?? 0,
        isActive: json['is_active'] ?? true,
      );

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  String title(String langCode) => switch (langCode) {
        'fr' => titleFr,
        'ar' => titleAr,
        _ => titleEn,
      };

  /// Short preview line shown under the title in the collection list.
  /// Falls back to the translation when no description is set.
  String description(String langCode) {
    final desc = switch (langCode) {
      'fr' => descriptionFr,
      'ar' => descriptionAr,
      _ => descriptionEn,
    };
    if (desc.isNotEmpty) return desc;
    return translation(langCode);
  }

  /// Latin transcription toggled by the "Aa" action (none for Arabic).
  String transcription(String langCode) =>
      langCode == 'fr' ? transcriptionFr : transcriptionEn;

  String translation(String langCode) =>
      langCode == 'fr' ? translationFr : translationEn;

  /// Source reference, e.g. "Sahih Bukhari 3302\nSahih Muslim 3302".
  String reference(String langCode) => switch (langCode) {
        'fr' => referenceFr.isNotEmpty ? referenceFr : referenceEn,
        'ar' => referenceAr.isNotEmpty ? referenceAr : referenceEn,
        _ => referenceEn,
      };

  String tafsir(String langCode) => switch (langCode) {
        'fr' => tafsirFr.isNotEmpty ? tafsirFr : tafsirEn,
        'ar' => tafsirAr.isNotEmpty ? tafsirAr : tafsirEn,
        _ => tafsirEn,
      };

  HadithModel copyWith({int? likesCount}) => HadithModel(
        id: id,
        collectionId: collectionId,
        titleEn: titleEn,
        titleFr: titleFr,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionFr: descriptionFr,
        descriptionAr: descriptionAr,
        arabicText: arabicText,
        transcriptionEn: transcriptionEn,
        transcriptionFr: transcriptionFr,
        translationEn: translationEn,
        translationFr: translationFr,
        referenceEn: referenceEn,
        referenceFr: referenceFr,
        referenceAr: referenceAr,
        tafsirEn: tafsirEn,
        tafsirFr: tafsirFr,
        tafsirAr: tafsirAr,
        audioUrl: audioUrl,
        ajr: ajr,
        likesCount: likesCount ?? this.likesCount,
        position: position,
        isActive: isActive,
      );

  @override
  List<Object?> get props => [
        id,
        collectionId,
        titleEn,
        titleFr,
        titleAr,
        descriptionEn,
        descriptionFr,
        descriptionAr,
        arabicText,
        transcriptionEn,
        transcriptionFr,
        translationEn,
        translationFr,
        referenceEn,
        referenceFr,
        referenceAr,
        tafsirEn,
        tafsirFr,
        tafsirAr,
        audioUrl,
        ajr,
        likesCount,
        position,
        isActive,
      ];
}
