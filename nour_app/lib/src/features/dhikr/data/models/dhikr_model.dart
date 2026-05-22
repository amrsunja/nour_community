import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class DhikrModel extends Equatable {
  final int id;
  final String arabicText;
  final String transcriptionEn;
  final String transcriptionFr;
  final String translationEn;
  final String translationFr;
  final int minCount;
  final int ajr;
  final bool isActive;

  const DhikrModel({
    required this.id,
    required this.arabicText,
    required this.transcriptionEn,
    required this.transcriptionFr,
    required this.translationEn,
    required this.translationFr,
    required this.minCount,
    required this.ajr,
    required this.isActive,
  });

  factory DhikrModel.fromJson(Json json) => DhikrModel(
    id: json['id'],
    arabicText: json['arabic_text'],
    transcriptionEn: json['transcription_en'],
    transcriptionFr: json['transcription_fr'],
    translationEn: json['translation_en'],
    translationFr: json['translation_fr'],
    minCount: json['min_count'],
    ajr: json['ajr'],
    isActive: json['is_active'] ?? true,
  );

  /// Latin transcription used as the card/title label.
  /// Falls back to the English transcription for `ar` and any other locale.
  String transcription(String langCode) =>
      langCode == 'fr' ? transcriptionFr : transcriptionEn;

  /// Localized meaning shown under the Arabic text.
  String translation(String langCode) =>
      langCode == 'fr' ? translationFr : translationEn;

  @override
  List<Object?> get props => [
    id,
    arabicText,
    transcriptionEn,
    transcriptionFr,
    translationEn,
    translationFr,
    minCount,
    ajr,
    isActive,
  ];
}
