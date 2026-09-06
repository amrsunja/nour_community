import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/models/mosque_model.dart';
import '../state_management/mosque_donation_provider.dart';
import 'mosque_donation_widgets.dart';
import 'mosque_format.dart';

/// Donation tab (devis B2/B3) — Sadaqa card + campaigns. Only rendered when
/// the feature flag and `mosque.donations_enabled` are both on.
class MosqueDonationTab extends HookConsumerWidget {
  const MosqueDonationTab({super.key, required this.mosque, required this.l10n});

  final MosqueModel mosque;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueDonationProvider(mosque.id).notifier);
    final state = ref.watch(mosqueDonationProvider(mosque.id));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    if (!state.loaded) {
      return const Padding(padding: EdgeInsets.all(40), child: Center(child: UICircularProgressBar()));
    }
    final settings = state.settings ?? MosqueDonationSettings(mosqueId: mosque.id);
    final sub = state.mySubscription;
    final active = state.activeCampaigns;
    final closed = state.closedCampaigns;

    Future<void> donate() async {
      final ok = await nav.toMosqueCheckout(mosqueId: mosque.id, amount: state.amount, frequency: state.frequency.name);
      if (ok == true) presenter.refresh();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sadaqa card ────────────────────────────────────────────────
          UICard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(settings.title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700))),
                    if (settings.showTaxBadge && mosque.canIssueTaxReceipts) MosqueTaxBadge(l10n: l10n),
                  ],
                ),
                if (settings.description != null && settings.description!.trim().isNotEmpty) ...[
                  const UISpace.vert(6),
                  Text(settings.description!, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                ],
                if (sub != null) ...[
                  const UISpace.vert(14),
                  _ActiveGiftRow(sub: sub, l10n: l10n, busy: state.cancelBusy, onCancel: () async {
                    final confirmed = await _confirmCancel(context, l10n);
                    if (confirmed != true) return;
                    final ok = await presenter.cancelMySubscription();
                    if (ok) snackbar.showSuccess(l10n.mosque_donation_recurring_cancelled);
                  }),
                ],
                if (settings.frequencies.length > 1) ...[
                  const UISpace.vert(14),
                  Row(
                    children: [
                      for (final f in settings.frequencies) ...[
                        MosqueChip(
                          label: switch (f) {
                            DonationFrequency.oneTime => l10n.donate_frequency_one_time,
                            DonationFrequency.monthly => l10n.donate_frequency_monthly,
                            DonationFrequency.yearly => l10n.donate_frequency_yearly,
                          },
                          selected: state.frequency == f,
                          dense: true,
                          onTap: () => presenter.setFrequency(f),
                        ),
                        const UISpace.horz(8),
                      ],
                    ],
                  ),
                ],
                const UISpace.vert(14),
                MosqueAmountPicker(amounts: settings.suggestedAmounts, value: state.amount, onChanged: presenter.setAmount, l10n: l10n),
                const UISpace.vert(16),
                UIButton.primary(
                  label: state.frequency == DonationFrequency.oneTime
                      ? l10n.mosque_donation_give(MosqueFormat.money(state.amount))
                      : state.frequency == DonationFrequency.monthly
                          ? l10n.mosque_donation_give_monthly(MosqueFormat.money(state.amount))
                          : l10n.mosque_donation_give_yearly(MosqueFormat.money(state.amount)),
                  fullWidth: true,
                  onTap: state.amount > 0 ? donate : null,
                ),
                const UISpace.vert(8),
                Center(
                  child: Text(l10n.mosque_donation_secure_note, textAlign: TextAlign.center, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                ),
              ],
            ),
          ),

          // ── Campaigns ──────────────────────────────────────────────────
          if (active.isNotEmpty) ...[
            const UISpace.vert(24),
            MosqueSectionHeader(title: l10n.mosque_campaigns_title),
            const UISpace.vert(12),
            for (final c in active) ...[
              MosqueCampaignCard(campaign: c, l10n: l10n, onTap: () => nav.toMosqueCampaign(mosqueId: mosque.id, campaignId: c.id)),
              const UISpace.vert(12),
            ],
          ],
          if (closed.isNotEmpty) ...[
            const UISpace.vert(12),
            MosqueSectionHeader(title: l10n.mosque_campaigns_past_title),
            const UISpace.vert(12),
            for (final c in closed.take(3)) ...[
              MosqueCampaignCard(campaign: c, l10n: l10n, onTap: () => nav.toMosqueCampaign(mosqueId: mosque.id, campaignId: c.id)),
              const UISpace.vert(12),
            ],
          ],
        ],
      ),
    );
  }

  Future<bool?> _confirmCancel(BuildContext context, AppLocale l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: UIColorsToken.bgSurface,
        title: Text(l10n.mosque_donation_cancel_recurring_title, style: const TextStyle(color: UIColorsToken.white)),
        content: Text(l10n.mosque_donation_cancel_recurring_message, style: const TextStyle(color: UIColorsToken.textParagraph)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.common_cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.common_yes, style: const TextStyle(color: UIColorsToken.red))),
        ],
      ),
    );
  }
}

class _ActiveGiftRow extends StatelessWidget {
  const _ActiveGiftRow({required this.sub, required this.l10n, required this.busy, required this.onCancel});
  final MyMosqueSubscription sub;
  final AppLocale l10n;
  final bool busy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final money = MosqueFormat.money(sub.amount);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: UIColorsToken.green.withValues(alpha: 0.12)),
      child: Row(
        children: [
          const Icon(Icons.autorenew, size: 18, color: UIColorsToken.green),
          const UISpace.horz(10),
          Expanded(
            child: Text(
              sub.frequency == DonationFrequency.monthly ? l10n.mosque_donation_active_monthly(money) : l10n.mosque_donation_active_yearly(money),
              style: typo.inter.bodySmall.copyWith(color: UIColorsToken.white),
            ),
          ),
          if (busy)
            const UICircularProgressBar(size: 16)
          else
            UITap(onTap: onCancel, child: Text(l10n.common_cancel, style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph, decoration: TextDecoration.underline))),
        ],
      ),
    );
  }
}
