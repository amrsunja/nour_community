import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/ui/state_management/mosque_search_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosques_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_search_card.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';
import 'package:nour/src/features/onboarding/domain/onboarding_step.dart';

/// Onboarding step "Select a mosque" (Figma Onboarding 32) — sits between
/// "How much time daily?" and "Choose a voice". Picks the principal mosque.
class OnboardingScreenMosque extends HookConsumerWidget {
  const OnboardingScreenMosque({super.key});

  static const _nextPage = OnboardingStep.screen6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final onboarding = ref.read(onboardingProvider.notifier);
    final search = ref.read(mosqueSearchProvider.notifier);
    final state = ref.watch(mosqueSearchProvider);
    final my = ref.watch(myMosquesProvider);
    final enabled = ref.watch(appConfigProvider.select((c) => c.mosquesEnabled));
    final selected = useState<int?>(my.principal?.id);
    final started = useState(false);

    // Lazy init: only when the page becomes visible-ish (first build is fine).
    useEffect(() {
      if (!enabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onboarding.changePage(_nextPage));
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!started.value) {
          started.value = true;
          search.init();
          ref.read(myMosquesProvider.notifier).init();
        }
      });
      return null;
    }, const []);

    Future<void> onContinue() async {
      final id = selected.value;
      if (id != null && id != my.principal?.id) {
        await ref.read(myMosquesProvider.notifier).save(principal: id, secondary: my.secondary?.id);
      }
      onboarding.changePage(_nextPage);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const UISpace.vert(60),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Text(l10n.onboarding_mosque_title, textAlign: TextAlign.center,
                      style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white)),
                ),
                const SizedBox(height: 8),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Text(l10n.onboarding_mosque_subtitle, textAlign: TextAlign.center,
                      style: theme.typo.inter.bodyLarge.copyWith(color: UIColorsToken.textParagraph)),
                ),
                const SizedBox(height: 24),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 300),
                  offsetY: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: UIInputField(
                          hintText: l10n.mosque_search_hint,
                          onChanged: search.setQuery,
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      const SizedBox(width: 8),
                      UITap(
                        onTap: search.locate,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.my_location, color: UIColorsToken.textYellow, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(state.query.trim().isEmpty ? l10n.mosque_search_near_you_short : l10n.mosque_search_results,
                    style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                const SizedBox(height: 8),
                Expanded(
                  child: state.isLoading && state.results.isEmpty
                      ? const Center(child: UICircularProgressBar())
                      : state.results.isEmpty
                          ? Center(
                              child: Text(l10n.mosque_search_empty, textAlign: TextAlign.center,
                                  style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)))
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.results.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final m = state.results[i];
                                return MosqueSearchCard(
                                  item: m,
                                  l10n: l10n,
                                  compact: true,
                                  isMine: selected.value == m.id,
                                  onTap: () => selected.value = selected.value == m.id ? null : m.id,
                                  onAdd: () => selected.value = selected.value == m.id ? null : m.id,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: UIButton.textual(
                  label: l10n.onboarding_maybe_later,
                  fullWidth: true,
                  contentColor: UIColorsToken.white,
                  onTap: () => onboarding.changePage(_nextPage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: UIButton.primary(
                  label: l10n.common_continue,
                  fullWidth: true,
                  isBusy: my.isLoading,
                  onTap: onContinue,
                ),
              ),
            ],
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}
