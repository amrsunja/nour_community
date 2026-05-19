import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

class OnboardingScreen4 extends HookConsumerWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final provider = ref.read(onboardingProvider.notifier);
    final profile = ref.watch(profileProvider).profile;
    final isLoading = ref.watch(
      onboardingProvider.select((s) => s.isLoading),
    );

    final selectedLevel = useState<LevelType?>(profile?.level);

    Future<void> onContinue() async {
      final level = selectedLevel.value;
      if (level == null) return;

      final ok = await provider.selectLevel(level);
      if (ok) {
        profile?.level = level;
        provider.changePage(4);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: .center,
              children: [
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.onboarding_screen_4_title,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.display.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ...LevelType.values.indexed.map((entry) {
                  final i = entry.$1;
                  final level = entry.$2;
                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                    child: UIAppearAnimation(
                      delay: Duration(milliseconds: 250 + i * 120),
                      offsetY: 24,
                      child: UILevelCard(
                        title: level.title(l10n),
                        description: level.description(l10n),
                        selected: selectedLevel.value == level,
                        onTap: () => selectedLevel.value = level,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 800),
            offsetY: 16,
            child: UIButton.primary(
              label: 'Continue',
              fullWidth: true,
              isBusy: isLoading,
              onTap: onContinue,
            ),
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}
