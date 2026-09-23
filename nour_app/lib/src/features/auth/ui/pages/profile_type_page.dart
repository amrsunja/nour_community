import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/onboarding/domain/onboarding_step.dart';

enum _ProfileType { mosqueManager, worshipper }

/// "How will you use Nour?" — mosque manager vs worshipper (Figma
/// Onboarding 27 / 29). Worshipper → anonymous session + classic onboarding.
/// Mosque manager → sessionless mosque onboarding (draft stored locally).
///
/// Reachable again from the first onboarding step (back chevron) while an
/// anonymous session already exists; [AuthPresenter] handles both cases.
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
      ref.read(analyticsRepoProvider).trackOnboardingPage(OnboardingStep.profileType);
      switch (selected.value) {
        case _ProfileType.worshipper:
          await auth.startAsWorshipper();
        case _ProfileType.mosqueManager:
          await auth.startAsMosqueManager();
      }
    }

    return UIGradientLinedScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: UIIcon(
                  UIIconsToken.icons.chevronLeft,
                  color: UIColorsToken.yellow,
                  onTap: isLoading ? null : nav.toWelcome,
                ),
              ),
            ),
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
                      image: Assets.images.masjid,
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
                      image: Assets.images.prayMuslim,
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
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final AssetGenImage image;
  final bool selected;
  final VoidCallback onTap;

  /// Rendered size of the 3D icon. Only its top-left is visible: the card
  /// clips the right/bottom overflow (see [_CardArt]).
  static const double _artSize = 150;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: UISelecteableCard(
          selected: selected,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -_artSize * 0.42,
                bottom: -_artSize * 0.36,
                child: _CardArt(image: image, size: _artSize, selected: selected),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 96, top: 8, bottom: 40),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// 3D icon with a soft radial glow behind it. The glow warms up to gold when
/// the card is selected.
class _CardArt extends StatelessWidget {
  const _CardArt({required this.image, required this.size, required this.selected});

  final AssetGenImage image;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final glow = selected ? UIColorsToken.textYellow : UIColorsToken.white;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glow.withValues(alpha: selected ? 0.28 : 0.14),
                  glow.withValues(alpha: 0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          image.image(width: size, height: size, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
