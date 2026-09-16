import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../widgets/admin_campaign_actions.dart';
import '../widgets/admin_campaign_row.dart';

/// All campaigns of the mosque — active first, then the closed / past ones.
/// Reached from the "Also here" section of the admin Donation tab.
@RoutePage()
class MosqueAdminCampaignsPage extends HookConsumerWidget {
  const MosqueAdminCampaignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    final active = state.activeCampaigns;
    final past = state.pastCampaigns;

    return Scaffold(
      appBar: UIAppBar(
        title: l10n.mosque_campaigns_title,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          UIButton.textual(label: l10n.mosque_admin_fundraising_settings_title, isSmall: true, onTap: nav.toMosqueAdminFundraisingSettings),
        ],
      ),
      body: state.isLoading && !state.loaded
          ? const Center(child: UICircularProgressBar())
          : RefreshIndicator(
              onRefresh: presenter.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.mosque_admin_campaigns_active_title,
                        style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      AdminCountBadge(count: active.length),
                      const Spacer(),
                      if (state.donationsReady && state.canCreateCampaign)
                        UIButton.primary(
                          label: l10n.mosque_admin_campaign_new_short,
                          assetIcon: UIIconsToken.icons.plus,
                          iconAxis: UIButtonIconAxis.leading,
                          isSmall: true,
                          onTap: () => nav.toMosqueAdminCampaignForm(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (active.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        l10n.mosque_admin_campaigns_empty,
                        style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ),
                  for (final c in active) ...[
                    AdminCampaignManageCard(campaign: c, onOpen: () => nav.toMosqueAdminCampaign(c.id)),
                    const SizedBox(height: 10),
                  ],
                  if (past.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      l10n.mosque_campaigns_past_title,
                      style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    for (final c in past) ...[
                      AdminCampaignRow(campaign: c, l10n: l10n, onTap: () => nav.toMosqueAdminCampaign(c.id)),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}
