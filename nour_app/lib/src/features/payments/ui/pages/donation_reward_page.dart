import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/audio/app_sound.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/impact/data/datasources/impact_remote_datasource.dart';
import 'package:nour/src/features/impact/ui/state_management/impact_project_detail_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/profile/ui/widgets/reward_scaffold.dart';

import '../../data/models/tx_enums.dart';
import '../widgets/reward_coins_badge.dart';

/// Step 3 of the donation flow — "Jazak Allahu Khayr". Shown once the webhook
/// confirmed the payment (or the first invoice of a recurring donation).
///
/// Route: `donation-reward/:projectId?amount=&frequency=`.
@RoutePage()
class DonationRewardPage extends ConsumerWidget {
  const DonationRewardPage({
    super.key,
    @PathParam('projectId') required this.projectId,
    @QueryParam('amount') this.amount = 0,
    @QueryParam('frequency') this.frequency = 'oneTime',
  });

  final int projectId;
  final double amount;
  final String frequency;

  DonationFrequency get _frequency => DonationFrequency.values.firstWhere(
        (f) => f.name == frequency,
        orElse: () => DonationFrequency.oneTime,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final typo = UITheme.of(context).typo;

    final project = ref.watch(
      impactProjectDetailProvider(projectId).select((s) => s.project),
    );
    final currency = project?.currency ?? 'EUR';
    final money = ImpactFormat.money(amount, currency);
    final amountLabel = switch (_frequency) {
      DonationFrequency.monthly => l10n.donate_per_month(money),
      DonationFrequency.yearly => l10n.donate_per_year(money),
      DonationFrequency.oneTime => money,
    };
    final org = project?.organization;
    final avatarUrl = ImpactRemoteDatasource.publicStoryImageUrl(org?.avatarUrl);

    return RewardScaffold(
      celebrationSound: AppSound.achievement2,
      badge: const RewardCoinsBadge(),
      title: l10n.reward_donation_title,
      subtitle: l10n.reward_donation_message,
      primaryLabel: l10n.reward_alhamdulilah,
      secondaryLabel: l10n.profile_my_donations,
      onPrimary: () => context.router.maybePop(),
      onSecondary: () {
        context.router.maybePop();
        nav.toMyDonations();
      },
      content: Column(
        children: [
          // "You donated  100€"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: UIColorsToken.black80,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _frequency.isRecurring
                      ? l10n.reward_donation_you_give
                      : l10n.reward_donation_you_donated,
                  style: typo.inter.title.copyWith(color: UIColorsToken.white),
                ),
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

          // Project card
          if (project != null)
            Container(
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
                    l10n.reward_donation_project,
                    style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                  ),
                  const UISpace.vert(4),
                  Text(
                    project.title(langCode),
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: typo.inter.title.copyWith(
                      color: UIColorsToken.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (project.subtitle(langCode).isNotEmpty) ...[
                    const UISpace.vert(2),
                    Text(
                      project.subtitle(langCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ],
                  if (org != null) ...[
                    const UISpace.vert(10),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: avatarUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => Image.asset(
                                    Assets.images.illustration1.path,
                                    width: 22,
                                    height: 22,
                                  ),
                                )
                              : Image.asset(
                                  Assets.images.illustration1.path,
                                  width: 22,
                                  height: 22,
                                ),
                        ),
                        const UISpace.horz(8),
                        Expanded(
                          child: Text(
                            l10n.reward_donation_via(org.name(langCode)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                          ),
                        ),
                        if (org.isVerified)
                          Text(
                            l10n.impact_verified,
                            style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            )
                .animate(delay: const Duration(milliseconds: 650))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
