import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

class OnboardingScreen5 extends HookConsumerWidget {
  const OnboardingScreen5({super.key});

  static const List<({int value, String display})> _options = [
    (value: 5, display: '5'),
    (value: 10, display: '10'),
    (value: 20, display: '20'),
    (value: 30, display: '30+'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final onboarding = ref.read(onboardingProvider.notifier);
    final profilePresenter = ref.read(profileProvider.notifier);
    final profile = ref.watch(profileProvider).profile;
    final isLoading = ref.watch(
      profileProvider.select((s) => s.isLoading),
    );

    final selected = useState<int?>(profile?.dailyPracticeTime);

    Future<void> onContinue() async {
      final minutes = selected.value;
      if (minutes == null) return;

      final ok = await profilePresenter.setDailyPracticeTime(minutes);
      if (ok) {
        profile?.dailyPracticeTime = minutes;
        onboarding.changePage(5);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
            mainAxisAlignment: .center,
              children: [
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.onboarding_screen_5_title,
                    style: theme.typo.inter.display.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 250),
                  child: Text(
                    l10n.onboarding_screen_5_description,
                    style: theme.typo.inter.bodyLarge.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _OptionsGrid(
                  options: _options,
                  selectedValue: selected.value,
                  unitLabel: l10n.onboarding_screen_5_minutes_per_day,
                  onSelect: (v) => selected.value = v,
                ),
              ],
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 850),
            offsetY: 16,
            child: UIButton.primary(
              label: l10n.common_continue,
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

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({
    required this.options,
    required this.selectedValue,
    required this.unitLabel,
    required this.onSelect,
  });

  final List<({int value, String display})> options;
  final int? selectedValue;
  final String unitLabel;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < options.length; row += 2)
          Padding(
            padding: EdgeInsets.only(top: row == 0 ? 0 : 12),
            child: Row(
              children: [
                Expanded(
                  child: UIAppearAnimation(
                    delay: Duration(milliseconds: 400 + row * 120),
                    offsetY: 24,
                    child: _TimeCard(
                      option: options[row],
                      selected: selectedValue == options[row].value,
                      unitLabel: unitLabel,
                      onTap: () => onSelect(options[row].value),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UIAppearAnimation(
                    delay: Duration(milliseconds: 460 + row * 120),
                    offsetY: 24,
                    child: _TimeCard(
                      option: options[row + 1],
                      selected: selectedValue == options[row + 1].value,
                      unitLabel: unitLabel,
                      onTap: () => onSelect(options[row + 1].value),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.option,
    required this.selected,
    required this.unitLabel,
    required this.onTap,
  });

  final ({int value, String display}) option;
  final bool selected;
  final String unitLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final accent = UIColorsToken.textYellow;

    return UITap(
      onTap: onTap,
      child: UISelecteableCard(
        selected: selected,
        child: SizedBox(
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: theme.typo.inter.hero.copyWith(
                  color: selected ? accent : UIColorsToken.white,
                  fontWeight: FontWeight.w700,
                ),
                child: UIGlowingBlock(
                  shadow: UIShadowToken.texts,
                  child: Text(option.display)
                ),
              ),
              const SizedBox(height: 6),
              Text(
                unitLabel,
                style: theme.typo.inter.bodySmall.copyWith(
                  color: selected ? accent : UIColorsToken.textParagraph,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
