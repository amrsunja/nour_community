import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Top toast revealed after the user validates an answer. Slides down + fades
/// in, glows softly, and carries the verdict: a green check (correct, with the
/// earned-ajr badge) or a muted cross (wrong).
class QuizResultToast extends StatelessWidget {
  const QuizResultToast({
    super.key,
    required this.isCorrect,
    required this.title,
    this.body,
    this.ajr,
  });

  final bool isCorrect;
  final String title;
  final String? body;

  /// Ajr earned for this question — shown as a `+N` badge when correct.
  final int? ajr;

  static const _green = UIColorsToken.greenAccent;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    final accent = isCorrect ? _green : UIColorsToken.white.withValues(alpha: 0.7);

    final card = UICard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: isCorrect ? Color(0xff404F3B) : Color(0xff191F17),
      child: Stack(
        alignment: .center,
        children: [
          if (isCorrect && (ajr ?? 0) > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: UIColorsToken.yellow.withValues(alpha: 0.18),
                  border: .all(color: UIColorsToken.yellow, width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+$ajr',
                  style: typo.inter.caption.copyWith(
                    color: UIColorsToken.textYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                child: Image.asset(
                  isCorrect 
                    ? Assets.images.illustration2.path
                    : Assets.images.illustration1.path
                ),
              ).animate()
                .fade(duration: Duration(seconds: 1))
                .rotate(duration: Duration(seconds: 1))
                .scale(curve: Curves.bounceOut, duration: Duration(seconds: 1)),
              const UISpace.vert(10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: typo.inter.largeTitle.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
              if (body != null) ...[
                const UISpace.vert(6),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: typo.inter.title.copyWith(
                    fontSize: isCorrect ? 12 : null,
                    color: isCorrect
                      ? UIColorsToken.textParagraph
                      : _green,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return card
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 320))
        .moveY(begin: 30, end: 0, curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 420))
        .then()
        .shimmer(
          duration: const Duration(milliseconds: 1100),
          color: accent.withValues(alpha: 0.25),
        );
  }
}
