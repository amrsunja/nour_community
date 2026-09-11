import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

import '../state_management/mosque_onboarding_provider.dart';
import 'mosque_onboarding_scaffold.dart';

/// "Choose your language" (Figma Onboarding 21). Live-previews the app locale
/// like the worshipper onboarding does.
class MosqueOnboardingLanguageScreen extends ConsumerWidget {
  const MosqueOnboardingLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);
    final settings = ref.read(settingsProvider.notifier);
    final storedLocale = ref.watch(settingsProvider.select((s) => s.data?.locale));
    final current = (storedLocale ?? L10n.defaultLocale).languageCode;

    final options = <(Locale, String)>[
      (L10n.en, l10n.onboarding_screen_8_lang_en),
      (L10n.ar, l10n.onboarding_screen_8_lang_ar),
      (L10n.fr, l10n.onboarding_screen_8_lang_fr),
      (L10n.de, l10n.onboarding_screen_8_lang_de),
      (L10n.nl, l10n.onboarding_screen_8_lang_nl),
      (L10n.tr, l10n.onboarding_screen_8_lang_tr),
      (L10n.id, l10n.onboarding_screen_8_lang_id),
      (L10n.ur, l10n.onboarding_screen_8_lang_ur),
      (L10n.bn, l10n.onboarding_screen_8_lang_bn),
      (L10n.ms, l10n.onboarding_screen_8_lang_ms),
      (L10n.ru, l10n.onboarding_screen_8_lang_ru),
    ];

    return MosqueOnboardingStepScaffold(
      children: [
        const UISpace.vert(60),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          child: Text(
            l10n.onboarding_screen_8_title,
            textAlign: TextAlign.center,
            style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
          ),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UIAppearAnimation(
              delay: Duration(milliseconds: 250 + i * 90),
              offsetY: 18,
              child: UITap(
                onTap: () async {
                  await settings.changeAppLanguage(options[i].$1);
                  await presenter.setLanguage(options[i].$1.languageCode);
                },
                child: UISelecteableCard(
                  selected: current == options[i].$1.languageCode,
                  child: Center(
                    child: Text(
                      options[i].$2,
                      style: theme.typo.inter.title.copyWith(
                        color: current == options[i].$1.languageCode ? UIColorsToken.textYellow : UIColorsToken.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
      bottom: UIButton.primary(
        label: l10n.common_continue,
        fullWidth: true,
        onTap: () async {
          await presenter.setLanguage(current);
          await presenter.next();
        },
      ),
    );
  }
}
