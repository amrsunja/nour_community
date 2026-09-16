import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/audio/app_sound.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:nour/src/features/payments/ui/widgets/reward_coins_badge.dart';
import 'package:nour/src/features/profile/ui/widgets/reward_scaffold.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/models/mosque_model.dart';
import '../../data/mosque_repo.dart';
import '../state_management/mosque_profile_provider.dart';
import '../widgets/mosque_donation_widgets.dart';
import '../widgets/mosque_format.dart';
import '../widgets/mosque_header.dart';

/// "Jazak Allahu Khayr" for every confirmed mosque transaction — sadaqa
/// (one-time / recurring), campaign gift, and the yearly membership fee.
///
/// Same celebratory layout as the impact donation reward: it replaces the
/// old in-checkout success card so every paid flow lands on one reward system.
///
/// Route: `mosque/:id/reward?amount=&frequency=&campaignId=&membershipId=`.
@RoutePage()
class MosqueRewardPage extends HookConsumerWidget {
  const MosqueRewardPage({
    super.key,
    @PathParam('id') required this.mosqueId,
    @QueryParam('amount') this.amount = 0,
    @QueryParam('frequency') this.frequency = 'oneTime',
    @QueryParam('campaignId') this.campaignId,
    @QueryParam('membershipId') this.membershipId,
  });

  final int mosqueId;
  final double amount;
  final String frequency;
  final int? campaignId;
  final int? membershipId;

  bool get _isMembership => membershipId != null;
  bool get _isCampaign => campaignId != null;

  DonationFrequency get _frequency => DonationFrequency.values.firstWhere(
        (f) => f.name == frequency,
        orElse: () => DonationFrequency.oneTime,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final typo = UITheme.of(context).typo;

    final mosque = ref.watch(mosqueProfileProvider(mosqueId).select((s) => s.mosque));
    final campaign = useState<MosqueCampaignModel?>(null);

    // The webhook credits the campaign before the checkout flips to success,
    // so a fresh read already includes this gift; the stream keeps it live.
    useEffect(() {
      StreamSubscription<MosqueCampaignModel?>? sub;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(mosqueProfileProvider(mosqueId)).mosque == null) {
          ref.read(mosqueProfileProvider(mosqueId).notifier).init(trackView: false);
        }
      });
      if (campaignId != null) {
        final repo = ref.read(mosqueRepoProvider);
        repo.getCampaign(campaignId!).then((r) => r.when((c) => campaign.value = c, (_) {}));
        sub = repo.watchCampaign(campaignId!).listen((c) {
          if (c != null) campaign.value = c;
        });
      }
      return () => sub?.cancel();
    }, const []);

    final currency = campaign.value?.currency ?? 'EUR';
    final money = ImpactFormat.money(amount, currency);
    final amountLabel = switch (_frequency) {
      DonationFrequency.monthly => l10n.donate_per_month(money),
      DonationFrequency.yearly => l10n.donate_per_year(money),
      DonationFrequency.oneTime => money,
    };
    final giveLabel = _isMembership
        ? l10n.reward_mosque_you_contributed
        : _frequency.isRecurring
            ? l10n.reward_donation_you_give
            : l10n.reward_donation_you_donated;
    final subtitle = _isMembership
        ? l10n.reward_mosque_membership_message
        : _isCampaign
            ? l10n.reward_mosque_campaign_message
            : l10n.reward_mosque_sadaqa_message;

    final canIssueReceipts = mosque?.canIssueTaxReceipts ?? false;

    // What the gift went to: the campaign (with its refreshed progress) or the
    // mosque itself for sadaqa / membership.
    final Widget? contextCard = _isCampaign
        ? (campaign.value == null
            ? const SizedBox(height: 140, child: Center(child: UICircularProgressBar()))
            : _CampaignRewardCard(campaign: campaign.value!, mosque: mosque, l10n: l10n))
        : (mosque == null
            ? null
            : _MosqueRewardCard(
                mosque: mosque,
                label: _isMembership ? l10n.mosque_checkout_membership_fee : l10n.mosque_checkout_sadaqa,
                l10n: l10n,
              ));

    return RewardScaffold(
      scrollable: true, // campaign progress card can exceed small screens
      celebrationSound: AppSound.achievement2,
      badge: const RewardCoinsBadge(),
      title: l10n.reward_donation_title,
      subtitle: subtitle,
      primaryLabel: l10n.reward_alhamdulilah,
      secondaryLabel: canIssueReceipts ? l10n.reward_mosque_my_receipts : l10n.profile_my_donations,
      onPrimary: () => context.router.maybePop(),
      onSecondary: () {
        context.router.maybePop();
        if (canIssueReceipts) {
          nav.toMyMosqueReceipts();
        } else {
          nav.toMyDonations();
        }
      },
      content: Column(
        children: [
          // "You donated  100€"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  UIColorsToken.black80,
                  UIColorsToken.yellow.withValues(alpha: 0.18),
                  UIColorsToken.black80,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    giveLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.title.copyWith(color: UIColorsToken.white),
                  ),
                ),
                const UISpace.horz(10),
                Text(
                  amountLabel,
                  style: typo.inter.largeTitle.copyWith(
                    color: UIColorsToken.textYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: const Duration(milliseconds: 550))
              .fadeIn(duration: const Duration(milliseconds: 450))
              .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),

          const UISpace.vert(12),

          if (contextCard != null)
            contextCard
                .animate(delay: const Duration(milliseconds: 650))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

/// Campaign gift: cover + title, the goal progress *including* this donation,
/// and the mosque behind it.
class _CampaignRewardCard extends StatelessWidget {
  const _CampaignRewardCard({required this.campaign, required this.mosque, required this.l10n});

  final MosqueCampaignModel campaign;
  final MosqueModel? mosque;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (campaign.coverUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CachedNetworkImage(imageUrl: campaign.coverUrl!, fit: BoxFit.cover),
                  ),
                ),
                const UISpace.horz(12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mosque_campaign_title,
                      style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
                    ),
                    const UISpace.vert(4),
                    Text(
                      campaign.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.title.copyWith(
                        color: UIColorsToken.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const UISpace.vert(14),
          UIProgressLine(
            current: campaign.collectedAmount,
            total: campaign.goalAmount <= 0 ? 1 : campaign.goalAmount,
            height: 8,
          ),
          const UISpace.vert(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MosqueFormat.money(campaign.collectedAmount),
                style: typo.inter.title.copyWith(
                  color: UIColorsToken.textYellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const UISpace.horz(6),
              Expanded(
                child: Text(
                  l10n.mosque_campaign_of_goal(MosqueFormat.money(campaign.goalAmount)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                ),
              ),
              Text(
                '${campaign.percent}%',
                style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
              ),
            ],
          ),
          if (mosque != null) ...[
            const UISpace.vert(12),
            _MosqueRow(mosque: mosque!, l10n: l10n, showTaxBadge: campaign.showTaxBadge),
          ],
        ],
      ),
    );
  }
}

/// Sadaqa / membership: the mosque that received the gift.
class _MosqueRewardCard extends StatelessWidget {
  const _MosqueRewardCard({required this.mosque, required this.label, required this.l10n});

  final MosqueModel mosque;
  final String label;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reward_mosque_label,
            style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
          ),
          const UISpace.vert(8),
          _MosqueRow(mosque: mosque, l10n: l10n, showTaxBadge: mosque.canIssueTaxReceipts, big: true),
          const UISpace.vert(8),
          Text(
            label,
            style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
          ),
        ],
      ),
    );
  }
}

class _MosqueRow extends StatelessWidget {
  const _MosqueRow({
    required this.mosque,
    required this.l10n,
    this.showTaxBadge = false,
    this.big = false,
  });

  final MosqueModel mosque;
  final AppLocale l10n;
  final bool showTaxBadge;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Row(
      children: [
        MosqueLogo(mosque: mosque, size: big ? 34 : 22, radius: big ? 10 : 6),
        const UISpace.horz(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mosque.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: big
                    ? typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)
                    : typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
              ),
              if (big && (mosque.city ?? '').isNotEmpty)
                Text(
                  mosque.city!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                ),
            ],
          ),
        ),
        if (showTaxBadge) ...[const UISpace.horz(6), MosqueTaxBadge(l10n: l10n)],
      ],
    );
  }
}
