import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/quiz_question_model.dart';
import 'quiz_option_tile.dart';

/// Scrollable body of a single quiz step: the prompt, an optional Arabic focal
/// block (Arabic text + transcription), an optional subtitle, then the four
/// answer options. Everything makes a soft staggered entrance.
class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.langCode,
    required this.selectedIndex,
    required this.answered,
    required this.onSelect,
  });

  final QuizQuestionModel question;
  final String langCode;

  /// 1-based selected option, or null.
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onSelect;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final arabic = question.arabicText;
    final transcription = question.transcription(langCode);
    final subtitle = question.subtitle(langCode);
    final options = question.options(langCode);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question(langCode),
            textAlign: TextAlign.center,
            style: typo.inter.title.copyWith(color: UIColorsToken.white),
          ),
          if (arabic != null) ...[
            const UISpace.vert(20),
            Text(
              arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: typo.inter.hero.copyWith(
                color: UIColorsToken.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (transcription != null) ...[
              const UISpace.vert(8),
              Text(
                transcription,
                textAlign: TextAlign.center,
                style: typo.inter.bodySmall.copyWith(
                  color: UIColorsToken.yellow,
                ),
              ),
            ],
          ],
          if (subtitle != null) ...[
            const UISpace.vert(12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium,
            ),
          ],
          const UISpace.vert(28),
          ...List.generate(options.length, (i) {
            final optionIndex = i + 1; // options are 1-based
            return Padding(
              padding: EdgeInsets.only(bottom: i == options.length - 1 ? 0 : 12),
              child:
                  QuizOptionTile(
                        letter: _letters[i],
                        text: options[i],
                        selected: selectedIndex == optionIndex,
                        answered: answered,
                        isCorrect: question.isCorrect(optionIndex),
                        onTap: () => onSelect(optionIndex),
                      )
                      .animate(delay: Duration(milliseconds: 90 * i))
                      .fadeIn(duration: const Duration(milliseconds: 360))
                      .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
            );
          }),
        ],
      ),
    );
  }
}
