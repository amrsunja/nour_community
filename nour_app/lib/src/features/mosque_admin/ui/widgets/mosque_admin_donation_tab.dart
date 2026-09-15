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
                    Icon(Icons.chevron_right, size: 18, color: UIColorsToken.textParagraph),
                  ],
                ),
              ),
            ),

          // ── Analytics ──────────────────────────────────────────────────
          if (stats != null) ...[
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: _YearPicker(year: state.year, onChanged: presenter.setYear)),
            const SizedBox(height: 8),
            UIMosqueDonationInformationCard(
              total: MosqueFormat.money(stats.totalYear),
              totalLabel: l10n.mosque_admin_total_raised_year,
              growthLabel: growth == null
                  ? null
                  : l10n.mosque_donation_card_growth('${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%', '${state.year - 1}'),
              growthIsPositive: (growth ?? 0) >= 0,
              supportAmount: MosqueFormat.money(stats.supportAmount),
              supportLabel: l10n.mosque_donation_card_support,
              campaignsAmount: MosqueFormat.money(stats.campaignsAmount),
              campaignsLabel: l10n.mosque_admin_stat_campaigns,
              supportRatio: _supportRatio(stats),
              stats: [
                UIMosqueDonationStat(value: MosqueFormat.compact(stats.donors), label: l10n.mosque_admin_donors),
                UIMosqueDonationStat(value: MosqueFormat.compact(stats.recurringActive), label: l10n.mosque_admin_recurring),
                UIMosqueDonationStat(value: MosqueFormat.money(stats.avgGift), label: l10n.mosque_admin_avg_gift),
              ],
            ),
          ],

          // ── Sadaqa card ────────────────────────────────────────────────
          const SizedBox(height: 24),
          MosqueSectionHeader(title: l10n.mosque_admin_sadaqa_section_title),
          const SizedBox(height: 10),
          _SadaqaPreview(
            settings: state.settings ?? MosqueDonationSettings(mosqueId: mosque.id),
            mosque: mosque,
            stats: stats,
            l10n: l10n,
            active: state.donationsReady,
            onManage: nav.toMosqueAdminSadaqaSettings,
          ),

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

/// Support share of the year total, `0..1` (defaults to a 50/50 bar when
/// nothing has been raised yet).
double _supportRatio(MosqueDonationStats stats) {
  final total = stats.supportAmount + stats.campaignsAmount;
  return total <= 0 ? 0.5 : (stats.supportAmount / total).clamp(0.0, 1.0);
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
  const _SadaqaPreview({
    required this.settings,
    required this.mosque,
    required this.stats,
    required this.l10n,
    required this.active,
    required this.onManage,
  });

  final MosqueDonationSettings settings;
  final MosqueModel mosque;
  final MosqueDonationStats? stats;
  final AppLocale l10n;
  final bool active;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final description = settings.description;
    return UICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  settings.title,
                  style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
                ),
              ),
              if (settings.showTaxBadge && mosque.canIssueTaxReceipts) ...[
                MosqueTaxBadge(l10n: l10n),
                const SizedBox(width: 6),
              ],
              if (active) _ActiveBadge(label: l10n.mosque_campaign_active),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
          if (stats != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SadaqaStatTile(
                    label: l10n.mosque_admin_sadaqa_this_month,
                    value: MosqueFormat.money(stats!.monthAmount),
                    hint: l10n.mosque_admin_sadaqa_gifts(stats!.monthGifts),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SadaqaStatTile(
                    label: l10n.mosque_admin_recurring,
                    value: '${stats!.recurringActive}',
                    hint: l10n.mosque_admin_sadaqa_monthly_donors,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          UIButton.secondary(
            label: l10n.mosque_admin_sadaqa_manage_settings,
            assetIcon: UIIconsToken.icons.tools,
            fullWidth: true,
            onTap: onManage,
          ),
        ],
      ),
    );
  }
}

/// Green "Active" pill of the Sadaqa card header.
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: UIColorsToken.pastelGreen.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.greenAccent, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// `label / value / hint` tile used inside the Sadaqa card.
class _SadaqaStatTile extends StatelessWidget {
  const _SadaqaStatTile({required this.label, required this.value, required this.hint});
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIColorsToken.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UIColorsToken.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typo.inter.titleMedium.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(hint, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
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
        UITap(onTap: () => onChanged(year - 1), child: Icon(Icons.chevron_left, size: 20, color: UIColorsToken.textParagraph)),
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
            Icon(Icons.chevron_right, size: 18, color: UIColorsToken.textParagraph),
          ],
        ),
      ),
    );
  }
}
