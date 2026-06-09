import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';

import '../../data/quiz_repo.dart';
import 'quiz_state.dart';

final quizProvider = StateNotifierProvider.autoDispose<QuizPresenter, QuizState>(
  (ref) => QuizPresenter(
    repo: ref.read(quizRepoProvider),
    appEvents: ref.read(appEventProvider),
    analytics: ref.read(analyticsRepoProvider),
  ),
);

class QuizPresenter extends Presenter<QuizState> {
  final QuizRepo repo;
  final AppEvents appEvents;
  final AnalyticsRepo analytics;

  QuizPresenter({
    required this.repo,
    required this.appEvents,
    required this.analytics,
  }) : super(const QuizState());

  Future<void> init() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final res = await repo.getQuiz();

    res.when(
      (bundle) {
        // Participation: only count a fresh attempt, not a re-open of a
        // quiz already played today.
        if (!bundle.alreadyPlayed) analytics.trackQuizStart();
        return state = state.copyWith(
          isLoading: false,
          hasLoaded: true,
          questions: bundle.questions,
          alreadyPlayed: bundle.alreadyPlayed,
        );
      },
      (error) {
        state = state.copyWith(isLoading: false, hasLoaded: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  /// Pick an option (1-based). No-op once the question is validated.
  void selectOption(int oneBasedIndex) {
    final q = state.currentQuestion;
    if (q == null || state.isAnswered(q.id)) return;

    state = state.copyWith(
      selectedByQuestionId: {...state.selectedByQuestionId, q.id: oneBasedIndex},
    );
  }

  /// Reveal the answer for the current question (drives the result + toast).
  void validate() {
    final q = state.currentQuestion;
    if (q == null || !state.canValidate) return;

    state = state.copyWith(
      answeredQuestionIds: {...state.answeredQuestionIds, q.id},
    );
  }

  /// Continue: advance to the next question, or submit + finish on the last.
  Future<void> onContinue() async {
    if (!state.currentAnswered) return;

    if (state.isLastQuestion) {
      await _submit();
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  Future<void> _submit() async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);

    final res = await repo.submitQuiz(state.selectedByQuestionId);

    res.when(
      (result) {
        analytics.trackQuizComplete(
          score: result.correctCount,
          total: result.total,
        );
        return state = state.copyWith(isSubmitting: false, result: result);
      },
      (error) {
        state = state.copyWith(isSubmitting: false);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }
}
