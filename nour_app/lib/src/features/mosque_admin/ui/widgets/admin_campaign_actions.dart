import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/features/mosques/data/datasources/mosque_admin_remote_datasource.dart' show BroadcastQuota;
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../state_management/mosque_admin_mosque_provider.dart';
import 'mosque_admin_form_widgets.dart';

/// The four things an admin does to a running campaign — extend, edit, post an
/// update, close. Shared by the Fundraising settings page and the campaign
/// page so the same confirmation / picker / sheet is used everywhere.

/// Pushes the end date further (also the "reopen" path of a closed campaign).
Future<bool> extendCampaignFlow(BuildContext context, WidgetRef ref, MosqueCampaignModel c) async {
  final l10n = ref.read(l10nProvider);
  final snackbar = ref.read(snackbarProvider);
  final presenter = ref.read(mosqueAdminDonationProvider.notifier);
  final now = DateTime.now();
  final d = await UIPickers.date(
    context,
    initialDate: c.endsAt.isAfter(now) ? c.endsAt.add(const Duration(days: 7)) : now.add(const Duration(days: 7)),
    firstDate: now.add(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 365)),
  );
  if (d == null) return false;
  final updated = await presenter.extendCampaign(c.id, DateTime(d.year, d.month, d.day, 23, 59));
  if (updated != null) snackbar.showSuccess(l10n.mosque_admin_campaign_extended);
  return updated != null;
}

/// Closes a campaign early. Donations stop immediately — hence the confirm.
Future<bool> closeCampaignFlow(BuildContext context, WidgetRef ref, MosqueCampaignModel c) async {
  final l10n = ref.read(l10nProvider);
  final snackbar = ref.read(snackbarProvider);
  final presenter = ref.read(mosqueAdminDonationProvider.notifier);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: UIColorsToken.bgSurface,
      title: Text(l10n.mosque_admin_campaign_close_title, style: const TextStyle(color: UIColorsToken.white)),
      content: Text(l10n.mosque_admin_campaign_close_message, style: TextStyle(color: UIColorsToken.textParagraph)),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.common_cancel)),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.common_yes, style: const TextStyle(color: UIColorsToken.red))),
      ],
    ),
  );
  if (ok != true) return false;
  final updated = await presenter.closeCampaign(c.id);
  if (updated != null) snackbar.showSuccess(l10n.mosque_admin_campaign_closed);
  return updated != null;
}

/// Posts a progress update (+ optional push, which costs one broadcast).
Future<bool> postCampaignUpdateFlow(BuildContext context, WidgetRef ref, MosqueCampaignModel c) async {
  final l10n = ref.read(l10nProvider);
  final snackbar = ref.read(snackbarProvider);
  final presenter = ref.read(mosqueAdminDonationProvider.notifier);
  final res = await UIBottomSheet.show<(String, bool)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: UIColorsToken.bgPrimary,
    builder: (_) => AdminCampaignUpdateSheet(l10n: l10n, quota: ref.read(mosqueAdminMosqueProvider).quota),
  );
  if (res == null) return false;
  final ok = await presenter.postCampaignUpdate(campaignId: c.id, body: res.$1, notify: res.$2);
  if (ok) snackbar.showSuccess(l10n.mosque_admin_campaign_update_posted);
  return ok;
}

/// Body + "notify followers" sheet of [postCampaignUpdateFlow].
class AdminCampaignUpdateSheet extends HookWidget {
  const AdminCampaignUpdateSheet({super.key, required this.l10n, required this.quota});

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

/// Campaign card of the Fundraising settings page: the progress block of
/// [AdminCampaignRow] plus the four inline actions, so a manager can run a
/// campaign without opening it.
class AdminCampaignManageCard extends ConsumerWidget {
  const AdminCampaignManageCard({super.key, required this.campaign, this.onOpen});

  final MosqueCampaignModel campaign;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final c = campaign;
    final endingSoon = c.isEndingSoon;
    final timeLabel = !c.isOpen
        ? l10n.mosque_campaign_closed
        : c.daysLeft == 0
            ? l10n.mosque_campaign_days_left(0)
            : l10n.mosque_admin_campaign_days_left_short(c.daysLeft);

    return UICard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.mosque_campaign_donors_count(c.donorsCount),
                      style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${c.percent}%', style: typo.inter.title.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: typo.inter.bodySmall.copyWith(color: endingSoon ? UIColorsToken.red : UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MosqueFormat.money(c.collectedAmount),
                style: typo.inter.titleMedium.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.mosque_campaign_of_goal(MosqueFormat.money(c.goalAmount)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          UIProgressLine(current: c.collectedAmount, total: c.goalAmount <= 0 ? 1 : c.goalAmount, height: 6),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AdminCampaignActionTile(
                  icon: Icons.schedule,
                  label: l10n.mosque_admin_campaign_extend,
                  onTap: () => extendCampaignFlow(context, ref, c),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminCampaignActionTile(
                  icon: Icons.edit_outlined,
                  label: l10n.common_edit,
                  onTap: c.status == MosqueCampaignStatus.active ? () => nav.toMosqueAdminCampaignForm(campaignId: c.id) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AdminCampaignActionTile(
                  icon: Icons.chat_bubble_outline,
                  label: l10n.mosque_admin_campaign_post_update,
                  onTap: c.status == MosqueCampaignStatus.active ? () => postCampaignUpdateFlow(context, ref, c) : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminCampaignActionTile(
                  icon: Icons.close,
                  // A campaign that still has time left is "closed early".
                  label: endingSoon ? l10n.mosque_admin_campaign_close : l10n.mosque_admin_campaign_close_early,
                  danger: true,
                  onTap: c.status == MosqueCampaignStatus.active ? () => closeCampaignFlow(context, ref, c) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One square action of [AdminCampaignManageCard].
class AdminCampaignActionTile extends StatelessWidget {
  const AdminCampaignActionTile({super.key, required this.icon, required this.label, this.onTap, this.danger = false});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final enabled = onTap != null;
    final color = danger ? UIColorsToken.red : UIColorsToken.white;
    return UITap(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: danger ? UIColorsToken.red.withValues(alpha: 0.10) : UIColorsToken.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: (danger ? UIColorsToken.red : UIColorsToken.white).withValues(alpha: danger ? 0.24 : 0.10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.bodyMedium.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
