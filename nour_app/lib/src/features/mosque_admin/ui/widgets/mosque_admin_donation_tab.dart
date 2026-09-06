import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/models/mosque_model.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_donation_widgets.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import 'mosque_admin_form_widgets.dart';

/// Admin Donation tab (devis B1/B5): Stripe setup CTA, analytics, Sadaqa
/// settings shortcut, campaigns, donors & receipts.
class MosqueAdminDonationTab extends HookConsumerWidget {
  const MosqueAdminDonationTab({super.key, required this.mosque});

  final MosqueModel mosque;

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

    if (!state.loaded) {
      return const Padding(padding: EdgeInsets.all(40), child: Center(child: UICircularProgressBar()));
    }

    final stats = state.stats;
    final growth = stats?.growthPercent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Stripe status ──────────────────────────────────────────────
          if (!state.donationsReady)
            _SetupCard(state: state, l10n: l10n, onTap: nav.toMosqueAdminStripe)
          else
            UITap(
              onTap: nav.toMosqueAdminStripe,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: UIColorsToken.green.withValues(alpha: 0.12)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: UIColorsToken.green),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.mosque_admin_stripe_active, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white))),
                    const Icon(Icons.chevron_right, size: 18, color: UIColorsToken.textParagraph),
                  ],
                ),
              ),
            ),

          // ── Analytics ──────────────────────────────────────────────────
          if (stats != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text(l10n.mosque_admin_total_raised_year, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph))),
                _YearPicker(year: state.year, onChanged: presenter.setYear),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(MosqueFormat.money(stats.totalYear), style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                if (growth != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%',
                      style: theme.typo.inter.bodyMedium.copyWith(color: growth >= 0 ? UIColorsToken.green : UIColorsToken.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminStatTile(label: l10n.mosque_admin_donors, value: '${stats.donors}')),
                const SizedBox(width: 8),
                Expanded(child: AdminStatTile(label: l10n.mosque_admin_recurring, value: '${stats.recurringActive}')),
                const SizedBox(width: 8),
                Expanded(child: AdminStatTile(label: l10n.mosque_admin_avg_gift, value: MosqueFormat.money(stats.avgGift))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: AdminStatTile(label: l10n.mosque_admin_stat_support, value: MosqueFormat.money(stats.supportAmount), hint: l10n.mosque_admin_stat_support_hint)),
                const SizedBox(width: 8),
                Expanded(child: AdminStatTile(label: l10n.mosque_admin_stat_campaigns, value: MosqueFormat.money(stats.campaignsAmount))),
              ],
            ),
          ],

          // ── Sadaqa card ────────────────────────────────────────────────
          const SizedBox(height: 24),
          MosqueSectionHeader(title: l10n.mosque_admin_sadaqa_title, actionLabel: l10n.mosque_admin_manage, onAction: nav.toMosqueAdminSadaqaSettings),
          const SizedBox(height: 10),
          _SadaqaPreview(settings: state.settings ?? MosqueDonationSettings(mosqueId: mosque.id), mosque: mosque, stats: stats, l10n: l10n),

          // ── Campaigns ──────────────────────────────────────────────────
          const SizedBox(height: 24),
          MosqueSectionHeader(
            title: l10n.mosque_campaigns_title,
            actionLabel: state.donationsReady && state.canCreateCampaign ? l10n.mosque_admin_campaign_new : null,
            onAction: () => nav.toMosqueAdminCampaignForm(),
          ),
          const SizedBox(height: 10),
          if (state.campaigns.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
              child: Text(l10n.mosque_admin_campaigns_empty, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
            ),
          for (final c in state.activeCampaigns) ...[
            MosqueCampaignCard(campaign: c, l10n: l10n, onTap: () => nav.toMosqueAdminCampaign(c.id)),
            const SizedBox(height: 10),
          ],
          if (state.pastCampaigns.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(l10n.mosque_campaigns_past_title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 8),
            for (final c in state.pastCampaigns.take(5)) ...[
              MosqueCampaignCard(campaign: c, l10n: l10n, onTap: () => nav.toMosqueAdminCampaign(c.id)),
              const SizedBox(height: 10),
            ],
          ],

          // ── Donors / receipts ──────────────────────────────────────────
          const SizedBox(height: 14),
          _LinkRow(icon: Icons.people_outline, label: l10n.mosque_admin_donors_list, onTap: nav.toMosqueAdminDonors),
          const SizedBox(height: 8),
          _LinkRow(icon: Icons.receipt_long_outlined, label: l10n.mosque_admin_receipts, onTap: nav.toMosqueAdminReceipts),
        ],
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.state, required this.l10n, required this.onTap});
  final MosqueAdminDonationState state;
  final AppLocale l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final pending = state.stripe.hasAccount;
    return UICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(pending ? Icons.hourglass_bottom : Icons.account_balance_outlined, color: UIColorsToken.textYellow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(pending ? l10n.mosque_admin_stripe_pending_title : l10n.mosque_admin_stripe_setup_title,
                    style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(pending ? l10n.mosque_admin_stripe_pending_message : l10n.mosque_admin_stripe_setup_message,
              style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 14),
          UIButton.primary(label: pending ? l10n.mosque_admin_stripe_continue : l10n.mosque_admin_stripe_start, fullWidth: true, onTap: onTap),
        ],
      ),
    );
  }
}

class _SadaqaPreview extends StatelessWidget {
  const _SadaqaPreview({required this.settings, required this.mosque, required this.stats, required this.l10n});
  final MosqueDonationSettings settings;
  final MosqueModel mosque;
  final MosqueDonationStats? stats;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UICard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(settings.title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600))),
              if (settings.showTaxBadge && mosque.canIssueTaxReceipts) MosqueTaxBadge(l10n: l10n),
            ],
          ),
          if (settings.description != null && settings.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(settings.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final a in settings.suggestedAmounts) MosqueChip(label: '$a€', selected: false, dense: true)]),
          if (stats != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.mosque_admin_sadaqa_month_summary(stats!.monthGifts, MosqueFormat.money(stats!.monthAmount), stats!.monthlyDonors),
              style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
        ],
      ),
    );
  }
}

class _YearPicker extends StatelessWidget {
  const _YearPicker({required this.year, required this.onChanged});
  final int year;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final now = DateTime.now().year;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UITap(onTap: () => onChanged(year - 1), child: const Icon(Icons.chevron_left, size: 20, color: UIColorsToken.textParagraph)),
        Text('$year', style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
        UITap(onTap: year < now ? () => onChanged(year + 1) : null, child: Icon(Icons.chevron_right, size: 20, color: year < now ? UIColorsToken.textParagraph : UIColorsToken.black80)),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: UIColorsToken.textYellow),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white))),
            const Icon(Icons.chevron_right, size: 18, color: UIColorsToken.textParagraph),
          ],
        ),
      ),
    );
  }
}
