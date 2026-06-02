import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Authoritative scoring returned by the `submitQuiz` edge function.
class QuizResultModel extends Equatable {
  final int correctCount;
  final int total;
  final int earnedAjr;
  final bool bonusAwarded;
  final List<QuizAnswerDetail> details;

  const QuizResultModel({
    required this.correctCount,
    required this.total,
    required this.earnedAjr,
    required this.bonusAwarded,
    required this.details,
  });

  factory QuizResultModel.fromJson(Json json) => QuizResultModel(
    correctCount: json['correct_count'] as int? ?? 0,
    total: json['total'] as int? ?? 0,
    earnedAjr: json['earned_ajr'] as int? ?? 0,
    bonusAwarded: json['bonus_awarded'] as bool? ?? false,
    details: ((json['details'] as List?) ?? const [])
        .map((e) => QuizAnswerDetail.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  bool get isPerfect => total > 0 && correctCount == total;

  @override
  List<Object?> get props => [
    correctCount,
    total,
    earnedAjr,
    bonusAwarded,
    details,
  ];
}

class QuizAnswerDetail extends Equatable {
  final int questionId;
  final int correctOptionIndex;
  final bool wasCorrect;

  const QuizAnswerDetail({
    required this.questionId,
    required this.correctOptionIndex,
    required this.wasCorrect,
  });

  factory QuizAnswerDetail.fromJson(Json json) => QuizAnswerDetail(
    questionId: json['question_id'] as int,
    correctOptionIndex: json['correct_option_index'] as int,
    wasCorrect: json['was_correct'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [questionId, correctOptionIndex, wasCorrect];
}
