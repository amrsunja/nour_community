import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../state_management/favorites/duas/favorite_duas_provider.dart';
import 'favorite_card.dart';
import 'favorite_list_scaffold.dart';

/// Favourite duas tab. See [FavoriteAyahsView] for the keep-alive / one-shot
/// load behaviour.
class FavoriteDuasView extends ConsumerStatefulWidget {
  const FavoriteDuasView({super.key});

  @override
  ConsumerState<FavoriteDuasView> createState() => _FavoriteDuasViewState();
}

class _FavoriteDuasViewState extends ConsumerState<FavoriteDuasView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(favoriteDuasProvider.notifier).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(favoriteDuasProvider.notifier);
    final state = ref.watch(favoriteDuasProvider);
    final nav = ref.read(navigationServicesProvider);

    return FavoriteListScaffold(
      isLoading: state.isLoading,
      hasError: state.hasError,
      isEmpty: state.isEmpty,
      itemCount: state.items.length,
      onRefresh: presenter.refresh,
      onRetry: presenter.refresh,
      itemBuilder: (context, index) {
        final dua = state.items[index];
        return FavoriteCard(
          title: dua.title(langCode),
          subtitle: dua.when(langCode),
          onTap: () => nav.toDuaReader(
            initialDuaId: dua.id,
            recordProgress: false,
          ),
        );
      },
    );
  }
}
