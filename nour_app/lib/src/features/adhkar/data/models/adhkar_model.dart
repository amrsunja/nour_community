import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AdhkarModel extends Equatable {
  final int id;
  final int subcategoryId;
  final String arabicText;
  final String? transcriptionEn;
  final String? transcriptionFr;
  final String? translationEn;
  final String? translationFr;
  final String? whenEn;
  final String? whenFr;
  final String? whenAr;
  final String? referenceEn;
  final String? referenceFr;
  final String? referenceAr;
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
    this.translationEn,
    this.translationFr,
    this.whenEn,
    this.whenFr,
    this.whenAr,
    this.referenceEn,
    this.referenceFr,
    this.referenceAr,
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
    translationEn: json['translation_en'],
    translationFr: json['translation_fr'],
    whenEn: json['when_en'],
    whenFr: json['when_fr'],
    whenAr: json['when_ar'],
    referenceEn: json['reference_en'],
    referenceFr: json['reference_fr'],
    referenceAr: json['reference_ar'],
    minCount: json['min_count'] ?? 1,
    ajr: json['ajr'] ?? 5,
    likesCount: json['likes_count'] ?? 0,
    isActive: json['is_active'] ?? true,
  );

  /// Card / detail title — the "when to recite" label.
  String? when(String langCode) => switch (langCode) {
    'fr' => whenFr,
    'ar' => whenAr,
    _ => whenEn,
  };

  /// Source reference (hadith citation).
  String? reference(String langCode) => switch (langCode) {
    'fr' => referenceFr,
    'ar' => referenceAr,
    _ => referenceEn,
  };

  /// Latin transcription shown under the Arabic when toggled on.
  String? transcription(String langCode) =>
      langCode == 'fr' ? transcriptionFr : transcriptionEn;

  /// Localized meaning displayed below the card.
  String? translation(String langCode) =>
      langCode == 'fr' ? translationFr : translationEn;

  @override
  List<Object?> get props => [
    id,
    subcategoryId,
    arabicText,
    transcriptionEn,
    transcriptionFr,
    translationEn,
    translationFr,
    whenEn,
    whenFr,
    whenAr,
    referenceEn,
    referenceFr,
    referenceAr,
    minCount,
    ajr,
    likesCount,
    isActive,
  ];
}
