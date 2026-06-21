import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';

class OnboardingScreen3 extends HookConsumerWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final provider = ref.read(onboardingProvider.notifier);

    final dhikrCount = useState(31);

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
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 900),
                  beginScale: 0.9,
                  offsetY: 32,
                  child: Stack(
                    children: [
                      Transform.rotate(
                        angle: 0.4,
                        child: UICard(
                          height: 370,
                          width: 250,
                          child: UISpace.zero()
                        ),
                      ),
                      Transform.rotate(
                        angle: -0.2,
                        child: UICard(
                          height: 370,
                          width: 250,
                          child: UISpace.zero()
                        ),
                      ),
                      Transform.rotate(
                        angle: 0.2,
                        child: UICard(
                          height: 370,
                          width: 250,
                          child: UISpace.zero()
                        ),
                      ),
                      _DhikrCard(
                        currentCount: dhikrCount.value,
                        translation: l10n.onboarding_screen_3_dhikr_translation,
                        onChange: (v) => dhikrCount.value = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    l10n.onboarding_screen_3_title,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.display.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 650),
                  child: Text(
                    l10n.onboarding_screen_3_description,
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
            delay: const Duration(milliseconds: 800),
            offsetY: 16,
            child: UIButton.primary(
              label: l10n.common_continue,
              fullWidth: true,
              onTap: () {
                provider.changePage(3);
              },
            ),
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.currentCount,
    required this.translation,
    required this.onChange,
  });

  final int currentCount;
  final String translation;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return Transform.rotate(
      angle: -0.03,
      child: UICard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'سُبْحَانَ اللَّهِ',
              style: theme.typo.inter.largeTitle,
            ),
            const SizedBox(height: 4),
            Text(
              translation,
              style: theme.typo.inter.bodyLarge.copyWith(
                color: UIColorsToken.textYellow,
                fontSize: 12
              ),
            ),
            const SizedBox(height: 24),
            UIDhikrCounter(
              totalCount: 33,
              currentCount: currentCount,
              onChange: onChange,
            ),
          ],
        ),
      ),
    );
  }
}
