import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../state_management/favorites/adhkars/favorite_adhkars_provider.dart';
import 'favorite_card.dart';
import 'favorite_list_scaffold.dart';

/// Favourite adhkars tab. See [FavoriteAyahsView] for the keep-alive / one-shot
/// load behaviour.
class FavoriteAdhkarsView extends ConsumerStatefulWidget {
  const FavoriteAdhkarsView({super.key});

  @override
  ConsumerState<FavoriteAdhkarsView> createState() =>
      _FavoriteAdhkarsViewState();
}

class _FavoriteAdhkarsViewState extends ConsumerState<FavoriteAdhkarsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(favoriteAdhkarsProvider.notifier).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(favoriteAdhkarsProvider.notifier);
    final state = ref.watch(favoriteAdhkarsProvider);
    final nav = ref.read(navigationServicesProvider);

    return FavoriteListScaffold(
      isLoading: state.isLoading,
      hasError: state.hasError,
      isEmpty: state.isEmpty,
      itemCount: state.items.length,
      onRefresh: presenter.refresh,
      onRetry: presenter.refresh,
      itemBuilder: (context, index) {
        final adhkar = state.items[index];
        return FavoriteCard(
          title: adhkar.when(langCode) ?? adhkar.reference(langCode) ?? '',
          subtitle: adhkar.reference(langCode) ?? '',
          // Adhkar detail is per-subcategory; jump straight to this exact dhikr.
          onTap: () => nav.toAdhkarDetail(
            subcategoryId: adhkar.subcategoryId,
            initialAdhkarId: adhkar.id,
          ),
        );
      },
    );
  }
}
