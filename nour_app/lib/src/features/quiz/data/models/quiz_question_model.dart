import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A single daily-quiz question. Mirrors `public.quiz_questions`.
///
/// `correctOptionIndex` is 1-based (1..4) and is used **only** for instant
/// client-side feedback — `submitQuiz` stays authoritative for scoring/ajr.
class QuizQuestionModel extends Equatable {
  final int id;
  final String level;

  final String questionEn;
  final String questionFr;
  final String questionAr;

  final String? arabicText;

  final String? transcriptionEn;
  final String? transcriptionFr;

  final String? subtitleEn;
  final String? subtitleFr;
  final String? subtitleAr;

  final String optionAEn;
  final String optionAFr;
  final String optionAAr;
  final String optionBEn;
  final String optionBFr;
  final String optionBAr;
  final String optionCEn;
  final String optionCFr;
  final String optionCAr;
  final String optionDEn;
  final String optionDFr;
  final String optionDAr;

  final String? congratulationEn;
  final String? congratulationFr;
  final String? congratulationAr;

  final int correctOptionIndex;
  final int ajr;
  final int? bonusAjr;

  const QuizQuestionModel({
    required this.id,
    required this.level,
    required this.questionEn,
    required this.questionFr,
    required this.questionAr,
    this.arabicText,
    this.transcriptionEn,
    this.transcriptionFr,
    this.subtitleEn,
    this.subtitleFr,
    this.subtitleAr,
    required this.optionAEn,
    required this.optionAFr,
    required this.optionAAr,
    required this.optionBEn,
    required this.optionBFr,
    required this.optionBAr,
    required this.optionCEn,
    required this.optionCFr,
    required this.optionCAr,
    required this.optionDEn,
    required this.optionDFr,
    required this.optionDAr,
    this.congratulationEn,
    this.congratulationFr,
    this.congratulationAr,
    required this.correctOptionIndex,
    required this.ajr,
    this.bonusAjr,
  });

  factory QuizQuestionModel.fromJson(Json json) => QuizQuestionModel(
    id: json['id'] as int,
    level: json['level'] as String,
    questionEn: json['question_en'] as String,
    questionFr: json['question_fr'] as String,
    questionAr: json['question_ar'] as String,
    arabicText: _str(json['arabic_text']),
    transcriptionEn: _str(json['transcription_en']),
    transcriptionFr: _str(json['transcription_fr']),
    subtitleEn: _str(json['subtitle_en']),
    subtitleFr: _str(json['subtitle_fr']),
    subtitleAr: _str(json['subtitle_ar']),
    optionAEn: json['option_a_en'] as String,
    optionAFr: json['option_a_fr'] as String,
    optionAAr: json['option_a_ar'] as String,
    optionBEn: json['option_b_en'] as String,
    optionBFr: json['option_b_fr'] as String,
    optionBAr: json['option_b_ar'] as String,
    optionCEn: json['option_c_en'] as String,
    optionCFr: json['option_c_fr'] as String,
    optionCAr: json['option_c_ar'] as String,
    optionDEn: json['option_d_en'] as String,
    optionDFr: json['option_d_fr'] as String,
    optionDAr: json['option_d_ar'] as String,
    congratulationEn: _str(json['congratulation_en']),
    congratulationFr: _str(json['congratulation_fr']),
    congratulationAr: _str(json['congratulation_ar']),
    correctOptionIndex: json['correct_option_index'] as int,
    ajr: json['ajr'] as int,
    bonusAjr: json['bonus_ajr'] as int?,
  );

  /// Trims and nulls-out empty strings so the UI can rely on `!= null`.
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  String question(String lang) => switch (lang) {
    'fr' => questionFr,
    'ar' => questionAr,
    _ => questionEn,
  };

  /// Latin transcription of [arabicText]. No Arabic variant — falls back to EN.
  String? transcription(String lang) => switch (lang) {
    'fr' => transcriptionFr,
    _ => transcriptionEn,
  };

  String? subtitle(String lang) => switch (lang) {
    'fr' => subtitleFr,
    'ar' => subtitleAr,
    _ => subtitleEn,
  };

  /// The 4 options in display order (index 0 == option A == answer index 1).
  List<String> options(String lang) => switch (lang) {
    'fr' => [optionAFr, optionBFr, optionCFr, optionDFr],
    'ar' => [optionAAr, optionBAr, optionCAr, optionDAr],
    _ => [optionAEn, optionBEn, optionCEn, optionDEn],
  };

  /// Optional success explanation shown in the toast. Null → UI shows only the
  /// local title.
  String? congratulation(String lang) => switch (lang) {
    'fr' => congratulationFr,
    'ar' => congratulationAr,
    _ => congratulationEn,
  };

  bool isCorrect(int oneBasedOptionIndex) =>
      oneBasedOptionIndex == correctOptionIndex;

  @override
  List<Object?> get props => [
    id,
    level,
    questionEn,
    questionFr,
    questionAr,
    arabicText,
    transcriptionEn,
    transcriptionFr,
    subtitleEn,
    subtitleFr,
    subtitleAr,
    optionAEn,
    optionAFr,
    optionAAr,
    optionBEn,
    optionBFr,
    optionBAr,
    optionCEn,
    optionCFr,
    optionCAr,
    optionDEn,
    optionDFr,
    optionDAr,
    congratulationEn,
    congratulationFr,
    congratulationAr,
    correctOptionIndex,
    ajr,
    bonusAjr,
  ];
}
