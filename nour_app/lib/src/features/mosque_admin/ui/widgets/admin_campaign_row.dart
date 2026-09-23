import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

/// Compact campaign row of the admin Donation tab (Figma "Mosque admin —
/// donations"): title + donors on the left, percent + time left on the right,
/// then `collected of goal` and the progress line.
///
/// The donor-facing [MosqueCampaignCard] keeps its cover image; this one is
/// dense on purpose so a manager can scan several campaigns at once.
class AdminCampaignRow extends StatelessWidget {
  const AdminCampaignRow({super.key, required this.campaign, required this.l10n, this.onTap});

  final MosqueCampaignModel campaign;
  final AppLocale l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final c = campaign;
    final endingSoon = c.isEndingSoon;
    final timeLabel = !c.isOpen
        ? l10n.mosque_campaign_closed
        : c.daysLeft == 0
            ? l10n.mosque_campaign_days_left(0)
            : l10n.mosque_admin_campaign_days_left_short(c.daysLeft);

    return UICard(
      onTap: onTap,
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
                  Text(
                    '${c.percent}%',
                    style: typo.inter.title.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: typo.inter.bodySmall.copyWith(
                      color: endingSoon ? UIColorsToken.red : UIColorsToken.textParagraph,
                    ),
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
        ],
      ),
    );
  }
}

/// Small count chip shown next to a section title (e.g. `Active campaigns 3`).
class AdminCountBadge extends StatelessWidget {
  const AdminCountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: UIColorsToken.bgSecondaryGreen, borderRadius: BorderRadius.circular(8)),
      child: Text('$count', style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
    );
  }
}

/// Square shortcut tile of the "Also here" section.
class AdminShortcutTile extends StatelessWidget {
  const AdminShortcutTile({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: UIColorsToken.yellow.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIColorsToken.yellow.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 22, color: UIColorsToken.white),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
            ),
          ],
        ),
      ),
    );
  }
}
