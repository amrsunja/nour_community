import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/impact_repo.dart';
import 'impact_project_detail_state.dart';
import 'impact_provider.dart';

/// One presenter per opened project; auto-disposed when the detail page is
/// popped.
final impactProjectDetailProvider = StateNotifierProvider.autoDispose
    .family<ImpactProjectDetailPresenter, ImpactProjectDetailState, int>((
      ref,
      projectId,
    ) {
      return ImpactProjectDetailPresenter(
        ref: ref,
        projectId: projectId,
        repo: ref.read(impactRepoProvider),
        appEvents: ref.read(appEventProvider),
      );
    });

class ImpactProjectDetailPresenter extends Presenter<ImpactProjectDetailState> {
  final Ref ref;
  final int projectId;
  final ImpactRepo repo;
  final AppEvents appEvents;

  ImpactProjectDetailPresenter({
    required this.ref,
    required this.projectId,
    required this.repo,
    required this.appEvents,
  }) : super(const ImpactProjectDetailState());

  Future<void> init() async {
    if (state.project != null || state.isLoading) return;
    state = state.copyWith(isLoading: true, hasError: false);

    final detailRes = await repo.getProjectDetail(projectId);
    final favoritesRes = await repo.getFavoriteProjectIds();

    favoritesRes.when(
      (ids) => state = state.copyWith(isFavorite: ids.contains(projectId)),
      (_) {},
    );

    detailRes.when(
      (project) =>
          state = state.copyWith(project: project, isLoading: false),
      (error) {
        state = state.copyWith(isLoading: false, hasError: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  Future<void> refresh() async {
    final res = await repo.getProjectDetail(projectId);
    res.when(
      (project) => state = state.copyWith(project: project),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }

  /// Optimistic favourite toggle; mirrors the change into the Impact list
  /// provider so the card heart stays in sync, and reverts on failure.
  Future<void> toggleFavorite() async {
    final wasFavorite = state.isFavorite;
    state = state.copyWith(isFavorite: !wasFavorite);
    _syncList(!wasFavorite);

    final res = wasFavorite
        ? await repo.removeFavorite(projectId)
        : await repo.addFavorite(projectId);

    res.when((_) {}, (error) {
      state = state.copyWith(isFavorite: wasFavorite);
      _syncList(wasFavorite);
      appEvents.send(ShowErrorEvent(error));
    });
  }

  /// Reflect the favourite change in the (app-lifetime) list provider without a
  /// second network call.
  void _syncList(bool isFavorite) {
    final listState = ref.read(impactProvider);
    final ids = Set<int>.from(listState.favoriteIds);
    isFavorite ? ids.add(projectId) : ids.remove(projectId);
    ref.read(impactProvider.notifier).setFavoriteIds(ids);
  }
}
