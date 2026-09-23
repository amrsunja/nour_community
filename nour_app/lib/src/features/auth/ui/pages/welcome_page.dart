import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosque_onboarding/data/datasources/mosque_onboarding_local_datasource.dart';

/// First screen when there is NO session (fresh install, logged out).
/// "Welcome to Nour" → profile type selection. A pending mosque-onboarding
/// draft offers to resume where the manager left off.
@RoutePage()
class WelcomePage extends HookConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);

    final draftFuture = useMemoized(() => ref.read(mosqueOnboardingLocalDataProvider).read());
    final draft = useFuture(draftFuture).data;

    return UIGradientLinedScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 900),
                    offsetY: 32,
                    beginScale: 0.92,
                    child: UiRepeatingStarsAnimation(
                      child: UIGlowingBlock(
                        child: Assets.images.illustration3.image(filterQuality: FilterQuality.high),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 350),
                    child: Text(
                      l10n.onboarding_screen_1_title,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.hero.copyWith(color: UIColorsToken.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 550),
                    child: Text(
                      l10n.onboarding_screen_1_description,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.bodyLarge.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ),
                ],
              ),
            ),
            if (draft != null) ...[
              UIButton.secondary(
                label: l10n.mosque_onboarding_resume,
                fullWidth: true,
                onTap: nav.toMosqueOnboarding,
              ),
              const UISpace.vert(12),
            ],
            UIButton.primary(
              label: l10n.onboarding_lets_get_started,
              fullWidth: true,
              onTap: nav.toProfileType,
            ),
            const UISpace.vert(10),
          ],
        ),
      ),
    ).animate(effects: [FadeEffect(duration: const Duration(milliseconds: 600))]);
  }
}
