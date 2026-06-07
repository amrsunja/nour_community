import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AdhkarModel extends Equatable {
  final int id;
  final int subcategoryId;
  final String arabicText;
  final String? transcriptionEn;
  final String? transcriptionFr;
  final String? transcriptionDe;
  final String? transcriptionNl;
  final String? transcriptionTr;
  final String? transcriptionId;
  final String? transcriptionUr;
  final String? transcriptionBn;
  final String? transcriptionMs;
  final String? translationEn;
  final String? translationFr;
  final String? translationDe;
  final String? translationNl;
  final String? translationTr;
  final String? translationId;
  final String? translationUr;
  final String? translationBn;
  final String? translationMs;
  final String? whenEn;
  final String? whenFr;
  final String? whenAr;
  final String? whenDe;
  final String? whenNl;
  final String? whenTr;
  final String? whenId;
  final String? whenUr;
  final String? whenBn;
  final String? whenMs;
  final String? referenceEn;
  final String? referenceFr;
  final String? referenceAr;
  final String? referenceDe;
  final String? referenceNl;
  final String? referenceTr;
  final String? referenceId;
  final String? referenceUr;
  final String? referenceBn;
  final String? referenceMs;
  final int minCount;
  final int ajr;
  final int likesCount;
  final bool isActive;

  const AdhkarModel({
    required this.id,
    required this.subcategoryId,
    required this.arabicText,
    this.transcriptionEn,
    this.transcriptionFr,
    this.transcriptionDe,
    this.transcriptionNl,
    this.transcriptionTr,
    this.transcriptionId,
    this.transcriptionUr,
    this.transcriptionBn,
    this.transcriptionMs,
    this.translationEn,
    this.translationFr,
    this.translationDe,
    this.translationNl,
    this.translationTr,
    this.translationId,
    this.translationUr,
    this.translationBn,
    this.translationMs,
    this.whenEn,
    this.whenFr,
    this.whenAr,
    this.whenDe,
    this.whenNl,
    this.whenTr,
    this.whenId,
    this.whenUr,
    this.whenBn,
    this.whenMs,
    this.referenceEn,
    this.referenceFr,
    this.referenceAr,
    this.referenceDe,
    this.referenceNl,
    this.referenceTr,
    this.referenceId,
    this.referenceUr,
    this.referenceBn,
    this.referenceMs,
    this.minCount = 1,
    this.ajr = 5,
    this.likesCount = 0,
    this.isActive = true,
  });

  factory AdhkarModel.fromJson(Json json) => AdhkarModel(
    id: json['id'],
    subcategoryId: json['adhkar_subcategory_id'],
    arabicText: json['arabic_text'] ?? '',
    transcriptionEn: json['transcription_en'],
    transcriptionFr: json['transcription_fr'],
    transcriptionDe: json['transcription_de'],
    transcriptionNl: json['transcription_nl'],
    transcriptionTr: json['transcription_tr'],
    transcriptionId: json['transcription_id'],
    transcriptionUr: json['transcription_ur'],
    transcriptionBn: json['transcription_bn'],
    transcriptionMs: json['transcription_ms'],
    translationEn: json['translation_en'],
    translationFr: json['translation_fr'],
    translationDe: json['translation_de'],
    translationNl: json['translation_nl'],
    translationTr: json['translation_tr'],
    translationId: json['translation_id'],
    translationUr: json['translation_ur'],
    translationBn: json['translation_bn'],
    translationMs: json['translation_ms'],
    whenEn: json['when_en'],
    whenFr: json['when_fr'],
    whenAr: json['when_ar'],
    whenDe: json['when_de'],
    whenNl: json['when_nl'],
    whenTr: json['when_tr'],
    whenId: json['when_id'],
    whenUr: json['when_ur'],
    whenBn: json['when_bn'],
    whenMs: json['when_ms'],
    referenceEn: json['reference_en'],
    referenceFr: json['reference_fr'],
    referenceAr: json['reference_ar'],
    referenceDe: json['reference_de'],
    referenceNl: json['reference_nl'],
    referenceTr: json['reference_tr'],
    referenceId: json['reference_id'],
    referenceUr: json['reference_ur'],
    referenceBn: json['reference_bn'],
    referenceMs: json['reference_ms'],
    minCount: json['min_count'] ?? 1,
    ajr: json['ajr'] ?? 5,
    likesCount: json['likes_count'] ?? 0,
    isActive: json['is_active'] ?? true,
  );

  /// Card / detail title — the "when to recite" label.
  String? when(String langCode) => switch (langCode) {
    'fr' => whenFr,
    'ar' => whenAr,
    'de' => whenDe.orLocNullable(whenEn),
    'nl' => whenNl.orLocNullable(whenEn),
    'tr' => whenTr.orLocNullable(whenEn),
    'id' => whenId.orLocNullable(whenEn),
    'ur' => whenUr.orLocNullable(whenEn),
    'bn' => whenBn.orLocNullable(whenEn),
    'ms' => whenMs.orLocNullable(whenEn),
    _ => whenEn,
  };

  /// Source reference (hadith citation).
  String? reference(String langCode) => switch (langCode) {
    'fr' => referenceFr,
    'ar' => referenceAr,
    'de' => referenceDe.orLocNullable(referenceEn),
    'nl' => referenceNl.orLocNullable(referenceEn),
    'tr' => referenceTr.orLocNullable(referenceEn),
    'id' => referenceId.orLocNullable(referenceEn),
    'ur' => referenceUr.orLocNullable(referenceEn),
    'bn' => referenceBn.orLocNullable(referenceEn),
    'ms' => referenceMs.orLocNullable(referenceEn),
    _ => referenceEn,
  };

  /// Latin transcription shown under the Arabic when toggled on.
  String? transcription(String langCode) => switch (langCode) {
    'fr' => transcriptionFr,
    'de' => transcriptionDe.orLocNullable(transcriptionEn),
    'nl' => transcriptionNl.orLocNullable(transcriptionEn),
    'tr' => transcriptionTr.orLocNullable(transcriptionEn),
    'id' => transcriptionId.orLocNullable(transcriptionEn),
    'ur' => transcriptionUr.orLocNullable(transcriptionEn),
    'bn' => transcriptionBn.orLocNullable(transcriptionEn),
    'ms' => transcriptionMs.orLocNullable(transcriptionEn),
    _ => transcriptionEn,
  };

  /// Localized meaning displayed below the card.
  String? translation(String langCode) => switch (langCode) {
    'fr' => translationFr,
    'de' => translationDe.orLocNullable(translationEn),
    'nl' => translationNl.orLocNullable(translationEn),
    'tr' => translationTr.orLocNullable(translationEn),
    'id' => translationId.orLocNullable(translationEn),
    'ur' => translationUr.orLocNullable(translationEn),
    'bn' => translationBn.orLocNullable(translationEn),
    'ms' => translationMs.orLocNullable(translationEn),
    _ => translationEn,
  };

  @override
  List<Object?> get props => [
    id,
    subcategoryId,
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
    translationEn,
    translationFr,
    translationDe,
    translationNl,
    translationTr,
    translationId,
    translationUr,
    translationBn,
    translationMs,
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
    minCount,
    ajr,
    likesCount,
    isActive,
  ];
}
