import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/models/mosque_model.dart';
import '../state_management/mosque_donation_provider.dart';
import 'mosque_campaign_public_card.dart';
import 'mosque_donation_widgets.dart';
import 'mosque_sadaqa_card.dart';
import 'mosque_format.dart';

/// Donation tab (devis B2/B3) — Sadaqa card + campaigns. Only rendered when
/// the feature flag and `mosque.donations_enabled` are both on.
class MosqueDonationTab extends HookConsumerWidget {
  const MosqueDonationTab({super.key, required this.mosque, required this.l10n});

  final MosqueModel mosque;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    void shareCampaign(MosqueCampaignModel c) =>
        Share.share('${c.title} — ${mosque.name}\n$website/mosque/${mosque.id}/campaign/${c.id}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sadaqa card ────────────────────────────────────────────────
          MosqueSadaqaCard(
            l10n: l10n,
            settings: settings,
            canIssueTaxReceipts: mosque.canIssueTaxReceipts,
            frequency: state.frequency,
            amount: state.amount,
            onFrequencyChanged: presenter.setFrequency,
            onAmountChanged: presenter.setAmount,
            onDonate: donate,
            banner: null
            /*
            sub == null
                ? null
                : _ActiveGiftRow(
                    sub: sub,
                    l10n: l10n,
                    busy: state.cancelBusy,
                    onCancel: () async {
                      final confirmed = await _confirmCancel(context, l10n);
                      if (confirmed != true) return;
                      final ok = await presenter.cancelMySubscription();
                      if (ok) snackbar.showSuccess(l10n.mosque_donation_recurring_cancelled);
                    },
                  ),
                  */
          ),

          // ── Campaigns ──────────────────────────────────────────────────
          if (active.isNotEmpty) ...[
            const UISpace.vert(24),
            MosqueSectionHeader(title: l10n.mosque_campaigns_title),
            const UISpace.vert(12),
            for (final c in active) ...[
              MosqueCampaignPublicCard(
                campaign: c,
                l10n: l10n,
                onTap: () => nav.toMosqueCampaign(mosqueId: mosque.id, campaignId: c.id),
                onShare: () => shareCampaign(c),
                onContribute: () => nav.toMosqueCampaign(mosqueId: mosque.id, campaignId: c.id),
              ),
              const UISpace.vert(12),
            ],
          ],
          if (closed.isNotEmpty) ...[
            const UISpace.vert(12),
            MosqueSectionHeader(title: l10n.mosque_campaigns_past_title),
            const UISpace.vert(12),
            for (final c in closed.take(3)) ...[
              MosqueCampaignPublicCard(
                campaign: c,
                l10n: l10n,
                onTap: () => nav.toMosqueCampaign(mosqueId: mosque.id, campaignId: c.id),
                onShare: () => shareCampaign(c),
                onContribute: () => nav.toMosqueCampaign(mosqueId: mosque.id, campaignId: c.id),
              ),
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
        content: Text(l10n.mosque_donation_cancel_recurring_message, style: TextStyle(color: UIColorsToken.textParagraph)),
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
