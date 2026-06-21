import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../state_management/favorites/hadiths/favorite_hadiths_provider.dart';
import 'favorite_card.dart';
import 'favorite_list_scaffold.dart';

/// Favourite hadiths tab. See [FavoriteAyahsView] for the keep-alive / one-shot
/// load behaviour.
class FavoriteHadithsView extends ConsumerStatefulWidget {
  const FavoriteHadithsView({super.key});

  @override
  ConsumerState<FavoriteHadithsView> createState() =>
      _FavoriteHadithsViewState();
}

class _FavoriteHadithsViewState extends ConsumerState<FavoriteHadithsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(favoriteHadithsProvider.notifier).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(favoriteHadithsProvider.notifier);
    final state = ref.watch(favoriteHadithsProvider);
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
        final hadith = item.hadith;
        final collection = item.collectionTitle(langCode);
        final title = hadith.title(langCode);
        return FavoriteCard(
          title: collection.isEmpty ? title : '$collection - $title',
          subtitle: hadith.description(langCode),
          onTap: () => nav.toHadithReader(
            collectionId: hadith.collectionId,
            initialHadithId: hadith.id,
            recordProgress: false,
          ),
        );
      },
    );
  }
}
