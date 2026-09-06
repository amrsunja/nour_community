import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/datasources/mosque_admin_remote_datasource.dart' show BroadcastQuota;
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_donation_widgets.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../state_management/mosque_admin_mosque_provider.dart';
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
    final snackbar = ref.read(snackbarProvider);
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
      if (campaign == null) return;
      final d = await showDatePicker(
        context: context,
        initialDate: campaign.endsAt.isAfter(DateTime.now()) ? campaign.endsAt.add(const Duration(days: 7)) : DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (d == null) return;
      final c = await presenter.extendCampaign(campaign.id, DateTime(d.year, d.month, d.day, 23, 59));
      if (c != null) snackbar.showSuccess(l10n.mosque_admin_campaign_extended);
    }

    Future<void> close() async {
      if (campaign == null) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: UIColorsToken.bgSurface,
          title: Text(l10n.mosque_admin_campaign_close_title, style: const TextStyle(color: UIColorsToken.white)),
          content: Text(l10n.mosque_admin_campaign_close_message, style: const TextStyle(color: UIColorsToken.textParagraph)),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.common_cancel)),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.common_yes, style: const TextStyle(color: UIColorsToken.red))),
          ],
        ),
      );
      if (ok != true) return;
      final c = await presenter.closeCampaign(campaign.id);
      if (c != null) snackbar.showSuccess(l10n.mosque_admin_campaign_closed);
    }

    Future<void> postUpdate() async {
      if (campaign == null) return;
      final res = await showModalBottomSheet<(String, bool)>(
        context: context,
        isScrollControlled: true,
        backgroundColor: UIColorsToken.bgPrimary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _UpdateSheet(l10n: l10n, quota: ref.read(mosqueAdminMosqueProvider).quota),
      );
      if (res == null) return;
      final ok = await presenter.postCampaignUpdate(campaignId: campaign.id, body: res.$1, notify: res.$2);
      if (ok) {
        snackbar.showSuccess(l10n.mosque_admin_campaign_update_posted);
        await loadSide();
      }
    }

    return UIGradientLinedScaffold(
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
                  Row(
                    children: [
                      Expanded(child: AdminStatTile(label: l10n.mosque_admin_donors, value: '${campaign.donorsCount}')),
                      const SizedBox(width: 8),
                      Expanded(child: AdminStatTile(label: l10n.mosque_campaign_remaining, value: MosqueFormat.money(campaign.remaining))),
                      const SizedBox(width: 8),
                      Expanded(child: AdminStatTile(label: l10n.mosque_admin_campaign_ends, value: MosqueFormat.longDate(campaign.endsAt, lang))),
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

class _UpdateSheet extends HookWidget {
  const _UpdateSheet({required this.l10n, required this.quota});
  final AppLocale l10n;
  final BroadcastQuota? quota;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final body = useTextEditingController();
    final notify = useState(false);
    useListenable(body);
    final exhausted = quota?.exhausted == true;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.mosque_admin_campaign_post_update, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          AdminTextArea(controller: body, hint: l10n.mosque_admin_campaign_update_hint, minLines: 3, maxLines: 6),
          const SizedBox(height: 12),
          AdminToggleRow(
            title: l10n.mosque_admin_campaign_notify_update,
            subtitle: exhausted ? l10n.error_api_mosque_broadcast_quota_exceeded : l10n.mosque_admin_campaign_notify_hint,
            value: notify.value && !exhausted,
            enabled: !exhausted,
            onChanged: (v) => notify.value = v,
          ),
          const SizedBox(height: 16),
          UIButton.primary(
            label: l10n.mosque_admin_tab_post,
            fullWidth: true,
            onTap: body.text.trim().isEmpty ? null : () => Navigator.of(context).pop((body.text.trim(), notify.value && !exhausted)),
          ),
        ],
      ),
    );
  }
}
