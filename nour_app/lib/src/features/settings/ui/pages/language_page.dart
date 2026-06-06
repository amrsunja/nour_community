import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

/// Settings › Language. Mirrors onboarding screen 8 but persists the selection
/// immediately on tap (no continue button). Changing the language live-updates
/// the whole UI. Local settings are the single source of truth for language.
@RoutePage()
class LanguagePage extends HookConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final settingsPresenter = ref.read(settingsProvider.notifier);

    final storedLocale = ref.watch(
      settingsProvider.select((s) => s.data?.locale),
    );

    final options = <_LangOption>[
      _LangOption(locale: L10n.en, label: l10n.onboarding_screen_8_lang_en),
      _LangOption(locale: L10n.ar, label: l10n.onboarding_screen_8_lang_ar),
      _LangOption(locale: L10n.fr, label: l10n.onboarding_screen_8_lang_fr),
    ];

    final activeCode =
        (storedLocale ?? L10n.defaultLocale).languageCode;

    Future<void> onSelect(Locale locale) async {
      await settingsPresenter.changeAppLanguage(locale);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            title: l10n.settings_language,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                12,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.settings_language_info,
                    style: theme.typo.inter.bodyMedium.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                  const UISpace.vert(20),
                  for (var i = 0; i < options.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                      child: UIAppearAnimation(
                        delay: Duration(milliseconds: 120 + i * 90),
                        offsetY: 18,
                        child: _LangCard(
                          label: options[i].label,
                          selected:
                              activeCode == options[i].locale.languageCode,
                          onTap: () => onSelect(options[i].locale),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
