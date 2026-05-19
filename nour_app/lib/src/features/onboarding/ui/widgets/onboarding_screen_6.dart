import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/notifications/notifications_services.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/notifications/ui/state_management/notifications_provider.dart';
import 'package:nour/src/features/notifications/ui/widgets/notifications_settings_widget.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen6 extends ConsumerWidget {
  const OnboardingScreen6({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final onboarding = ref.read(onboardingProvider.notifier);
    final notificationsServices = ref.read(notificationsServicesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 80),
                    duration: const Duration(milliseconds: 900),
                    beginScale: 0.9,
                    offsetY: 24,
                    child: UIGlowingBlock(
                      child: Assets.images.illustration6.image(
                        width: 140,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      l10n.onboarding_screen_6_title,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.display.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 320),
                    child: Text(
                      l10n.onboarding_screen_6_description,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.bodyLarge.copyWith(
                        color: UIColorsToken.textParagraph,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const NotificationsSettingsWidget(animateEntry: true),
                ],
              ),
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 900),
            offsetY: 16,
            child: Row(
              children: [
                Expanded(
                  child: UIButton.textual(
                    label: 'Maybe later',
                    fullWidth: true,
                    contentColor: UIColorsToken.white,
                    onTap: () => onboarding.changePage(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: UIButton.primary(
                    label: 'Allow notifications',
                    fullWidth: true,
                    onTap: () async {
                      // Init notifications
                      final isGranted = await notificationsServices.requestPermissions();

                      if (isGranted) {
                        await notificationsServices.initialize();
                      }

                      onboarding.changePage(6);
                    },
                  ),
                ),
              ],
            ),
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}
