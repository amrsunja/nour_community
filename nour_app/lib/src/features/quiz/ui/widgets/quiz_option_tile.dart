import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';

/// One answer row (A/B/C/D). Drives every visual state of the quiz:
///
///  * idle / selected (pre-validate)
///  * correct / wrong / muted (post-validate, [answered] == true)
class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    this.onTap,
  });

  final String letter;
  final String text;

  /// User picked this option.
  final bool selected;

  /// Question has been validated → reveal colors.
  final bool answered;

  /// This option is the correct one.
  final bool isCorrect;

  final VoidCallback? onTap;

  static const _green = UIColorsToken.greenAccent;
  static const _greenBg = Color(0xff1C2C26);
  static const _redBg = Color(0xff2C1E1E);

  _Style _resolve() {
    if (answered) {
      //success
      if (isCorrect) {
        return const _Style(
          bg: _greenBg,
          border: _green,
          chip: _green,
          chipText: UIColorsToken.black,
          text: UIColorsToken.white,
        );
      }
      //Error
      if (selected) {
        return const _Style(
          bg: _redBg,
          border: UIColorsToken.red,
          chip: Colors.transparent, 
          chipText: UIColorsToken.red,
          text: UIColorsToken.white,
        );
      }
      // Untouched options dim out once the answer is revealed.
      return _Style(
        bg: UIColorsToken.bgSurface.withValues(alpha: 0.5),
        border: Colors.transparent,
        chip: UIColorsToken.white.withValues(alpha: 0.03),
        chipText: UIColorsToken.yellow.withValues(alpha: 0.3),
        text: UIColorsToken.white.withValues(alpha: 0.3),
      );
    }

    if (selected) {
      return _Style(
        bg: Color(0xff463B24),
        border: UIColorsToken.textYellow,
        chip: UIColorsToken.yellow,
        chipText: UIColorsToken.black,
        text: UIColorsToken.white,
      );
    }

    return _Style(
      bg: UIColorsToken.bgSurface,
      border: Colors.transparent,
      chip: UIColorsToken.white.withValues(alpha: 0.06),
      chipText: UIColorsToken.yellow,
      text: UIColorsToken.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final s = _resolve();
    final locked = answered;

    return GestureDetector(
      onTap: locked
          ? null
          : () {
              AppVibrations.selection();
              onTap?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: s.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: s.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: s.chip,
                shape: BoxShape.circle,
                border: Border.all(
                  color: s.chipText,
                  width: 0.5
                )
              ),
              child: Text(
                letter,
                style: typo.inter.caption.copyWith(
                  color: s.chipText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const UISpace.horz(12),
            Expanded(
              child: Text(
                text,
                style: typo.inter.title.copyWith(color: s.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Style {
  const _Style({
    required this.bg,
    required this.border,
    required this.chip,
    required this.chipText,
    required this.text,
  });

  final Color bg;
  final Color border;
  final Color chip;
  final Color chipText;
  final Color text;
}
