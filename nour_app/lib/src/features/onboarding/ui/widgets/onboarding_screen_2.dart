import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';

class OnboardingScreen2 extends ConsumerWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final provider = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ToolCardsStack(
                  streakRewardLabel: l10n.onboarding_screen_2_card_streak_reward,
                  ajrCounterLabel: l10n.onboarding_screen_2_card_ajr_counter,
                  dailyDhikrLabel: l10n.onboarding_screen_2_card_daily_dhikr,
                ),
                const SizedBox(height: 48),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    l10n.onboarding_screen_2_title,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.display.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 750),
                  child: Text(
                    l10n.onboarding_screen_2_description,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.bodyLarge.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 900),
            offsetY: 16,
            child: UIButton.primary(
              label: l10n.common_continue,
              fullWidth: true,
              onTap: () {
                provider.changePage(2);
              },
            ),
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}

class _ToolCardsStack extends StatelessWidget {
  const _ToolCardsStack({
    required this.streakRewardLabel,
    required this.ajrCounterLabel,
    required this.dailyDhikrLabel,
  });

  final String streakRewardLabel;
  final String ajrCounterLabel;
  final String dailyDhikrLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Back card — centered, slight tilt
          Align(
            alignment: const Alignment(0.4, -1.3),
            child: UIAppearAnimation(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 800),
              offsetY: 40,
              beginScale: 0.85,
              child: Transform.rotate(
                angle: 0.1,
                child: UIToolCard(
                  illustration: Assets.images.illustration10.image(
                    filterQuality: FilterQuality.high,
                  ),
                  label: streakRewardLabel,
                ),
              ),
            ),
          ),
          // Front-right card
          Align(
            alignment: const Alignment(0.85, 1.5),
            child: UIAppearAnimation(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 800),
              offsetY: 40,
              beginScale: 0.85,
              child: Transform.rotate(
                angle: 0.22,
                child: UIToolCard(
                  illustration: Assets.images.illustration5.image(
                    filterQuality: FilterQuality.high,
                  ),
                  label: ajrCounterLabel,
                ),
              ),
            ),
          ),
          // Front-left card
          Align(
            alignment: const Alignment(-0.85, 0.9),
            child: UIAppearAnimation(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 800),
              offsetY: 40,
              beginScale: 0.85,
              child: Transform.rotate(
                angle: -0.22,
                child: UIToolCard(
                  illustration: Assets.images.illustration7.image(
                    filterQuality: FilterQuality.high,
                  ),
                  label: dailyDhikrLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
