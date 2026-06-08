import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/audio/sound_effect_provider.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/navigation_services.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

import '../../data/models/quiz_question_model.dart';
import '../state_management/quiz_provider.dart';
import '../state_management/quiz_state.dart';
import '../widgets/quiz_progress_dots.dart';
import '../widgets/quiz_question_card.dart';
import '../widgets/quiz_result_toast.dart';
import '../widgets/quiz_reward_view.dart';

@RoutePage()
class QuizPage extends HookConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(quizProvider.notifier);
    final state = ref.watch(quizProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    final pageController = usePageController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    // Keep the PageView in sync with the presenter-driven index.
    ref.listen(quizProvider.select((s) => s.currentIndex), (_, next) {
      if (!pageController.hasClients) return;
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });

    if (state.result != null) {
      return _Reward(l10n: l10n, nav: nav, state: state);
    }

    return Stack(
      children: [
        UIGradientLinedScaffold(
          bgArabicText: 'اختبار يومي',
          appBar: UIAppBar(title: l10n.tools_daily_quiz, onBack: context.pop),
          body: _body(context, ref, l10n, presenter, state, langCode, pageController),
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocale l10n,
    QuizPresenter presenter,
    QuizState state,
    String langCode,
    PageController pageController,
  ) {
    if (!state.hasLoaded) {
      return const Center(child: UICircularProgressBar());
    }

    if (state.alreadyPlayed || state.questions.isEmpty) {
      return _Empty(l10n: l10n, alreadyPlayed: state.alreadyPlayed);
    }

    final current = state.currentQuestion!;
    final answered = state.currentAnswered;
    final selected = state.selectedOf(current.id);
    final isCorrect = selected != null && current.isCorrect(selected);

    return Column(
      children: [
        const UISpace.vert(8),
        QuizProgressDots(total: state.total, currentIndex: state.currentIndex),
        const UISpace.vert(16),
        Text(
          l10n.quiz_question_progress(state.currentIndex + 1, state.total),
          style: UITheme.of(context).typo.inter.title.copyWith(
            color: UIColorsToken.textYellow,
          ),
        ),
        const UISpace.vert(8),
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final q = state.questions[index];
                  return QuizQuestionCard(
                    key: ValueKey(q.id),
                    question: q,
                    langCode: langCode,
                    selectedIndex: state.selectedOf(q.id),
                    answered: state.isAnswered(q.id),
                    onSelect: presenter.selectOption,
                  );
                },
              ),
              if (answered)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                    child: QuizResultToast(
                      key: ValueKey('toast_${current.id}'),
                      isCorrect: isCorrect,
                      title: isCorrect
                          ? l10n.quiz_correct_title
                          : l10n.quiz_wrong_title,
                      body: _toastBody(l10n, current, langCode, isCorrect),
                      ajr: isCorrect ? current.ajr : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: answered
              ? UIButton.primary(
                  label: l10n.common_continue,
                  fullWidth: true,
                  isBusy: state.isSubmitting,
                  onTap: presenter.onContinue,
                )
              : _ValidateButton(
                  enabled: state.canValidate,
                  label: l10n.quiz_validate,
                  onTap: () {
                    // Feedback sound fires on the same gesture that reveals the
                    // result, so it stays in sync with the toast.
                    ref
                        .read(soundEffectServiceProvider)
                        .playQuizAnswer(isCorrect: isCorrect);
                    presenter.validate();
                  },
                ),
        ),
      ],
    );
  }

  /// Correct → the question's congratulation (may be null → no body).
  /// Wrong → "Good answer: <correct option>".
  String? _toastBody(
    AppLocale l10n,
    QuizQuestionModel question,
    String langCode,
    bool isCorrect,
  ) {
    if (isCorrect) return question.congratulation(langCode);
    final correct = question.options(langCode)[question.correctOptionIndex - 1];
    return l10n.quiz_good_answer(correct);
  }
}

/// Validate button greys out (and ignores taps) until an option is picked.
class _ValidateButton extends StatelessWidget {
  const _ValidateButton({
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  final bool enabled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: UIButton.primary(label: label, fullWidth: true, onTap: onTap),
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.l10n, required this.nav, required this.state});

  final AppLocale l10n;
  final NavigationServices nav;
  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;

    // Base ajr = sum of per-question ajr for the answers the user got right.
    // Bonus = whatever the server awarded beyond that (perfect-run bonus).
    var base = 0;
    for (final q in state.questions) {
      final sel = state.selectedOf(q.id);
      if (sel != null && q.isCorrect(sel)) base += q.ajr;
    }
    final bonus = (result.earnedAjr - base).clamp(0, result.earnedAjr);

    return QuizRewardView(
      l10n: l10n,
      correctCount: result.correctCount,
      total: result.total,
      ajrEarned: result.earnedAjr,
      bonusAjr: bonus,
      isPerfect: result.isPerfect,
      onPrimary: context.pop,
      onSecondary: () {
        context.pop();
        nav.toDhikrsList();
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n, required this.alreadyPlayed});

  final AppLocale l10n;
  final bool alreadyPlayed;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.illustration14.image(height: 96),
            const UISpace.vert(20),
            Text(
              alreadyPlayed
                  ? l10n.quiz_already_played_title
                  : l10n.quiz_empty_title,
              textAlign: TextAlign.center,
              style: typo.inter.titleMedium.copyWith(
                color: UIColorsToken.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const UISpace.vert(8),
            Text(
              alreadyPlayed
                  ? l10n.quiz_already_played_subtitle
                  : l10n.quiz_empty_subtitle,
              textAlign: TextAlign.center,
              style: typo.inter.body.copyWith(
                color: UIColorsToken.textParagraph,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }
}
