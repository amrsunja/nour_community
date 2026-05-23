import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/adhkar_repo.dart';
import '../../data/models/adhkar_model.dart';
import 'adhkar_state.dart';

final adhkarProvider =
    StateNotifierProvider<AdhkarPresenter, AdhkarState>((ref) {
  return AdhkarPresenter(
    repo: ref.read(adhkarRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class AdhkarPresenter extends Presenter<AdhkarState> {
  final AdhkarRepo repo;
  final AppEvents appEvents;

  AdhkarPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const AdhkarState());

  Future<void> init() async {
    if (state.categories.isNotEmpty && state.subcategories.isNotEmpty) return;

    state = state.copyWith(isLoading: true);

    final categoriesRes = await repo.getCategories();
    final subcategoriesRes = await repo.getSubcategories();

    categoriesRes.when(
      (categories) => state = state.copyWith(categories: categories),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    subcategoriesRes.when(
      (subcategories) => state = state.copyWith(subcategories: subcategories),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoading: false);
  }

  void search(String query) => state = state.copyWith(query: query);

  void clearSearch() => state = state.copyWith(query: '');

  /// Loads adhkars for [subcategoryId] once and caches them in state.
  Future<void> ensureAdhkars(int subcategoryId) async {
    if (state.adhkarsBySubcategory.containsKey(subcategoryId)) return;
    if (state.isLoadingAdhkars(subcategoryId)) return;

    state = state.copyWith(
      loadingSubcategoryIds: {...state.loadingSubcategoryIds, subcategoryId},
    );

    final response = await repo.getAdhkars(subcategoryId);

    response.when(
      (adhkars) {
        state = state.copyWith(
          adhkarsBySubcategory: {
            ...state.adhkarsBySubcategory,
            subcategoryId: adhkars,
          },
          loadingSubcategoryIds: {...state.loadingSubcategoryIds}
            ..remove(subcategoryId),
        );
      },
      (error) {
        state = state.copyWith(
          loadingSubcategoryIds: {...state.loadingSubcategoryIds}
            ..remove(subcategoryId),
        );
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  List<AdhkarModel> adhkarsOf(int subcategoryId) => state.adhkarsOf(subcategoryId);
}
