import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/notifications/push_notifications_services.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../state_management/push_provider.dart';

/// Push notification preferences (devis Poste 1 — screen 1). One toggle per
/// push kind; the server skips recipients whose `push_prefs[kind] == false`.
@RoutePage()
class PushSettingsPage extends ConsumerWidget {
  const PushSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final profile = ref.watch(profileProvider).profile;
    final presenter = ref.read(pushProvider.notifier);
    final services = ref.read(pushNotificationsServicesProvider);

    final isMosque = profile?.isMosqueAccount ?? false;
    final kinds = <(String, String, String)>[
      if (!isMosque) ('mosque_post', l10n.push_kind_mosque_post, l10n.push_kind_mosque_post_hint),
      if (!isMosque) ('mosque_event', l10n.push_kind_mosque_event, l10n.push_kind_mosque_event_hint),
      if (!isMosque) ('mosque_campaign', l10n.push_kind_mosque_campaign, l10n.push_kind_mosque_campaign_hint),
      if (!isMosque) ('mosque_broadcast', l10n.push_kind_mosque_broadcast, l10n.push_kind_mosque_broadcast_hint),
      if (isMosque) ('mosque_status', l10n.push_kind_mosque_status, l10n.push_kind_mosque_status_hint),
      ('system', l10n.push_kind_system, l10n.push_kind_system_hint),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(title: l10n.push_settings_title, onBack: () => context.router.maybePop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 12, kPageHorzPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.push_settings_description,
                    style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < kinds.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                      child: UIAppearAnimation(
                        delay: Duration(milliseconds: 100 + i * 80),
                        offsetY: 14,
                        child: UICard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(kinds[i].$2,
                                        style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                                    const SizedBox(height: 2),
                                    Text(kinds[i].$3,
                                        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                                  ],
                                ),
                              ),
                              UIToggle(
                                checked: profile?.pushEnabled(kinds[i].$1) ?? true,
                                onBeforeChange: (enable) async {
                                  if (!enable) return true;
                                  return services.requestPermission();
                                },
                                onCheck: (v) => presenter.setPref(kinds[i].$1, v),
                              ),
                            ],
                          ),
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
