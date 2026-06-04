import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';

class OnboardingScreen1 extends ConsumerWidget {
  const OnboardingScreen1({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 900),
                  offsetY: 32,
                  beginScale: 0.92,
                  child: UiRepeatingStarsAnimation(
                    child: UIGlowingBlock(
                      child: Assets.images.illustration3.image(
                        filterQuality: .high
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 350),
                  child: Text(
                    l10n.onboarding_screen_1_title,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.hero.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 550),
                  child: Text(
                    l10n.onboarding_screen_1_description,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.bodyLarge.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                ),
              ],
            ),
          ),

          UIButton.primary(
            label: l10n.onboarding_lets_get_started,
            fullWidth: true,
            onTap: () {
              provider.changePage(1);
            },
          ),
          UISpace.vert(10)
        ],
      ),
    );
  }
}
