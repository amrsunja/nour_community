import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../widgets/reward_scaffold.dart';
import '../widgets/reward_star_badge.dart';
import '../widgets/reward_stat_row.dart';

/// Reward shown when the user completes their daily dhikr goal. Displays the
/// total dhikr completed (true count, even past the goal) and the ajr earned.
@RoutePage()
class RewardDailyDhikrPage extends ConsumerWidget {
  const RewardDailyDhikrPage({
    super.key,
    this.dhikrCompleted = 0,
    this.ajrEarned = 0,
  });

  final int dhikrCompleted;
  final int ajrEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);

    return RewardScaffold(
      badge: const RewardStarBadge(),
      title: l10n.reward_dhikr_title,
      subtitle: l10n.reward_dhikr_subtitle,
      content: Column(
        children: [
          RewardStatRow(
            label: l10n.reward_ajr_earned,
            asset: Assets.images.illustration5,
            value: ajrEarned,
          )
              .animate(delay: const Duration(milliseconds: 650))
              .fadeIn(duration: const Duration(milliseconds: 450))
              .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
          const UISpace.vert(12),
          RewardStatRow(
            label: l10n.reward_dhikr_completed,
            asset: Assets.images.illustration7,
            value: dhikrCompleted,
          )
              .animate(delay: const Duration(milliseconds: 780))
              .fadeIn(duration: const Duration(milliseconds: 450))
              .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
      primaryLabel: l10n.reward_alhamdulilah,
      secondaryLabel: l10n.reward_go_further,
      onPrimary: context.pop,
      onSecondary: () {
        context.pop();
        nav.toDhikrsList();
      },
    );
  }
}
