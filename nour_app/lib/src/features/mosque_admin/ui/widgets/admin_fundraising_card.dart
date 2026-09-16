import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/enums/currency_type.dart';
import 'package:nour/src/features/mosques/data/models/mosque_dashboard_stats_model.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

/// Dashboard "Fundraising" card: total raised over a selectable period, the
/// donor count for that same period, then one progress line per running
/// campaign (Figma "Dashboard - Nour mosques").
class AdminFundraisingCard extends StatelessWidget {
  const AdminFundraisingCard({
    super.key,
    required this.stats,
    required this.period,
    required this.onPeriodChanged,
    required this.l10n,
    this.isLoading = false,
    this.onCampaignTap,
  });

  final MosqueDashboardStats stats;
  final MosqueFundraisingPeriod period;
  final ValueChanged<MosqueFundraisingPeriod> onPeriodChanged;
  final AppLocale l10n;
  final bool isLoading;
  final ValueChanged<MosqueCampaignSummary>? onCampaignTap;

  String _periodLabel(MosqueFundraisingPeriod p) => switch (p) {
        MosqueFundraisingPeriod.year => l10n.mosque_admin_period_this_year,
        MosqueFundraisingPeriod.days30 => l10n.mosque_admin_period_30d,
        MosqueFundraisingPeriod.all => l10n.mosque_admin_period_all_time,
      };

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyType.fromString(stats.fundraisingCurrency).symbol;

    // ClipRRect sits *inside* the card so the card keeps its drop shadow while
    // the glow is clipped to the rounded corners.
    return UICard(
      padding: EdgeInsets.zero,
      disableBorder: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // Warm halo bleeding in from the top of the card.
            const Positioned(
              top: -140,
              left: 0,
              right: 0,
              child: UITopGlow(diameter: 150, blur: 70),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    total: stats.fundraisingTotal,
                    donors: stats.fundraisingDonors,
                    symbol: symbol,
                    isLoading: isLoading,
                    label: _periodLabel(period),
                    period: period,
                    periodLabel: _periodLabel,
                    onPeriodChanged: onPeriodChanged,
                    l10n: l10n,
                  ),
                  if (stats.campaigns.isNotEmpty) ...[
                    const UISpace.vert(18),
                    for (var i = 0; i < stats.campaigns.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i == stats.campaigns.length - 1 ? 0 : 16),
                        child: _CampaignRow(
                          campaign: stats.campaigns[i],
                          l10n: l10n,
                          onTap: onCampaignTap == null ? null : () => onCampaignTap!(stats.campaigns[i]),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.donors,
    required this.symbol,
    required this.isLoading,
    required this.label,
    required this.period,
    required this.periodLabel,
    required this.onPeriodChanged,
    required this.l10n,
  });

  final double total;
  final int donors;
  final String symbol;
  final bool isLoading;
  final String label;
  final MosqueFundraisingPeriod period;
  final String Function(MosqueFundraisingPeriod) periodLabel;
  final ValueChanged<MosqueFundraisingPeriod> onPeriodChanged;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isLoading ? 0.4 : 1,
                child: Text(
                  MosqueFormat.money(total, symbol: symbol, prefix: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.mosque_admin_fundraising_total_raised,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ),
                  const UISpace.horz(8),
                  _PeriodPicker(
                    value: period,
                    label: label,
                    labelFor: periodLabel,
                    onChanged: onPeriodChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
        const UISpace.horz(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isLoading ? 0.4 : 1,
              child: Text(
                MosqueFormat.compact(donors),
                style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              l10n.mosque_admin_donors,
              style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
        ),
      ],
    );
  }
}

/// "This year ▾" pill.
class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({
    required this.value,
    required this.label,
    required this.labelFor,
    required this.onChanged,
  });

  final MosqueFundraisingPeriod value;
  final String label;
  final String Function(MosqueFundraisingPeriod) labelFor;
  final ValueChanged<MosqueFundraisingPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return PopupMenuButton<MosqueFundraisingPeriod>(
      onSelected: onChanged,
      initialValue: value,
      color: UIColorsToken.bgSurface,
      padding: EdgeInsets.zero,
      itemBuilder: (_) => [
        for (final p in MosqueFundraisingPeriod.values)
          PopupMenuItem(
            value: p,
            child: Text(
              labelFor(p),
              style: theme.typo.inter.body.copyWith(
                color: p == value ? UIColorsToken.textYellow : UIColorsToken.white,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: UIColorsToken.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white),
              ),
            ),
            const UISpace.horz(2),
            Icon(Icons.expand_more, size: 16, color: UIColorsToken.textParagraph),
          ],
        ),
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({required this.campaign, required this.l10n, this.onTap});

  final MosqueCampaignSummary campaign;
  final AppLocale l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final c = campaign;
    final urgent = c.daysLeft <= 2;

    return UITap(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.headline.copyWith(color: UIColorsToken.textParagraph),
                ),
              ),
              const UISpace.horz(8),
              Text(
                '${(c.progress * 100).round()}%',
                style: theme.typo.inter.headline.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w600),
              ),
              const UISpace.horz(8),
              Text(
                l10n.mosque_campaign_days_left_short(c.daysLeft),
                style: theme.typo.inter.bodySmall
                    .copyWith(color: urgent ? UIColorsToken.red : UIColorsToken.textParagraph),
              ),
            ],
          ),
          const UISpace.vert(10),
          UIProgressLine(
            current: c.collectedAmount,
            total: c.goalAmount,
            height: 4,
            fillColor: UIColorsToken.yellow,
            trackColor: UIColorsToken.white.withValues(alpha: 0.10),
          ),
        ],
      ),
    );
  }
}
