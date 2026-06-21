import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/hadith/ui/pages/hadiths_page.dart';
import 'package:nour/src/features/quran/ui/widgets/quran_source_view.dart';

/// The two source categories shown on the [SourcePage] header.
enum SourceTab { quran, hadith }

@RoutePage()
class SourcePage extends HookConsumerWidget {
  const SourcePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final tab = useState(SourceTab.quran);

    return Scaffold(
      body: Column(
        children: [
          const UISpace.vert(8),
          Text(
            l10n.source_title,
            style: typo.inter.title.copyWith(color: UIColorsToken.white),
          ),
          const UISpace.vert(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: UITabs<SourceTab>(
              selected: tab.value,
              items: [
                UITabItem(value: SourceTab.quran, label: l10n.source_quran),
                UITabItem(value: SourceTab.hadith, label: l10n.source_hadith),
              ],
              onChanged: (t) => tab.value = t,
            ),
          ),
          const UISpace.vert(16),
          Expanded(
            child: switch (tab.value) {
              SourceTab.quran => const QuranSourceView(),
              SourceTab.hadith => const HadithsPage(),
            },
          ),
        ],
      ),
    );
  }
}
