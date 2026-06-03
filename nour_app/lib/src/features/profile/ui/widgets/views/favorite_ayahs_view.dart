import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../state_management/favorites/ayahs/favorite_ayahs_provider.dart';
import 'favorite_card.dart';
import 'favorite_list_scaffold.dart';

/// Favourite ayahs tab. Kept alive inside the Favourites [PageView] so swiping
/// away and back doesn't refire the request — the provider is app-lifetime and
/// only loads once per launch (or on pull-to-refresh).
class FavoriteAyahsView extends ConsumerStatefulWidget {
  const FavoriteAyahsView({super.key});

  @override
  ConsumerState<FavoriteAyahsView> createState() => _FavoriteAyahsViewState();
}

class _FavoriteAyahsViewState extends ConsumerState<FavoriteAyahsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(favoriteAyahsProvider.notifier).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(favoriteAyahsProvider.notifier);
    final state = ref.watch(favoriteAyahsProvider);
    final nav = ref.read(navigationServicesProvider);

    return FavoriteListScaffold(
      isLoading: state.isLoading,
      hasError: state.hasError,
      isEmpty: state.isEmpty,
      itemCount: state.items.length,
      onRefresh: presenter.refresh,
      onRetry: presenter.refresh,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return FavoriteCard(
          title: '${item.surahName(langCode)}, Ayah - ${item.ayahNumber}',
          subtitle: item.translation,
          onTap: () => nav.toAyahReader(
            surahNumber: item.surahNumber,
            initialAyah: item.ayahNumber,
            recordProgress: false,
          ),
        );
      },
    );
  }
}
