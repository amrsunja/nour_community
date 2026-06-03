import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

import '../../data/models/statistics_models.dart';
import '../state_management/statistics_provider.dart';
import '../widgets/statistics_card.dart';

/// Profile › Statistics. Three time-range filters (all / week / today) over
/// three aggregate cards: earned ajr, dhikr completed, completed deeds
/// (donated projects). Data comes from the `fn_user_statistics` RPC.
@RoutePage()
class ProfileStatisticsPage extends ConsumerStatefulWidget {
  const ProfileStatisticsPage({super.key});

  @override
  ConsumerState<ProfileStatisticsPage> createState() =>
      _ProfileStatisticsPageState();
}

class _ProfileStatisticsPageState
    extends ConsumerState<ProfileStatisticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final state = ref.watch(statisticsProvider);
    final notifier = ref.read(statisticsProvider.notifier);
    final stats = state.stats ?? const UserStatistics.empty();

    final tabs = <UITabItem<StatRange>>[
      UITabItem(value: StatRange.all, label: l10n.statistics_filter_all),
      UITabItem(value: StatRange.week, label: l10n.statistics_filter_week),
      UITabItem(value: StatRange.today, label: l10n.statistics_filter_today),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            onBack: () => context.router.maybePop(),
            title: l10n.profile_statistics,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                12,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  UITabs<StatRange>(
                    selected: state.range,
                    items: tabs,
                    onChanged: notifier.load,
                  ),
                  const UISpace.vert(10),

                  // ---- Top row: earned ajr + dhikr completed ----
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: StatisticsCard(
                          label: l10n.statistics_earned_ajr,
                          value: stats.earnedAjr,
                          asset: Assets.images.illustration5,
                        ),
                      ),
                      Expanded(
                        child: StatisticsCard(
                          label: l10n.statistics_dhikr_completed,
                          value: stats.dhikrCompleted,
                          asset: Assets.images.illustration7,
                        ),
                      ),
                    ],
                  ),

                  // ---- Wide: completed deeds (donated projects) ----
                  StatisticsCard(
                    label: l10n.statistics_completed_deeds,
                    value: stats.completedDeeds,
                    asset: Assets.images.illustration8,
                    wide: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
