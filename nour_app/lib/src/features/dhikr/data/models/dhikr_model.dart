import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class DhikrModel extends Equatable {
  final int id;
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
  final String translationEn;
  final String translationFr;
  final String? translationDe;
  final String? translationNl;
  final String? translationTr;
  final String? translationId;
  final String? translationUr;
  final String? translationBn;
  final String? translationMs;
  final int minCount;
  final int ajr;
  final bool isActive;

  const DhikrModel({
    required this.id,
    required this.arabicText,
    required this.transcriptionEn,
    required this.transcriptionFr,
    this.transcriptionDe,
    this.transcriptionNl,
    this.transcriptionTr,
    this.transcriptionId,
    this.transcriptionUr,
    this.transcriptionBn,
    this.transcriptionMs,
    required this.translationEn,
    required this.translationFr,
    this.translationDe,
    this.translationNl,
    this.translationTr,
    this.translationId,
    this.translationUr,
    this.translationBn,
    this.translationMs,
    required this.minCount,
    required this.ajr,
    required this.isActive,
  });

  factory DhikrModel.fromJson(Json json) => DhikrModel(
    id: json['id'],
    arabicText: json['arabic_text'],
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
    minCount: json['min_count'],
    ajr: json['ajr'],
    isActive: json['is_active'] ?? true,
  );

  /// Latin transcription used as the card/title label.
  /// Falls back to the English transcription for `ar` and any other locale.
  String transcription(String langCode) => switch (langCode) {
    'fr' => transcriptionFr,
    'de' => transcriptionDe.orLoc(transcriptionEn),
    'nl' => transcriptionNl.orLoc(transcriptionEn),
    'tr' => transcriptionTr.orLoc(transcriptionEn),
    'id' => transcriptionId.orLoc(transcriptionEn),
    'ur' => transcriptionUr.orLoc(transcriptionEn),
    'bn' => transcriptionBn.orLoc(transcriptionEn),
    'ms' => transcriptionMs.orLoc(transcriptionEn),
    _ => transcriptionEn,
  };

  /// Localized meaning shown under the Arabic text.
  String translation(String langCode) => switch (langCode) {
    'fr' => translationFr,
    'de' => translationDe.orLoc(translationEn),
    'nl' => translationNl.orLoc(translationEn),
    'tr' => translationTr.orLoc(translationEn),
    'id' => translationId.orLoc(translationEn),
    'ur' => translationUr.orLoc(translationEn),
    'bn' => translationBn.orLoc(translationEn),
    'ms' => translationMs.orLoc(translationEn),
    _ => translationEn,
  };

  @override
  List<Object?> get props => [
    id,
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
    minCount,
    ajr,
    isActive,
  ];
}
