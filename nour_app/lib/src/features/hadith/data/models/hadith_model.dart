import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
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
  final String? titleDe;
  final String? titleNl;
  final String? titleTr;
  final String? titleId;
  final String? titleUr;
  final String? titleBn;
  final String? titleMs;
  final String? titleRu;

  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String? descriptionDe;
  final String? descriptionNl;
  final String? descriptionTr;
  final String? descriptionId;
  final String? descriptionUr;
  final String? descriptionBn;
  final String? descriptionMs;
  final String? descriptionRu;

  final String arabicText;

  final String transcriptionEn;
  final String transcriptionFr;
  final String? transcriptionDe;
  final String? transcriptionNl;
  final String? transcriptionTr;
  final String? transcriptionId;
  final String? transcriptionUr;
  final String? transcriptionBn;
  final String? transcriptionMs;
  final String? transcriptionRu;

  final String translationEn;
  final String translationFr;
  final String? translationDe;
  final String? translationNl;
  final String? translationTr;
  final String? translationId;
  final String? translationUr;
  final String? translationBn;
  final String? translationMs;
  final String? translationRu;

  final String referenceEn;
  final String referenceFr;
  final String referenceAr;
  final String? referenceDe;
  final String? referenceNl;
  final String? referenceTr;
  final String? referenceId;
  final String? referenceUr;
  final String? referenceBn;
  final String? referenceMs;
  final String? referenceRu;

  final String tafsirEn;
  final String tafsirFr;
  final String tafsirAr;
  final String? tafsirDe;
  final String? tafsirNl;
  final String? tafsirTr;
  final String? tafsirId;
  final String? tafsirUr;
  final String? tafsirBn;
  final String? tafsirMs;
  final String? tafsirRu;

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
    this.titleDe,
    this.titleNl,
    this.titleTr,
    this.titleId,
    this.titleUr,
    this.titleBn,
    this.titleMs,
    this.titleRu,
    this.descriptionEn = '',
    this.descriptionFr = '',
    this.descriptionAr = '',
    this.descriptionDe,
    this.descriptionNl,
    this.descriptionTr,
    this.descriptionId,
    this.descriptionUr,
    this.descriptionBn,
    this.descriptionMs,
    this.descriptionRu,
    required this.arabicText,
    this.transcriptionEn = '',
    this.transcriptionFr = '',
    this.transcriptionDe,
    this.transcriptionNl,
    this.transcriptionTr,
    this.transcriptionId,
    this.transcriptionUr,
    this.transcriptionBn,
    this.transcriptionMs,
    this.transcriptionRu,
    this.translationEn = '',
    this.translationFr = '',
    this.translationDe,
    this.translationNl,
    this.translationTr,
    this.translationId,
    this.translationUr,
    this.translationBn,
    this.translationMs,
    this.translationRu,
    this.referenceEn = '',
    this.referenceFr = '',
    this.referenceAr = '',
    this.referenceDe,
    this.referenceNl,
    this.referenceTr,
    this.referenceId,
    this.referenceUr,
    this.referenceBn,
    this.referenceMs,
    this.referenceRu,
    this.tafsirEn = '',
    this.tafsirFr = '',
    this.tafsirAr = '',
    this.tafsirDe,
    this.tafsirNl,
    this.tafsirTr,
    this.tafsirId,
    this.tafsirUr,
    this.tafsirBn,
    this.tafsirMs,
    this.tafsirRu,
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
        titleDe: json['title_de'],
        titleNl: json['title_nl'],
        titleTr: json['title_tr'],
        titleId: json['title_id'],
        titleUr: json['title_ur'],
        titleBn: json['title_bn'],
        titleMs: json['title_ms'],
        titleRu: json['title_ru'],
        descriptionEn: json['description_en'] ?? '',
        descriptionFr: json['description_fr'] ?? '',
        descriptionAr: json['description_ar'] ?? '',
        descriptionDe: json['description_de'],
        descriptionNl: json['description_nl'],
        descriptionTr: json['description_tr'],
        descriptionId: json['description_id'],
        descriptionUr: json['description_ur'],
        descriptionBn: json['description_bn'],
        descriptionMs: json['description_ms'],
        descriptionRu: json['description_ru'],
        arabicText: json['arabic_text'] ?? '',
        transcriptionEn: json['transcription_en'] ?? '',
        transcriptionFr: json['transcription_fr'] ?? '',
        transcriptionDe: json['transcription_de'],
        transcriptionNl: json['transcription_nl'],
        transcriptionTr: json['transcription_tr'],
        transcriptionId: json['transcription_id'],
        transcriptionUr: json['transcription_ur'],
        transcriptionBn: json['transcription_bn'],
        transcriptionMs: json['transcription_ms'],
        transcriptionRu: json['transcription_ru'],
        translationEn: json['translation_en'] ?? '',
        translationFr: json['translation_fr'] ?? '',
        translationDe: json['translation_de'],
        translationNl: json['translation_nl'],
        translationTr: json['translation_tr'],
        translationId: json['translation_id'],
        translationUr: json['translation_ur'],
        translationBn: json['translation_bn'],
        translationMs: json['translation_ms'],
        translationRu: json['translation_ru'],
        referenceEn: json['reference_en'] ?? '',
        referenceFr: json['reference_fr'] ?? '',
        referenceAr: json['reference_ar'] ?? '',
        referenceDe: json['reference_de'],
        referenceNl: json['reference_nl'],
        referenceTr: json['reference_tr'],
        referenceId: json['reference_id'],
        referenceUr: json['reference_ur'],
        referenceBn: json['reference_bn'],
        referenceMs: json['reference_ms'],
        referenceRu: json['reference_ru'],
        tafsirEn: json['tafsir_en'] ?? '',
        tafsirFr: json['tafsir_fr'] ?? '',
        tafsirAr: json['tafsir_ar'] ?? '',
        tafsirDe: json['tafsir_de'],
        tafsirNl: json['tafsir_nl'],
        tafsirTr: json['tafsir_tr'],
        tafsirId: json['tafsir_id'],
        tafsirUr: json['tafsir_ur'],
        tafsirBn: json['tafsir_bn'],
        tafsirMs: json['tafsir_ms'],
        tafsirRu: json['tafsir_ru'],
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
        'de' => titleDe.orLoc(titleEn),
        'nl' => titleNl.orLoc(titleEn),
        'tr' => titleTr.orLoc(titleEn),
        'id' => titleId.orLoc(titleEn),
        'ur' => titleUr.orLoc(titleEn),
        'bn' => titleBn.orLoc(titleEn),
        'ms' => titleMs.orLoc(titleEn),
        'ru' => titleRu.orLoc(titleEn),
        _ => titleEn,
      };

  /// Short preview line shown under the title in the collection list.
  /// Falls back to the translation when no description is set.
  String description(String langCode) {
    final desc = switch (langCode) {
      'fr' => descriptionFr,
      'ar' => descriptionAr,
      'de' => descriptionDe.orLoc(descriptionEn),
      'nl' => descriptionNl.orLoc(descriptionEn),
      'tr' => descriptionTr.orLoc(descriptionEn),
      'id' => descriptionId.orLoc(descriptionEn),
      'ur' => descriptionUr.orLoc(descriptionEn),
      'bn' => descriptionBn.orLoc(descriptionEn),
      'ms' => descriptionMs.orLoc(descriptionEn),
      'ru' => descriptionRu.orLoc(descriptionEn),
      _ => descriptionEn,
    };
    if (desc.isNotEmpty) return desc;
    return translation(langCode);
  }

  /// Latin transcription toggled by the "Aa" action (none for Arabic).
  String transcription(String langCode) => switch (langCode) {
        'fr' => transcriptionFr,
        'de' => transcriptionDe.orLoc(transcriptionEn),
        'nl' => transcriptionNl.orLoc(transcriptionEn),
        'tr' => transcriptionTr.orLoc(transcriptionEn),
        'id' => transcriptionId.orLoc(transcriptionEn),
        'ur' => transcriptionUr.orLoc(transcriptionEn),
        'bn' => transcriptionBn.orLoc(transcriptionEn),
        'ms' => transcriptionMs.orLoc(transcriptionEn),
        'ru' => transcriptionRu.orLoc(transcriptionEn),
        _ => transcriptionEn,
      };

  String translation(String langCode) => switch (langCode) {
        'fr' => translationFr,
        'de' => translationDe.orLoc(translationEn),
        'nl' => translationNl.orLoc(translationEn),
        'tr' => translationTr.orLoc(translationEn),
        'id' => translationId.orLoc(translationEn),
        'ur' => translationUr.orLoc(translationEn),
        'bn' => translationBn.orLoc(translationEn),
        'ms' => translationMs.orLoc(translationEn),
        'ru' => translationRu.orLoc(translationEn),
        _ => translationEn,
      };

  /// Source reference, e.g. "Sahih Bukhari 3302\nSahih Muslim 3302".
  String reference(String langCode) => switch (langCode) {
        'fr' => referenceFr.isNotEmpty ? referenceFr : referenceEn,
        'ar' => referenceAr.isNotEmpty ? referenceAr : referenceEn,
        'de' => referenceDe.orLoc(referenceEn),
        'nl' => referenceNl.orLoc(referenceEn),
        'tr' => referenceTr.orLoc(referenceEn),
        'id' => referenceId.orLoc(referenceEn),
        'ur' => referenceUr.orLoc(referenceEn),
        'bn' => referenceBn.orLoc(referenceEn),
        'ms' => referenceMs.orLoc(referenceEn),
        'ru' => referenceRu.orLoc(referenceEn),
        _ => referenceEn,
      };

  String tafsir(String langCode) => switch (langCode) {
        'fr' => tafsirFr.isNotEmpty ? tafsirFr : tafsirEn,
        'ar' => tafsirAr.isNotEmpty ? tafsirAr : tafsirEn,
        'de' => tafsirDe.orLoc(tafsirEn),
        'nl' => tafsirNl.orLoc(tafsirEn),
        'tr' => tafsirTr.orLoc(tafsirEn),
        'id' => tafsirId.orLoc(tafsirEn),
        'ur' => tafsirUr.orLoc(tafsirEn),
        'bn' => tafsirBn.orLoc(tafsirEn),
        'ms' => tafsirMs.orLoc(tafsirEn),
        'ru' => tafsirRu.orLoc(tafsirEn),
        _ => tafsirEn,
      };

  HadithModel copyWith({int? likesCount}) => HadithModel(
        id: id,
        collectionId: collectionId,
        titleEn: titleEn,
        titleFr: titleFr,
        titleAr: titleAr,
        titleDe: titleDe,
        titleNl: titleNl,
        titleTr: titleTr,
        titleId: titleId,
        titleUr: titleUr,
        titleBn: titleBn,
        titleMs: titleMs,
        titleRu: titleRu,
        descriptionEn: descriptionEn,
        descriptionFr: descriptionFr,
        descriptionAr: descriptionAr,
        descriptionDe: descriptionDe,
        descriptionNl: descriptionNl,
        descriptionTr: descriptionTr,
        descriptionId: descriptionId,
        descriptionUr: descriptionUr,
        descriptionBn: descriptionBn,
        descriptionMs: descriptionMs,
        descriptionRu: descriptionRu,
        arabicText: arabicText,
        transcriptionEn: transcriptionEn,
        transcriptionFr: transcriptionFr,
        transcriptionDe: transcriptionDe,
        transcriptionNl: transcriptionNl,
        transcriptionTr: transcriptionTr,
        transcriptionId: transcriptionId,
        transcriptionUr: transcriptionUr,
        transcriptionBn: transcriptionBn,
        transcriptionMs: transcriptionMs,
        transcriptionRu: transcriptionRu,
        translationEn: translationEn,
        translationFr: translationFr,
        translationDe: translationDe,
        translationNl: translationNl,
        translationTr: translationTr,
        translationId: translationId,
        translationUr: translationUr,
        translationBn: translationBn,
        translationMs: translationMs,
        translationRu: translationRu,
        referenceEn: referenceEn,
        referenceFr: referenceFr,
        referenceAr: referenceAr,
        referenceDe: referenceDe,
        referenceNl: referenceNl,
        referenceTr: referenceTr,
        referenceId: referenceId,
        referenceUr: referenceUr,
        referenceBn: referenceBn,
        referenceMs: referenceMs,
        referenceRu: referenceRu,
        tafsirEn: tafsirEn,
        tafsirFr: tafsirFr,
        tafsirAr: tafsirAr,
        tafsirDe: tafsirDe,
        tafsirNl: tafsirNl,
        tafsirTr: tafsirTr,
        tafsirId: tafsirId,
        tafsirUr: tafsirUr,
        tafsirBn: tafsirBn,
        tafsirMs: tafsirMs,
        tafsirRu: tafsirRu,
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
        titleDe,
        titleNl,
        titleTr,
        titleId,
        titleUr,
        titleBn,
        titleMs,
        titleRu,
        descriptionEn,
        descriptionFr,
        descriptionAr,
        descriptionDe,
        descriptionNl,
        descriptionTr,
        descriptionId,
        descriptionUr,
        descriptionBn,
        descriptionMs,
        descriptionRu,
        arabicText,
        transcriptionEn,
        transcriptionFr,
        transcriptionDe,
        transcriptionNl,
        transcriptionTr,
        transcriptionId,
        transcriptionUr,
        transcriptionBn,
        transcriptionMs,
        transcriptionRu,
        translationEn,
        translationFr,
        translationDe,
        translationNl,
        translationTr,
        translationId,
        translationUr,
        translationBn,
        translationMs,
        translationRu,
        referenceEn,
        referenceFr,
        referenceAr,
        referenceDe,
        referenceNl,
        referenceTr,
        referenceId,
        referenceUr,
        referenceBn,
        referenceMs,
        referenceRu,
        tafsirEn,
        tafsirFr,
        tafsirAr,
        tafsirDe,
        tafsirNl,
        tafsirTr,
        tafsirId,
        tafsirUr,
        tafsirBn,
        tafsirMs,
        tafsirRu,
        audioUrl,
        ajr,
        likesCount,
        position,
        isActive,
      ];
}
