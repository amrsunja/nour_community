import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/notifications/notifications_services.dart';
import 'package:nour/src/features/notifications/ui/widgets/notifications_settings_widget.dart';

import '../state_management/mosque_onboarding_provider.dart';
import 'mosque_onboarding_scaffold.dart';

/// "Gentle reminders" (Figma Onboarding 19) — same toggles as the worshipper
/// onboarding; the local reminder settings are device-level so they apply to
/// mosque accounts too.
class MosqueOnboardingRemindersScreen extends ConsumerWidget {
  const MosqueOnboardingRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);
    final notificationsServices = ref.read(notificationsServicesProvider);

    return MosqueOnboardingStepScaffold(
      centered: true,
      children: [
        UIAppearAnimation(
          delay: const Duration(milliseconds: 80),
          duration: const Duration(milliseconds: 900),
          beginScale: 0.9,
          child: Center(
            child: UIGlowingBlock(
              child: Assets.images.illustration6.image(width: 140, filterQuality: FilterQuality.high),
            ),
          ),
        ),
        const SizedBox(height: 24),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 200),
          child: Text(
            l10n.onboarding_screen_6_title,
            textAlign: TextAlign.center,
            style: theme.typo.inter.display.copyWith(color: UIColorsToken.white),
          ),
        ),
        const SizedBox(height: 8),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 320),
          child: Text(
            l10n.onboarding_screen_6_description,
            textAlign: TextAlign.center,
            style: theme.typo.inter.bodyLarge.copyWith(color: UIColorsToken.textParagraph),
          ),
        ),
        const SizedBox(height: 28),
        const NotificationsSettingsWidget(animateEntry: true),
      ],
      bottom: Row(
        children: [
          Expanded(
            child: UIButton.textual(
              label: l10n.onboarding_maybe_later,
              fullWidth: true,
              contentColor: UIColorsToken.white,
              onTap: presenter.next,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: UIButton.primary(
              label: l10n.onboarding_allow_notifications,
              fullWidth: true,
              onTap: () async {
                final isGranted = await notificationsServices.requestPermissions();
                if (isGranted) await notificationsServices.initialize();
                await presenter.next();
              },
            ),
          ),
        ],
      ),
    );
  }
}
