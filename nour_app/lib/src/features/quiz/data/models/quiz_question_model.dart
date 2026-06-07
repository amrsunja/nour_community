import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
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
  final String? questionDe;
  final String? questionNl;
  final String? questionTr;
  final String? questionId;
  final String? questionUr;
  final String? questionBn;
  final String? questionMs;

  final String? arabicText;

  final String? transcriptionEn;
  final String? transcriptionFr;
  final String? transcriptionDe;
  final String? transcriptionNl;
  final String? transcriptionTr;
  final String? transcriptionId;
  final String? transcriptionUr;
  final String? transcriptionBn;
  final String? transcriptionMs;

  final String? subtitleEn;
  final String? subtitleFr;
  final String? subtitleAr;
  final String? subtitleDe;
  final String? subtitleNl;
  final String? subtitleTr;
  final String? subtitleId;
  final String? subtitleUr;
  final String? subtitleBn;
  final String? subtitleMs;

  final String optionAEn;
  final String optionAFr;
  final String optionAAr;
  final String? optionADe;
  final String? optionANl;
  final String? optionATr;
  final String? optionAId;
  final String? optionAUr;
  final String? optionABn;
  final String? optionAMs;
  final String optionBEn;
  final String optionBFr;
  final String optionBAr;
  final String? optionBDe;
  final String? optionBNl;
  final String? optionBTr;
  final String? optionBId;
  final String? optionBUr;
  final String? optionBBn;
  final String? optionBMs;
  final String optionCEn;
  final String optionCFr;
  final String optionCAr;
  final String? optionCDe;
  final String? optionCNl;
  final String? optionCTr;
  final String? optionCId;
  final String? optionCUr;
  final String? optionCBn;
  final String? optionCMs;
  final String optionDEn;
  final String optionDFr;
  final String optionDAr;
  final String? optionDDe;
  final String? optionDNl;
  final String? optionDTr;
  final String? optionDId;
  final String? optionDUr;
  final String? optionDBn;
  final String? optionDMs;

  final String? congratulationEn;
  final String? congratulationFr;
  final String? congratulationAr;
  final String? congratulationDe;
  final String? congratulationNl;
  final String? congratulationTr;
  final String? congratulationId;
  final String? congratulationUr;
  final String? congratulationBn;
  final String? congratulationMs;

  final int correctOptionIndex;
  final int ajr;
  final int? bonusAjr;

  const QuizQuestionModel({
    required this.id,
    required this.level,
    required this.questionEn,
    required this.questionFr,
    required this.questionAr,
    this.questionDe,
    this.questionNl,
    this.questionTr,
    this.questionId,
    this.questionUr,
    this.questionBn,
    this.questionMs,
    this.arabicText,
    this.transcriptionEn,
    this.transcriptionFr,
    this.transcriptionDe,
    this.transcriptionNl,
    this.transcriptionTr,
    this.transcriptionId,
    this.transcriptionUr,
    this.transcriptionBn,
    this.transcriptionMs,
    this.subtitleEn,
    this.subtitleFr,
    this.subtitleAr,
    this.subtitleDe,
    this.subtitleNl,
    this.subtitleTr,
    this.subtitleId,
    this.subtitleUr,
    this.subtitleBn,
    this.subtitleMs,
    required this.optionAEn,
    required this.optionAFr,
    required this.optionAAr,
    this.optionADe,
    this.optionANl,
    this.optionATr,
    this.optionAId,
    this.optionAUr,
    this.optionABn,
    this.optionAMs,
    required this.optionBEn,
    required this.optionBFr,
    required this.optionBAr,
    this.optionBDe,
    this.optionBNl,
    this.optionBTr,
    this.optionBId,
    this.optionBUr,
    this.optionBBn,
    this.optionBMs,
    required this.optionCEn,
    required this.optionCFr,
    required this.optionCAr,
    this.optionCDe,
    this.optionCNl,
    this.optionCTr,
    this.optionCId,
    this.optionCUr,
    this.optionCBn,
    this.optionCMs,
    required this.optionDEn,
    required this.optionDFr,
    required this.optionDAr,
    this.optionDDe,
    this.optionDNl,
    this.optionDTr,
    this.optionDId,
    this.optionDUr,
    this.optionDBn,
    this.optionDMs,
    this.congratulationEn,
    this.congratulationFr,
    this.congratulationAr,
    this.congratulationDe,
    this.congratulationNl,
    this.congratulationTr,
    this.congratulationId,
    this.congratulationUr,
    this.congratulationBn,
    this.congratulationMs,
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
    questionDe: _str(json['question_de']),
    questionNl: _str(json['question_nl']),
    questionTr: _str(json['question_tr']),
    questionId: _str(json['question_id']),
    questionUr: _str(json['question_ur']),
    questionBn: _str(json['question_bn']),
    questionMs: _str(json['question_ms']),
    arabicText: _str(json['arabic_text']),
    transcriptionEn: _str(json['transcription_en']),
    transcriptionFr: _str(json['transcription_fr']),
    transcriptionDe: _str(json['transcription_de']),
    transcriptionNl: _str(json['transcription_nl']),
    transcriptionTr: _str(json['transcription_tr']),
    transcriptionId: _str(json['transcription_id']),
    transcriptionUr: _str(json['transcription_ur']),
    transcriptionBn: _str(json['transcription_bn']),
    transcriptionMs: _str(json['transcription_ms']),
    subtitleEn: _str(json['subtitle_en']),
    subtitleFr: _str(json['subtitle_fr']),
    subtitleAr: _str(json['subtitle_ar']),
    subtitleDe: _str(json['subtitle_de']),
    subtitleNl: _str(json['subtitle_nl']),
    subtitleTr: _str(json['subtitle_tr']),
    subtitleId: _str(json['subtitle_id']),
    subtitleUr: _str(json['subtitle_ur']),
    subtitleBn: _str(json['subtitle_bn']),
    subtitleMs: _str(json['subtitle_ms']),
    optionAEn: json['option_a_en'] as String,
    optionAFr: json['option_a_fr'] as String,
    optionAAr: json['option_a_ar'] as String,
    optionADe: _str(json['option_a_de']),
    optionANl: _str(json['option_a_nl']),
    optionATr: _str(json['option_a_tr']),
    optionAId: _str(json['option_a_id']),
    optionAUr: _str(json['option_a_ur']),
    optionABn: _str(json['option_a_bn']),
    optionAMs: _str(json['option_a_ms']),
    optionBEn: json['option_b_en'] as String,
    optionBFr: json['option_b_fr'] as String,
    optionBAr: json['option_b_ar'] as String,
    optionBDe: _str(json['option_b_de']),
    optionBNl: _str(json['option_b_nl']),
    optionBTr: _str(json['option_b_tr']),
    optionBId: _str(json['option_b_id']),
    optionBUr: _str(json['option_b_ur']),
    optionBBn: _str(json['option_b_bn']),
    optionBMs: _str(json['option_b_ms']),
    optionCEn: json['option_c_en'] as String,
    optionCFr: json['option_c_fr'] as String,
    optionCAr: json['option_c_ar'] as String,
    optionCDe: _str(json['option_c_de']),
    optionCNl: _str(json['option_c_nl']),
    optionCTr: _str(json['option_c_tr']),
    optionCId: _str(json['option_c_id']),
    optionCUr: _str(json['option_c_ur']),
    optionCBn: _str(json['option_c_bn']),
    optionCMs: _str(json['option_c_ms']),
    optionDEn: json['option_d_en'] as String,
    optionDFr: json['option_d_fr'] as String,
    optionDAr: json['option_d_ar'] as String,
    optionDDe: _str(json['option_d_de']),
    optionDNl: _str(json['option_d_nl']),
    optionDTr: _str(json['option_d_tr']),
    optionDId: _str(json['option_d_id']),
    optionDUr: _str(json['option_d_ur']),
    optionDBn: _str(json['option_d_bn']),
    optionDMs: _str(json['option_d_ms']),
    congratulationEn: _str(json['congratulation_en']),
    congratulationFr: _str(json['congratulation_fr']),
    congratulationAr: _str(json['congratulation_ar']),
    congratulationDe: _str(json['congratulation_de']),
    congratulationNl: _str(json['congratulation_nl']),
    congratulationTr: _str(json['congratulation_tr']),
    congratulationId: _str(json['congratulation_id']),
    congratulationUr: _str(json['congratulation_ur']),
    congratulationBn: _str(json['congratulation_bn']),
    congratulationMs: _str(json['congratulation_ms']),
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
    'de' => questionDe.orLoc(questionEn),
    'nl' => questionNl.orLoc(questionEn),
    'tr' => questionTr.orLoc(questionEn),
    'id' => questionId.orLoc(questionEn),
    'ur' => questionUr.orLoc(questionEn),
    'bn' => questionBn.orLoc(questionEn),
    'ms' => questionMs.orLoc(questionEn),
    _ => questionEn,
  };

  /// Latin transcription of [arabicText]. No Arabic variant — falls back to EN.
  String? transcription(String lang) => switch (lang) {
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

  String? subtitle(String lang) => switch (lang) {
    'fr' => subtitleFr,
    'ar' => subtitleAr,
    'de' => subtitleDe.orLocNullable(subtitleEn),
    'nl' => subtitleNl.orLocNullable(subtitleEn),
    'tr' => subtitleTr.orLocNullable(subtitleEn),
    'id' => subtitleId.orLocNullable(subtitleEn),
    'ur' => subtitleUr.orLocNullable(subtitleEn),
    'bn' => subtitleBn.orLocNullable(subtitleEn),
    'ms' => subtitleMs.orLocNullable(subtitleEn),
    _ => subtitleEn,
  };

  /// The 4 options in display order (index 0 == option A == answer index 1).
  List<String> options(String lang) => switch (lang) {
    'fr' => [optionAFr, optionBFr, optionCFr, optionDFr],
    'ar' => [optionAAr, optionBAr, optionCAr, optionDAr],
    'de' => [
      optionADe.orLoc(optionAEn),
      optionBDe.orLoc(optionBEn),
      optionCDe.orLoc(optionCEn),
      optionDDe.orLoc(optionDEn),
    ],
    'nl' => [
      optionANl.orLoc(optionAEn),
      optionBNl.orLoc(optionBEn),
      optionCNl.orLoc(optionCEn),
      optionDNl.orLoc(optionDEn),
    ],
    'tr' => [
      optionATr.orLoc(optionAEn),
      optionBTr.orLoc(optionBEn),
      optionCTr.orLoc(optionCEn),
      optionDTr.orLoc(optionDEn),
    ],
    'id' => [
      optionAId.orLoc(optionAEn),
      optionBId.orLoc(optionBEn),
      optionCId.orLoc(optionCEn),
      optionDId.orLoc(optionDEn),
    ],
    'ur' => [
      optionAUr.orLoc(optionAEn),
      optionBUr.orLoc(optionBEn),
      optionCUr.orLoc(optionCEn),
      optionDUr.orLoc(optionDEn),
    ],
    'bn' => [
      optionABn.orLoc(optionAEn),
      optionBBn.orLoc(optionBEn),
      optionCBn.orLoc(optionCEn),
      optionDBn.orLoc(optionDEn),
    ],
    'ms' => [
      optionAMs.orLoc(optionAEn),
      optionBMs.orLoc(optionBEn),
      optionCMs.orLoc(optionCEn),
      optionDMs.orLoc(optionDEn),
    ],
    _ => [optionAEn, optionBEn, optionCEn, optionDEn],
  };

  /// Optional success explanation shown in the toast. Null → UI shows only the
  /// local title.
  String? congratulation(String lang) => switch (lang) {
    'fr' => congratulationFr,
    'ar' => congratulationAr,
    'de' => congratulationDe.orLocNullable(congratulationEn),
    'nl' => congratulationNl.orLocNullable(congratulationEn),
    'tr' => congratulationTr.orLocNullable(congratulationEn),
    'id' => congratulationId.orLocNullable(congratulationEn),
    'ur' => congratulationUr.orLocNullable(congratulationEn),
    'bn' => congratulationBn.orLocNullable(congratulationEn),
    'ms' => congratulationMs.orLocNullable(congratulationEn),
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
    questionDe,
    questionNl,
    questionTr,
    questionId,
    questionUr,
    questionBn,
    questionMs,
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
    subtitleEn,
    subtitleFr,
    subtitleAr,
    subtitleDe,
    subtitleNl,
    subtitleTr,
    subtitleId,
    subtitleUr,
    subtitleBn,
    subtitleMs,
    optionAEn,
    optionAFr,
    optionAAr,
    optionADe,
    optionANl,
    optionATr,
    optionAId,
    optionAUr,
    optionABn,
    optionAMs,
    optionBEn,
    optionBFr,
    optionBAr,
    optionBDe,
    optionBNl,
    optionBTr,
    optionBId,
    optionBUr,
    optionBBn,
    optionBMs,
    optionCEn,
    optionCFr,
    optionCAr,
    optionCDe,
    optionCNl,
    optionCTr,
    optionCId,
    optionCUr,
    optionCBn,
    optionCMs,
    optionDEn,
    optionDFr,
    optionDAr,
    optionDDe,
    optionDNl,
    optionDTr,
    optionDId,
    optionDUr,
    optionDBn,
    optionDMs,
    congratulationEn,
    congratulationFr,
    congratulationAr,
    congratulationDe,
    congratulationNl,
    congratulationTr,
    congratulationId,
    congratulationUr,
    congratulationBn,
    congratulationMs,
    correctOptionIndex,
    ajr,
    bonusAjr,
  ];
}
