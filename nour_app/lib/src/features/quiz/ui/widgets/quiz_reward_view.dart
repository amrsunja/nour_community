import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/audio/sound_effect_provider.dart';

import 'quiz_reward_badge.dart';

/// Final celebration (screen 6). Branded sunrise backdrop, an animated medallion
/// badge, the verdict copy, an optional bonus-ajr chip, the score/ajr stats, and
/// the two closing actions — every element staggered for a "wow" reveal.
class QuizRewardView extends HookConsumerWidget {
  const QuizRewardView({
    super.key,
    required this.l10n,
    required this.correctCount,
    required this.total,
    required this.ajrEarned,
    required this.bonusAjr,
    required this.isPerfect,
    required this.onPrimary,
    required this.onSecondary,
  });

  final AppLocale l10n;
  final int correctCount;
  final int total;
  final int ajrEarned;

  /// Extra ajr from the perfect-run bonus. Null/0 → chip hidden.
  final int? bonusAjr;
  final bool isPerfect;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final showBonus = isPerfect && (bonusAjr ?? 0) > 0;

    // Reward sound, once, in sync with the entrance animations.
    useEffect(() {
      ref.read(soundEffectServiceProvider).playReward();
      return null;
    }, const []);


    return UIGradientLinedScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            UiRepeatingStarsAnimation(
              child: _Halo(
                child: const QuizRewardBadge()
                  .animate()
                  .scaleXY(
                    begin: 0.5,
                    end: 1,
                    duration: const Duration(milliseconds: 850),
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 450))
              ),
            ),

            const SizedBox(height: 28),

            Text(
                  isPerfect
                      ? l10n.quiz_reward_perfect_title
                      : l10n.quiz_reward_title,
                  textAlign: TextAlign.center,
                  style: typo.inter.display.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w700,
                  ),
                )
                .animate(delay: const Duration(milliseconds: 300))
                .fadeIn(duration: const Duration(milliseconds: 500))
                .moveY(begin: 18, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 10),

            Text(
                  isPerfect
                      ? l10n.quiz_reward_perfect_subtitle(total)
                      : l10n.quiz_reward_subtitle(correctCount, total),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: typo.inter.bodyLarge.copyWith(
                    color: UIColorsToken.textParagraph,
                  ),
                )
                .animate(delay: const Duration(milliseconds: 450))
                .fadeIn(duration: const Duration(milliseconds: 500))
                .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 22),

            if (showBonus)
              _BonusChip(label: l10n.quiz_reward_bonus(bonusAjr!))
                  .animate(delay: const Duration(milliseconds: 600))
                  .fadeIn(duration: const Duration(milliseconds: 450))
                  .scaleXY(begin: 0.8, end: 1, curve: Curves.easeOutBack),

            if (showBonus) const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    value: '$correctCount/$total',
                    label: l10n.quiz_reward_score,
                  ),
                ),
                const UISpace.horz(12),
                Expanded(
                  child: _StatBox(
                    value: '+$ajrEarned',
                    label: l10n.reward_ajr_earned,
                    highlight: true,
                  ),
                ),
              ],
            )
                .animate(delay: const Duration(milliseconds: 720))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),

            const Spacer(flex: 4),

            UIButton.primary(
                  label: l10n.reward_alhamdulilah,
                  fullWidth: true,
                  onTap: onPrimary,
                )
                .animate(delay: const Duration(milliseconds: 850))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 6),

            UIButton.textual(
                  label: l10n.reward_go_further,
                  fullWidth: true,
                  onTap: onSecondary,
                )
                .animate(delay: const Duration(milliseconds: 950))
                .fadeIn(duration: const Duration(milliseconds: 450)),
          ],
        ),
      ),
    );
  }
}

/// Breathing radial glow behind the badge.
class _Halo extends StatelessWidget {
  const _Halo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                UIColorsToken.yellow,
                UIColorsToken.yellow.withValues(alpha: 0),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 0.85,
          end: 1.15,
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeInOut,
        ),
        child,
      ],
    );
  }
}

class _BonusChip extends StatelessWidget {
  const _BonusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      decoration: BoxDecoration(
        color: UIColorsToken.yellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: .all(color: UIColorsToken.yellow, width: 0.5),
        boxShadow: UIShadowToken.illustration,
      ),
      child: Text(
        label,
        style: typo.inter.titleMedium.copyWith(
          color: UIColorsToken.textYellow,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          UIGlowingBlock(
            shadow: UIShadowToken.texts,
            child: Text(
              value,
              style: typo.inter.titleMedium.copyWith(
                color: highlight ? UIColorsToken.textYellow : UIColorsToken.white,
              ),
            ),
          ),
          const UISpace.vert(2),
          Text(
            label,
            style: typo.inter.headline.copyWith(
              color: highlight ? UIColorsToken.textYellow : UIColorsToken.textParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
