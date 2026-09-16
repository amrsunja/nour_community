import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_donation_widgets.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../widgets/admin_campaign_actions.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// Admin view of one campaign (devis B3): progress, recent donors, updates,
/// extend / close / edit, post an update (+ optional push).
@RoutePage()
class MosqueAdminCampaignPage extends HookConsumerWidget {
  const MosqueAdminCampaignPage({super.key, @PathParam('campaignId') required this.campaignId});

  final int campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final nav = ref.read(navigationServicesProvider);
    final repo = ref.read(mosqueRepoProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final campaign = state.campaigns.where((c) => c.id == campaignId).firstOrNull;
    final updates = useState<List<MosqueCampaignUpdate>>(const []);
    final donors = useState<List<MosqueDonorRow>>(const []);

    Future<void> loadSide() async {
      final u = await repo.getCampaignUpdates(campaignId);
      u.when((v) => updates.value = v, (_) {});
      final mosqueId = campaign?.mosqueId;
      if (mosqueId != null) {
        final d = await repo.getDonors(mosqueId, type: 'mosque_campaign', limit: 50);
        d.when((v) => donors.value = v.where((r) => r.campaignTitle == campaign?.title).take(10).toList(), (_) {});
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.init().then((_) => loadSide());
      });
      return null;
    }, const []);

    Future<void> extend() async {
      if (campaign != null) await extendCampaignFlow(context, ref, campaign);
    }

    Future<void> close() async {
      if (campaign != null) await closeCampaignFlow(context, ref, campaign);
    }

    Future<void> postUpdate() async {
      if (campaign == null) return;
      if (await postCampaignUpdateFlow(context, ref, campaign)) await loadSide();
    }

    return Scaffold(
      appBar: UIAppBar(
        title: l10n.mosque_campaign_title,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          if (campaign != null && campaign.status == MosqueCampaignStatus.active)
            UIButton.textual(label: l10n.common_edit, isSmall: true, onTap: () => nav.toMosqueAdminCampaignForm(campaignId: campaign.id)),
        ],
      ),
      body: campaign == null
          ? const Center(child: UICircularProgressBar())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MosqueCampaignCard(campaign: campaign, l10n: l10n),
                  const SizedBox(height: 12),
                  Column(
                    spacing: 8,
                    children: [
                      AdminStatTile(label: l10n.mosque_admin_donors, value: '${campaign.donorsCount}'),
                      AdminStatTile(label: l10n.mosque_campaign_remaining, value: MosqueFormat.money(campaign.remaining)),
                      AdminStatTile(label: l10n.mosque_admin_campaign_ends, value: MosqueFormat.longDate(campaign.endsAt, lang)),
                      AdminStatTile(
                        label: l10n.mosque_admin_sadaqa_amounts,
                        value: campaign.amountsOrDefault.map((a) => '${a}€').join(' · '),
                      ),
                      AdminStatTile(
                        label: l10n.mosque_admin_fundraising_frequencies,
                        value: campaign.frequencies
                            .map((f) => switch (f) {
                                  DonationFrequency.oneTime => l10n.donate_frequency_one_time,
                                  DonationFrequency.monthly => l10n.donate_frequency_monthly,
                                  DonationFrequency.yearly => l10n.donate_frequency_yearly,
                                })
                            .join(' · '),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (campaign.status == MosqueCampaignStatus.active) ...[
                    UIButton.primary(label: l10n.mosque_admin_campaign_post_update, fullWidth: true, isBusy: state.busy, onTap: postUpdate),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: UIButton.secondary(label: l10n.mosque_admin_campaign_extend, fullWidth: true, onTap: extend)),
                        const SizedBox(width: 8),
                        Expanded(child: UIButton.secondary(label: l10n.mosque_admin_campaign_close, fullWidth: true, onTap: close)),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        l10n.mosque_admin_campaign_closed_note(campaign.closedAt == null ? '' : MosqueFormat.longDate(campaign.closedAt!, lang)),
                        style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ),
                    if (state.canCreateCampaign) ...[
                      const SizedBox(height: 8),
                      UIButton.secondary(label: l10n.mosque_admin_campaign_reopen, fullWidth: true, onTap: extend),
                    ],
                  ],

                  // Updates
                  const SizedBox(height: 24),
                  MosqueSectionHeader(title: l10n.mosque_campaign_updates),
                  const SizedBox(height: 10),
                  if (updates.value.isEmpty)
                    Text(l10n.mosque_campaign_updates_empty, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                  for (final u in updates.value) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.body, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white)),
                          const SizedBox(height: 4),
                          Text(MosqueFormat.timeAgo(u.createdAt, l10n), style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Recent donors
                  const SizedBox(height: 16),
                  MosqueSectionHeader(title: l10n.mosque_campaign_recent_donors, actionLabel: l10n.dashboard_see_all, onAction: nav.toMosqueAdminDonors),
                  const SizedBox(height: 10),
                  if (donors.value.isEmpty)
                    Text(l10n.mosque_admin_donors_empty, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                  for (final d in donors.value) ...[
                    Row(
                      children: [
                        UIAvatar(url: d.avatarUrl, initial: ((d.name ?? '').isEmpty ? 'A' : d.name!.substring(0, 1).toUpperCase()), color: UIColorsToken.bgSurface, size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: Text(d.isAnonymous ? l10n.mosque_donor_anonymous : (d.name ?? ''), style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white))),
                        Text(MosqueFormat.money(d.amount), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
    );
  }
}
