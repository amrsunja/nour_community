import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../../../data/favorites_repo.dart';
import 'favorite_impact_projects_state.dart';

/// App-lifetime provider (NOT autoDispose): see [favoriteAyahsProvider].
final favoriteImpactProjectsProvider =
    StateNotifierProvider<
      FavoriteImpactProjectsPresenter,
      FavoriteImpactProjectsState
    >((ref) {
      return FavoriteImpactProjectsPresenter(
        repo: ref.read(favoritesRepoProvider),
        appEvents: ref.read(appEventProvider),
      );
    });

class FavoriteImpactProjectsPresenter
    extends Presenter<FavoriteImpactProjectsState> {
  final FavoritesRepo repo;
  final AppEvents appEvents;

  FavoriteImpactProjectsPresenter({required this.repo, required this.appEvents})
    : super(const FavoriteImpactProjectsState());

  Future<void> init() async {
    if (state.loaded || state.isLoading) return;
    await _load();
  }

  Future<void> refresh() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    state = state.copyWith(isLoading: !silent, hasError: false);

    final res = await repo.getFavoriteImpactProjects();
    res.when(
      (items) =>
          state = state.copyWith(items: items, loaded: true, isLoading: false),
      (error) {
        state = state.copyWith(isLoading: false, hasError: !silent);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }
}
