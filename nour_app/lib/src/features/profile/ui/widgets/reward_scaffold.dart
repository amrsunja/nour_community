import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Shared celebratory layout for both reward screens: branded sunrise backdrop,
/// an animated hero [badge], a title/subtitle, a [content] slot (week row or
/// stats), and the two bottom actions. Every element makes a staggered
/// entrance for the "wow" moment.
class RewardScaffold extends StatelessWidget {
  const RewardScaffold({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final Widget badge;
  final String title;
  final String subtitle;
  final Widget content;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UIGradientLinedScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // ---- Hero badge with pulse glow + intro pop ----
            _AnimatedBadge(badge: badge),

            const SizedBox(height: 36),

            Text(
              title,
              textAlign: TextAlign.center,
              style: typo.inter.hero.copyWith(
                color: UIColorsToken.white,
                fontWeight: FontWeight.w700,
              ),
            )
                .animate(delay: const Duration(milliseconds: 300))
                .fadeIn(duration: const Duration(milliseconds: 500))
                .moveY(begin: 18, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 12),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: typo.inter.bodyLarge.copyWith(
                color: UIColorsToken.textParagraph,
              ),
            )
                .animate(delay: const Duration(milliseconds: 450))
                .fadeIn(duration: const Duration(milliseconds: 500))
                .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 32),

            content,

            const Spacer(flex: 4),

            UIButton.primary(
              label: primaryLabel,
              fullWidth: true,
              onTap: onPrimary,
            )
                .animate(delay: const Duration(milliseconds: 750))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 6),

            UIButton.textual(
              label: secondaryLabel,
              fullWidth: true,
              onTap: onSecondary,
            )
                .animate(delay: const Duration(milliseconds: 850))
                .fadeIn(duration: const Duration(milliseconds: 450)),
          ],
        ),
      ),
    );
  }
}

/// Hero badge: a soft repeating glow pulse behind a one-shot pop + shimmer.
class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({required this.badge});

  final Widget badge;

  @override
  Widget build(BuildContext context) {
    return UiRepeatingStarsAnimation(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing glow.
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  UIColorsToken.yellow.withValues(alpha: 0.22),
                  UIColorsToken.yellow.withValues(alpha: 0.0),
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
      
          badge
              .animate()
              .scaleXY(
                begin: 0.5,
                end: 1,
                duration: const Duration(milliseconds: 850),
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: const Duration(milliseconds: 450))
              .then()
              .shimmer(
                duration: const Duration(milliseconds: 1500),
                color: UIColorsToken.white.withValues(alpha: 0.35),
              ),
        ],
      ),
    );
  }
}
