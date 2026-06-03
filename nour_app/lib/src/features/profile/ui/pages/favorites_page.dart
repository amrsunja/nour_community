import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../widgets/views/favorite_adhkars_view.dart';
import '../widgets/views/favorite_ayahs_view.dart';
import '../widgets/views/favorite_duas_view.dart';
import '../widgets/views/favorite_hadiths_view.dart';

/// The four favourite categories shown on the [FavoritesPage] header.
enum FavoritesTab { ayahs, adhkars, duas, hadiths }

/// Profile → Favourites. A swipeable [PageView] of four keep-alive views, with
/// the segmented [UITabs] header kept in sync with the page. Each view owns its
/// own app-lifetime provider, so the underlying requests fire only once per app
/// launch (pull-to-refresh aside). Impact projects are intentionally omitted
/// for now.
@RoutePage()
class FavoritesPage extends HookConsumerWidget {
  const FavoritesPage({super.key});

  static const _tabs = FavoritesTab.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final controller = usePageController();
    final tab = useState(FavoritesTab.ayahs);

    void goTo(FavoritesTab next) {
      tab.value = next;
      controller.animateToPage(
        _tabs.indexOf(next),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }

    String labelFor(FavoritesTab t) => switch (t) {
          FavoritesTab.ayahs => l10n.favorites_tab_ayahs,
          FavoritesTab.adhkars => l10n.favorites_tab_adhkars,
          FavoritesTab.duas => l10n.favorites_tab_duas,
          FavoritesTab.hadiths => l10n.favorites_tab_hadiths,
        };

    return Scaffold(
      appBar: UIAppBar(title: l10n.profile_favourites, onBack: context.pop),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const UISpace.vert(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: UITabs<FavoritesTab>(
                selected: tab.value,
                items: [
                  for (final t in _tabs)
                    UITabItem(value: t, label: labelFor(t)),
                ],
                onChanged: goTo,
              ),
            ),
            const UISpace.vert(12),
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (i) => tab.value = _tabs[i],
                children: const [
                  FavoriteAyahsView(),
                  FavoriteAdhkarsView(),
                  FavoriteDuasView(),
                  FavoriteHadithsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
