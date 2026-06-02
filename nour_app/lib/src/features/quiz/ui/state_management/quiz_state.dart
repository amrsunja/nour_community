import 'package:equatable/equatable.dart';

import '../../data/models/quiz_question_model.dart';
import '../../data/models/quiz_result_model.dart';

/// Hand-written immutable state (no freezed codegen) — matches the rest of the
/// app and keeps the feature buildable without build_runner.
class QuizState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;

  /// First load finished (success or error) — gates the empty state so it
  /// never flashes before `getQuiz` resolves.
  final bool hasLoaded;

  /// User already played today → show the "come back tomorrow" empty state.
  final bool alreadyPlayed;

  final List<QuizQuestionModel> questions;
  final int currentIndex;

  /// `questionId -> selectedOptionIndex` (1-based).
  final Map<int, int> selectedByQuestionId;

  /// Questions the user has validated (answer revealed).
  final Set<int> answeredQuestionIds;

  /// Authoritative scoring from `submitQuiz`; non-null once the quiz is done.
  final QuizResultModel? result;

  const QuizState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasLoaded = false,
    this.alreadyPlayed = false,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedByQuestionId = const {},
    this.answeredQuestionIds = const {},
    this.result,
  });

  int get total => questions.length;

  bool get isFinished => result != null;

  QuizQuestionModel? get currentQuestion =>
      currentIndex >= 0 && currentIndex < questions.length
      ? questions[currentIndex]
      : null;

  bool get isLastQuestion => currentIndex == questions.length - 1;

  int? selectedOf(int questionId) => selectedByQuestionId[questionId];

  bool isAnswered(int questionId) => answeredQuestionIds.contains(questionId);

  /// Current question validated (result revealed)?
  bool get currentAnswered {
    final q = currentQuestion;
    return q != null && answeredQuestionIds.contains(q.id);
  }

  /// Current question has a selection but isn't validated yet.
  bool get canValidate {
    final q = currentQuestion;
    return q != null &&
        !answeredQuestionIds.contains(q.id) &&
        selectedByQuestionId.containsKey(q.id);
  }

  QuizState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? hasLoaded,
    bool? alreadyPlayed,
    List<QuizQuestionModel>? questions,
    int? currentIndex,
    Map<int, int>? selectedByQuestionId,
    Set<int>? answeredQuestionIds,
    QuizResultModel? result,
  }) => QuizState(
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    alreadyPlayed: alreadyPlayed ?? this.alreadyPlayed,
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    selectedByQuestionId: selectedByQuestionId ?? this.selectedByQuestionId,
    answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
    result: result ?? this.result,
  );

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    hasLoaded,
    alreadyPlayed,
    questions,
    currentIndex,
    selectedByQuestionId,
    answeredQuestionIds,
    result,
  ];
}
