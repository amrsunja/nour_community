import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/mosque_onboarding/data/datasources/mosque_onboarding_local_datasource.dart';
import 'package:nour/src/features/mosque_onboarding/data/models/mosque_onboarding_draft.dart';

enum _ProfileType { mosqueManager, worshipper }

/// "How will you use Nour?" — mosque manager vs worshipper (Figma
/// Onboarding 27 / 29). Worshipper → anonymous session + classic onboarding.
/// Mosque manager → sessionless mosque onboarding (draft stored locally).
@RoutePage()
class ProfileTypePage extends HookConsumerWidget {
  const ProfileTypePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final auth = ref.read(authProvider.notifier);
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final selected = useState(_ProfileType.worshipper);

    Future<void> onStart() async {
      if (isLoading) return;
      switch (selected.value) {
        case _ProfileType.worshipper:
          ref.read(analyticsRepoProvider).trackOnboardingPage(0);
          await auth.startAsWorshipper();
        case _ProfileType.mosqueManager:
          await ref.read(mosqueOnboardingLocalDataProvider).write(MosqueOnboardingDraft.empty);
          nav.toMosqueOnboarding();
      }
    }

    return UIGradientLinedScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      l10n.profile_type_title,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.display.copyWith(color: UIColorsToken.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 250),
                    offsetY: 18,
                    child: _TypeCard(
                      title: l10n.profile_type_mosque_title,
                      subtitle: l10n.profile_type_mosque_subtitle,
                      icon: Icons.mosque_outlined,
                      selected: selected.value == _ProfileType.mosqueManager,
                      onTap: () => selected.value = _ProfileType.mosqueManager,
                    ),
                  ),
                  const SizedBox(height: 12),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 350),
                    offsetY: 18,
                    child: _TypeCard(
                      title: l10n.profile_type_user_title,
                      subtitle: l10n.profile_type_user_subtitle,
                      icon: Icons.self_improvement_outlined,
                      selected: selected.value == _ProfileType.worshipper,
                      onTap: () => selected.value = _ProfileType.worshipper,
                    ),
                  ),
                ],
              ),
            ),
            UIAppearAnimation(
              delay: const Duration(milliseconds: 600),
              offsetY: 16,
              child: UIButton.primary(
                label: l10n.onboarding_lets_get_started,
                fullWidth: true,
                isBusy: isLoading,
                onTap: onStart,
              ),
            ),
            const UISpace.vert(10),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: UISelecteableCard(
        selected: selected,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typo.inter.title.copyWith(
                      color: selected ? UIColorsToken.textYellow : UIColorsToken.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 44, color: selected ? UIColorsToken.textYellow : UIColorsToken.textParagraph),
          ],
        ),
      ),
    );
  }
}
