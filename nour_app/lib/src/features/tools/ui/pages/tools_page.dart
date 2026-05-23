import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../widgets/tool_card_widget.dart';

@RoutePage()
class ToolsPage extends HookConsumerWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);

    final tools = useMemoized(() {
      return [
        _ToolItem(
          Assets.images.illustration12,
          l10n.tools_daily_ayah,
          onTap: () {
            nav.toDailyAyah();
          }
        ),
        _ToolItem(
          Assets.images.illustration19,
          l10n.tools_daily_dua,
          onTap: () {
            nav.toDailyDua();
          }
        ),
        _ToolItem(
          Assets.images.illustration13,
          l10n.tools_dua_library,
          onTap: () {
            nav.toDuaLibrary();
          }
        ),
        _ToolItem(
          Assets.images.illustration14, 
          l10n.tools_daily_quiz,
          onTap: () {}
        ),
        _ToolItem(
          Assets.images.illustration15, 
          l10n.tools_qibla_finder,
          onTap: () {}
        ),
        _ToolItem(
          Assets.images.illustration16, 
          l10n.tools_prayer_times,
          onTap: () {}
        ),
        _ToolItem(
          Assets.images.illustration7, 
          l10n.tools_dhikr_counter,
          onTap: () {
            nav.toDhikrsList();
          }
        ),
        _ToolItem(
          Assets.images.illustration17, 
          l10n.tools_zakat_calculator,
          onTap: () {}
        ),
        _ToolItem(
          Assets.images.illustration18, 
          l10n.tools_hijri_calendar,
          onTap: () {}
        ),
      ];
    });

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
