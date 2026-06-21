import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

class OnboardingScreen8 extends HookConsumerWidget {
  const OnboardingScreen8({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final onboarding = ref.read(onboardingProvider.notifier);
    final settingsPresenter = ref.read(settingsProvider.notifier);

    final storedLocale = ref.watch(
      settingsProvider.select((s) => s.data?.locale),
    );
    final isLoading = ref.watch(
      settingsProvider.select((s) => s.isLoading),
    );

    final options = <_LangOption>[
      _LangOption(locale: L10n.en, label: l10n.onboarding_screen_8_lang_en),
      _LangOption(locale: L10n.ar, label: l10n.onboarding_screen_8_lang_ar),
      _LangOption(locale: L10n.fr, label: l10n.onboarding_screen_8_lang_fr),
      _LangOption(locale: L10n.de, label: l10n.onboarding_screen_8_lang_de),
      _LangOption(locale: L10n.nl, label: l10n.onboarding_screen_8_lang_nl),
      _LangOption(locale: L10n.tr, label: l10n.onboarding_screen_8_lang_tr),
      _LangOption(locale: L10n.id, label: l10n.onboarding_screen_8_lang_id),
      _LangOption(locale: L10n.ur, label: l10n.onboarding_screen_8_lang_ur),
      _LangOption(locale: L10n.bn, label: l10n.onboarding_screen_8_lang_bn),
      _LangOption(locale: L10n.ms, label: l10n.onboarding_screen_8_lang_ms),
      _LangOption(locale: L10n.ru, label: l10n.onboarding_screen_8_lang_ru),
    ];

    final selected = useState<Locale>(
      storedLocale ?? L10n.defaultLocale,
    );

    Future<void> onContinue() async {
      final ok = await settingsPresenter.changeAppLanguage(selected.value);
      if (!ok) return;
      onboarding.changePage(8);
    }

    Future<void> onTapLang(Locale locale) async {
      selected.value = locale;
      // Live-preview the language so the rest of the UI updates immediately.
      await settingsPresenter.changeAppLanguage(locale);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const UISpace.vert(80),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      l10n.onboarding_screen_8_title,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.largeTitle.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  for (var i = 0; i < options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UIAppearAnimation(
                        delay: Duration(milliseconds: 250 + i * 90),
                        offsetY: 18,
                        child: _LangCard(
                          label: options[i].label,
                          selected: selected.value.languageCode ==
                              options[i].locale.languageCode,
                          onTap: () => onTapLang(options[i].locale),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 800),
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

class _LangOption {
  const _LangOption({required this.locale, required this.label});

  final Locale locale;
  final String label;
}

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final accent = UIColorsToken.textYellow;

    return UITap(
      onTap: onTap,
      child: UIGradientCard(
        selected: selected,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: theme.typo.inter.title.copyWith(
              color: selected ? accent : UIColorsToken.white,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
