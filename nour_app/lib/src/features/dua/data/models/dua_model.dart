import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A single dua ready for display. Mirrors `public.duas`.
///
/// Unlike hadiths, duas live in one flat library (no collections), so
/// [position] is the 1-based order inside the whole library — used both for the
/// numbered badge in the list and to derive reading progress ("x/total").
/// [whenEn]/[whenFr]/[whenAr] hold the "When to recite" guidance shown beneath
/// the translation. [audioUrl] is optional (a recitation), [likesCount] is the
/// global favorite count (maintained by a DB trigger on `favorite_duas`).
class DuaModel extends Equatable {
  final int id;

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

  final String whenEn;
  final String whenFr;
  final String whenAr;
  final String? whenDe;
  final String? whenNl;
  final String? whenTr;
  final String? whenId;
  final String? whenUr;
  final String? whenBn;
  final String? whenMs;
  final String? whenRu;

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

  const DuaModel({
    required this.id,
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
    this.whenEn = '',
    this.whenFr = '',
    this.whenAr = '',
    this.whenDe,
    this.whenNl,
    this.whenTr,
    this.whenId,
    this.whenUr,
    this.whenBn,
    this.whenMs,
    this.whenRu,
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

  factory DuaModel.fromJson(Json json) => DuaModel(
        id: json['id'] as int,
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
        whenEn: json['when_en'] ?? '',
        whenFr: json['when_fr'] ?? '',
        whenAr: json['when_ar'] ?? '',
        whenDe: json['when_de'],
        whenNl: json['when_nl'],
        whenTr: json['when_tr'],
        whenId: json['when_id'],
        whenUr: json['when_ur'],
        whenBn: json['when_bn'],
        whenMs: json['when_ms'],
        whenRu: json['when_ru'],
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

  /// Localized heading (e.g. "After salah"). Falls back to the reference, then
  /// the translation, so the card always has something to show.
  String title(String langCode) {
    final t = switch (langCode) {
      'fr' => titleFr.isNotEmpty ? titleFr : titleEn,
      'ar' => titleAr.isNotEmpty ? titleAr : titleEn,
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
    if (t.isNotEmpty) return t;
    final ref = reference(langCode);
    if (ref.isNotEmpty) return ref;
    return translation(langCode);
  }

  /// Short preview line shown under the title in the library list.
  /// Falls back to the translation when no "when" guidance is set.
  String description(String langCode) {
    final w = when(langCode);
    if (w.isNotEmpty) return w;
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

  /// "When to recite" guidance shown under the translation in the reader.
  String when(String langCode) => switch (langCode) {
        'fr' => whenFr.isNotEmpty ? whenFr : whenEn,
        'ar' => whenAr.isNotEmpty ? whenAr : whenEn,
        'de' => whenDe.orLoc(whenEn),
        'nl' => whenNl.orLoc(whenEn),
        'tr' => whenTr.orLoc(whenEn),
        'id' => whenId.orLoc(whenEn),
        'ur' => whenUr.orLoc(whenEn),
        'bn' => whenBn.orLoc(whenEn),
        'ms' => whenMs.orLoc(whenEn),
        'ru' => whenRu.orLoc(whenEn),
        _ => whenEn,
      };

  /// Source reference, e.g. "Sahih Muslim 3302".
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

  DuaModel copyWith({int? likesCount}) => DuaModel(
        id: id,
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
        whenEn: whenEn,
        whenFr: whenFr,
        whenAr: whenAr,
        whenDe: whenDe,
        whenNl: whenNl,
        whenTr: whenTr,
        whenId: whenId,
        whenUr: whenUr,
        whenBn: whenBn,
        whenMs: whenMs,
        whenRu: whenRu,
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
        whenEn,
        whenFr,
        whenAr,
        whenDe,
        whenNl,
        whenTr,
        whenId,
        whenUr,
        whenBn,
        whenMs,
        whenRu,
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
