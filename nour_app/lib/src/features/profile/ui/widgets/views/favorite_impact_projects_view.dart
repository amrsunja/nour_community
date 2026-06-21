import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../../../impact/ui/widgets/impact_project_card_widget.dart';
import '../../state_management/favorites/impact/favorite_impact_projects_provider.dart';
import 'favorite_list_scaffold.dart';

/// Favourite impact projects tab. Reuses [ImpactProjectCardWidget] (the same
/// card shown on the Impact list). See [FavoriteAyahsView] for the keep-alive /
/// one-shot load behaviour.
class FavoriteImpactProjectsView extends ConsumerStatefulWidget {
  const FavoriteImpactProjectsView({super.key});

  @override
  ConsumerState<FavoriteImpactProjectsView> createState() =>
      _FavoriteImpactProjectsViewState();
}

class _FavoriteImpactProjectsViewState
    extends ConsumerState<FavoriteImpactProjectsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(favoriteImpactProjectsProvider.notifier).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final presenter = ref.read(favoriteImpactProjectsProvider.notifier);
    final state = ref.watch(favoriteImpactProjectsProvider);
    final nav = ref.read(navigationServicesProvider);

    return FavoriteListScaffold(
      isLoading: state.isLoading,
      hasError: state.hasError,
      isEmpty: state.isEmpty,
      itemCount: state.items.length,
      onRefresh: presenter.refresh,
      onRetry: presenter.refresh,
      itemBuilder: (context, index) {
        final project = state.items[index];
        return ImpactProjectCardWidget(
          project: project,
          onTap: () => nav.toImpactProjectDetail(projectId: project.id),
        );
      },
    );
  }
}
