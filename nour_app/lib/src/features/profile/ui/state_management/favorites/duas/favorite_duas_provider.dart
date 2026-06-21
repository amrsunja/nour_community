import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../../../data/favorites_repo.dart';
import 'favorite_duas_state.dart';

/// App-lifetime provider (NOT autoDispose): see [favoriteAyahsProvider].
final favoriteDuasProvider =
    StateNotifierProvider<FavoriteDuasPresenter, FavoriteDuasState>((ref) {
  return FavoriteDuasPresenter(
    repo: ref.read(favoritesRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class FavoriteDuasPresenter extends Presenter<FavoriteDuasState> {
  final FavoritesRepo repo;
  final AppEvents appEvents;

  FavoriteDuasPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const FavoriteDuasState());

  Future<void> init() async {
    if (state.loaded || state.isLoading) return;
    await _load();
  }

  Future<void> refresh() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    state = state.copyWith(isLoading: !silent, hasError: false);

    final res = await repo.getFavoriteDuas();
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
