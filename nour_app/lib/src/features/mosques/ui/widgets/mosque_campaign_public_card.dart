import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/mosque_repo.dart';
import 'mosque_format.dart';

/// Last non-anonymous donors of a campaign (best effort — empty on error).
final mosqueCampaignDonorsProvider =
    FutureProvider.autoDispose.family<List<MosqueCampaignDonor>, int>((ref, campaignId) async {
  try {
    return await ref.read(mosqueRepoProvider).getCampaignRecentDonors(campaignId);
  } catch (_) {
    return const <MosqueCampaignDonor>[];
  }
});

/// Fundraising campaign card of the **worshipper** donation tab
/// (Figma "Mosque profile – user POV › Donation", 1093:5464).
///
/// Inset cover → time remaining (red while the campaign is open) → title →
/// description (2 lines) → green progress card (same language as the impact
/// project detail page) → Share / Contribute.
///
/// The denser [MosqueCampaignCard] stays in use on the admin lists, where the
/// status pill and the per-row actions matter more than the visual.
class MosqueCampaignPublicCard extends ConsumerWidget {
  const MosqueCampaignPublicCard({
    super.key,
    required this.campaign,
    required this.l10n,
    required this.onShare,
    required this.onContribute,
    this.onTap,
  });

  static const double _gutter = 14;

  final MosqueCampaignModel campaign;
  final AppLocale l10n;
  final VoidCallback onShare;
  final VoidCallback onContribute;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final c = campaign;
    final hasCover = c.coverUrl != null && c.coverUrl!.isNotEmpty;
    final hasDescription = c.description != null && c.description!.trim().isNotEmpty;

    return UICard(
      padding: const EdgeInsets.all(_gutter),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover, inset inside the card ──────────────────────────────
          if (hasCover) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: c.coverUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: UIColorsToken.bgSurface),
                  errorWidget: (_, __, ___) => Container(color: UIColorsToken.bgSurface),
                ),
              ),
            ),
            const UISpace.vert(14),
          ],

          // ── Time: days left in red while open, creation date once closed ─
          _TimeRow(campaign: c, l10n: l10n),
          const UISpace.vert(10),

          // ── Title + description ───────────────────────────────────────
          Text(
            c.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
          ),
          if (hasDescription) ...[
            const UISpace.vert(6),
            Text(
              c.description!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typo.inter.body.copyWith(color: UIColorsToken.textParagraph, height: 1.35),
            ),
          ],

          // ── Progress (same green card as the impact project detail) ───
          const UISpace.vert(14),
          _ProgressCard(campaign: c, l10n: l10n),

          // ── Actions ───────────────────────────────────────────────────
          const UISpace.vert(14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: UIButton.secondary(
                  label: l10n.mosque_post_share,
                  assetIcon: UIIconsToken.icons.share,
                  fullWidth: true,
                  onTap: onShare,
                ),
              ),
              if (c.isOpen) ...[
                const UISpace.horz(12),
                Expanded(
                  flex: 4,
                  child: UIButton.primary(
                    label: l10n.mosque_campaign_contribute,
                    fullWidth: true,
                    onTap: onContribute,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.campaign, required this.l10n});

  final MosqueCampaignModel campaign;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final open = campaign.isOpen;
    final color = open ? UIColorsToken.red : UIColorsToken.textParagraph;
    final label = open
        ? l10n.mosque_campaign_days_left(campaign.daysLeft)
        : [l10n.mosque_campaign_closed, MosqueFormat.timeAgo(campaign.createdAt, l10n)].join(' · ');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: color),
        const UISpace.horz(6),
        Text(label, style: typo.inter.bodySmall.copyWith(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard({required this.campaign, required this.l10n});

  final MosqueCampaignModel campaign;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final c = campaign;
    final donors = c.donorsCount > 0
        ? ref.watch(mosqueCampaignDonorsProvider(c.id)).valueOrNull ?? const <MosqueCampaignDonor>[]
        : const <MosqueCampaignDonor>[];

    return UICard(
      color: UIColorsToken.bgSecondaryGreen,
      disableBorder: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${MosqueFormat.money(c.collectedAmount)} / ${MosqueFormat.money(c.goalAmount)}',
            style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
          ),
          const UISpace.vert(10),
          UIProgressLine(current: c.collectedAmount, total: c.goalAmount <= 0 ? 1 : c.goalAmount, height: 4),
          if (c.donorsCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  if (donors.isNotEmpty) ...[
                    _DonorAvatars(donors: donors),
                    const UISpace.horz(8),
                  ],
                  Expanded(
                    child: Text(
                      l10n.mosque_campaign_people_donated(MosqueFormat.compact(c.donorsCount)),
                      style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DonorAvatars extends StatelessWidget {
  const _DonorAvatars({required this.donors});

  static const double _size = 22;
  static const double _step = 15;

  final List<MosqueCampaignDonor> donors;

  @override
  Widget build(BuildContext context) {
    final shown = donors.take(3).toList();
    return SizedBox(
      width: _size + _step * (shown.length - 1),
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: _step * i,
              child: UIAvatar(
                url: shown[i].avatarUrl,
                initial: _initial(shown[i].name),
                color: UIColorsToken.bgSurface,
                size: _size,
              ),
            ),
        ],
      ),
    );
  }

  static String _initial(String? name) {
    final n = (name ?? '').trim();
    return n.isEmpty ? 'A' : n.substring(0, 1).toUpperCase();
  }
}
