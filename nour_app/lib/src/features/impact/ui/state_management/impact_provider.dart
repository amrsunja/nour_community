import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/impact_repo.dart';
import '../../data/models/project_category_model.dart';
import 'impact_state.dart';

/// App-lifetime provider (NOT autoDispose) so the Impact tab keeps its data
/// while the user navigates the bottom navbar.
final impactProvider = StateNotifierProvider<ImpactPresenter, ImpactState>((
  ref,
) {
  return ImpactPresenter(
    repo: ref.read(impactRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class ImpactPresenter extends Presenter<ImpactState> {
  final ImpactRepo repo;
  final AppEvents appEvents;

  ImpactPresenter({required this.repo, required this.appEvents})
    : super(const ImpactState());

  /// Synthetic "All" tab, prepended to the fetched categories.
  static const _allCategory = ProjectCategoryModel(
    id: ProjectCategoryModel.allId,
    titleEn: 'All',
    titleFr: 'Tous',
    titleAr: 'الكل',
    titleDe: 'Alle',
    titleNl: 'Alle',
    titleTr: 'Tümü',
    titleId: 'Semua',
    titleUr: 'سب',
    titleBn: 'সব',
    titleMs: 'Semua',
    position: -1,
  );

  Future<void> init() async {
    if (state.loaded || state.isLoading) return;
    await _loadAll();
  }

  Future<void> refresh() => _loadAll(silent: true);

  Future<void> _loadAll({bool silent = false}) async {
    state = state.copyWith(isLoading: !silent, hasError: false);

    final categoriesRes = await repo.getCategories();
    final projectsRes = await repo.getProjects(
      categoryId: state.selectedCategoryId == ProjectCategoryModel.allId
          ? null
          : state.selectedCategoryId,
    );
    final favoritesRes = await repo.getFavoriteProjectIds();

    categoriesRes.when(
      (categories) => state = state.copyWith(
        categories: [_allCategory, ...categories],
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    favoritesRes.when(
      (ids) => state = state.copyWith(favoriteIds: ids),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    projectsRes.when(
      (projects) => state = state.copyWith(
        projects: projects,
        loaded: true,
        isLoading: false,
      ),
      (error) {
        state = state.copyWith(isLoading: false, hasError: !silent);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  /// Switches the active category tab and reloads its projects.
  Future<void> selectCategory(int categoryId) async {
    if (categoryId == state.selectedCategoryId) return;
    state = state.copyWith(
      selectedCategoryId: categoryId,
      isLoading: true,
      hasError: false,
    );

    final res = await repo.getProjects(
      categoryId: categoryId == ProjectCategoryModel.allId ? null : categoryId,
    );

    res.when(
      (projects) =>
          state = state.copyWith(projects: projects, isLoading: false),
      (error) {
        state = state.copyWith(isLoading: false, hasError: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  /// Replaces the favourite-id set without a network call. Used by the detail
  /// presenter to keep the list cards in sync after a toggle.
  void setFavoriteIds(Set<int> ids) {
    state = state.copyWith(favoriteIds: ids);
  }

  /// Optimistic favourite toggle; reverts on failure.
  Future<void> toggleFavorite(int projectId) async {
    final wasFavorite = state.isFavorite(projectId);
    final next = Set<int>.from(state.favoriteIds);
    wasFavorite ? next.remove(projectId) : next.add(projectId);
    state = state.copyWith(favoriteIds: next);

    final res = wasFavorite
        ? await repo.removeFavorite(projectId)
        : await repo.addFavorite(projectId);

    res.when((_) {}, (error) {
      // Revert.
      final reverted = Set<int>.from(state.favoriteIds);
      wasFavorite ? reverted.add(projectId) : reverted.remove(projectId);
      state = state.copyWith(favoriteIds: reverted);
      appEvents.send(ShowErrorEvent(error));
    });
  }
}
