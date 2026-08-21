import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/features/impact/data/datasources/impact_remote_datasource.dart';
import 'package:nour/src/core/audio/app_sound.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/profile/ui/widgets/reward_scaffold.dart';

import '../state_management/zakat_cart_provider.dart';
import '../widgets/reward_coins_badge.dart';

/// "Jazak Allahu Khayr" after a confirmed zakat payment — shows the amount the
/// user gave and the projects it was allocated to (from [zakatCartProvider]).
@RoutePage()
class ZakatRewardPage extends HookConsumerWidget {
  const ZakatRewardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final typo = UITheme.of(context).typo;
    final langCode = Localizations.localeOf(context).languageCode;

    final cart = ref.watch(zakatCartProvider);
    final items = cart?.items ?? const <ZakatCartItem>[];
    final total = cart?.allocated ?? 0;
    const currency = 'EUR';

    return RewardScaffold(
      scrollable: true, // carousel + totals can exceed small screens
      celebrationSound: AppSound.achievement2,
      badge: const RewardCoinsBadge(),
      title: l10n.reward_donation_title,
      subtitle: l10n.zakat_reward_message,
      primaryLabel: l10n.reward_alhamdulilah,
      secondaryLabel: l10n.profile_my_donations,
      onPrimary: () => context.router.maybePop(),
      onSecondary: () {
        context.router.maybePop();
        nav.toMyDonations();
      },
      content: Column(
        children: [
          // "You gave  510€"
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
                Text(
                  l10n.zakat_reward_you_gave,
                  style: typo.inter.title.copyWith(color: UIColorsToken.white),
                ),
                Text(
                  ImpactFormat.money(total, currency),
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

          if (items.isNotEmpty) ...[
            const UISpace.vert(14),
            Text(
              l10n.zakat_checkout_allocated_to,
              style: typo.inter.bodyMedium.copyWith(
                color: UIColorsToken.white,
                fontWeight: FontWeight.w600,
              ),
            )
                .animate(delay: const Duration(milliseconds: 600))
                .fadeIn(duration: const Duration(milliseconds: 450)),
            const UISpace.vert(10),
            _AllocatedProjectsCarousel(items: items, langCode: langCode, l10n: l10n)
                .animate(delay: const Duration(milliseconds: 650))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
          ],
        ],
      ),
    );
  }
}

/// Auto-playing carousel of the funded projects — one card per allocation,
/// styled like the donation reward's project card, with a dot indicator.
class _AllocatedProjectsCarousel extends HookWidget {
  const _AllocatedProjectsCarousel({
    required this.items,
    required this.langCode,
    required this.l10n,
  });

  final List<ZakatCartItem> items;
  final String langCode;
  final AppLocale l10n;

  static const _autoPlayEvery = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    final index = useState(0);

    // Auto-play: advance (and wrap) every few seconds while >1 card.
    useEffect(() {
      if (items.length <= 1) return null;
      final timer = Timer.periodic(_autoPlayEvery, (_) {
        if (!controller.hasClients) return;
        final next = (index.value + 1) % items.length;
        controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      });
      return timer.cancel;
    }, [items.length]);

    return Column(
      children: [
        SizedBox(
          height: 158,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => index.value = i,
            itemCount: items.length,
            itemBuilder: (_, i) => _AllocatedProjectCard(
              item: items[i],
              langCode: langCode,
              l10n: l10n,
            ),
          ),
        ),
        if (items.length > 1) ...[
          const UISpace.vert(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < items.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index.value == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index.value == i
                        ? UIColorsToken.white
                        : UIColorsToken.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Mirrors the donation reward's project card: "Project" label, title + the
/// allocated amount, subtitle and the partner org row.
class _AllocatedProjectCard extends StatelessWidget {
  const _AllocatedProjectCard({
    required this.item,
    required this.langCode,
    required this.l10n,
  });

  final ZakatCartItem item;
  final String langCode;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final project = item.project;
    final org = project.organization;
    final avatarUrl =
        ImpactRemoteDatasource.publicStoryImageUrl(org?.avatarUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
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
            style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
          ),
          const UISpace.vert(4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title(langCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.title.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const UISpace.horz(10),
              Text(
                ImpactFormat.money(item.amount, project.currency),
                style: typo.inter.title.copyWith(
                  color: UIColorsToken.textYellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (project.subtitle(langCode).isNotEmpty) ...[
            const UISpace.vert(2),
            Text(
              project.subtitle(langCode),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typo.inter.bodySmall
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
          const Spacer(),
          if (org != null)
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
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                ),
                if (org.isVerified)
                  Text(
                    l10n.impact_verified,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textYellow),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
