import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../state_management/mosque_onboarding_provider.dart';
import 'countries.dart';
import 'mosque_onboarding_scaffold.dart';

/// "Choose your country" (Figma Onboarding 30).
class MosqueOnboardingCountryScreen extends HookConsumerWidget {
  const MosqueOnboardingCountryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);
    final selected = ref.watch(mosqueOnboardingProvider.select((s) => s.draft.countryCode)) ?? 'FR';
    final query = useState('');

    final visible = kCountries
        .where((c) => query.value.isEmpty || c.name.toLowerCase().contains(query.value.toLowerCase()))
        .toList();

    return MosqueOnboardingStepScaffold(
      children: [
        const UISpace.vert(40),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          child: Text(
            l10n.mosque_onboarding_country_title,
            textAlign: TextAlign.center,
            style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
          ),
        ),
        const SizedBox(height: 24),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 200),
          offsetY: 16,
          child: UIInputField(
            hintText: l10n.mosque_onboarding_country_search,
            onChanged: (v) => query.value = v,
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < visible.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: UIAppearAnimation(
              delay: Duration(milliseconds: 250 + (i < 8 ? i * 60 : 0)),
              offsetY: 14,
              child: _CountryRow(
                country: visible[i],
                selected: visible[i].code == selected,
                onTap: () => presenter.setCountry(visible[i].code),
              ),
            ),
          ),
      ],
      bottom: UIButton.primary(
        label: l10n.common_continue,
        fullWidth: true,
        onTap: () async {
          if (ref.read(mosqueOnboardingProvider).draft.countryCode == null) {
            await presenter.setCountry(selected);
          }
          await presenter.next();
        },
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({required this.country, required this.selected, required this.onTap});
  final Country country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? const Color(0xff252219) : UIColorsToken.bgSurface,
          border: Border.all(
            color: selected ? UIColorsToken.textYellow : Colors.transparent,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                country.name,
                style: theme.typo.inter.title.copyWith(
                  color: selected ? UIColorsToken.textYellow : UIColorsToken.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
