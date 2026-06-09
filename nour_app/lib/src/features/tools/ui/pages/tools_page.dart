import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';

import '../widgets/tool_card_widget.dart';

@RoutePage()
class ToolsPage extends HookConsumerWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final analytics = ref.read(analyticsRepoProvider);

    final tools = useMemoized(() {
      return [
        _ToolItem(
          Assets.images.illustration12,
          l10n.tools_daily_ayah,
          onTap: () {
            analytics.trackDailyVerseView(source: 'tools');
            nav.toDailyAyah();
          }
        ),
        _ToolItem(
          Assets.images.illustration19,
          l10n.tools_daily_dua,
          onTap: () {
            analytics.trackDailyDuaRecite(period: 'daily');
            nav.toDailyDua();
          }
        ),
        _ToolItem(
          Assets.images.illustration13,
          l10n.tools_dua_library,
          onTap: () {
            analytics.trackFeatureOpen('dua_library', source: 'tools');
            nav.toDuaLibrary();
          }
        ),
        _ToolItem(
          Assets.images.illustration14,
          l10n.tools_daily_quiz,
          onTap: () {
            analytics.trackFeatureOpen('quiz', source: 'tools');
            nav.toQuiz();
          }
        ),
        _ToolItem(
          Assets.images.illustration15,
          l10n.tools_qibla_finder,
          onTap: () {
            analytics.trackFeatureOpen('qibla_finder', source: 'tools');
            nav.toQiblaFinder();
          }
        ),
        _ToolItem(
          Assets.images.illustration16,
          l10n.tools_prayer_times,
          onTap: () {
            analytics.trackFeatureOpen('prayer_times', source: 'tools');
            nav.toPrayerTimes();
          }
        ),
        _ToolItem(
          Assets.images.illustration17,
          l10n.tools_zakat_calculator,
          onTap: () {
            analytics.trackFeatureOpen('zakat_calculator', source: 'tools');
            nav.toZakatCalculator();
          }
        ),
        _ToolItem(
          Assets.images.illustration18,
          l10n.tools_hijri_calendar,
          onTap: () {
            analytics.trackFeatureOpen('hijri_calendar', source: 'tools');
            nav.toHijriCalendar();
          }
        ),
        _ToolItem(
          Assets.images.illustration36,
          l10n.adhkar_all_title,
          onTap: () {
            analytics.trackFeatureOpen('adhkars_list', source: 'tools');
            nav.toAdhkarsList();
          }
        ),
      ];
    }, [l10n]);

    return Scaffold(
      appBar: UIAppBar(title: l10n.tools_title),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return ToolCardWidget(
            illustration: tool.asset.image(
              height: 50,
              filterQuality: FilterQuality.high),
            label: tool.label,
            onTap: tool.onTap,
          );
        },
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem(this.asset, this.label, {this.onTap});

  final AssetGenImage asset;
  final String label;
  final VoidCallback? onTap;
}
