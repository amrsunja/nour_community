import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/dhikr_repo.dart';
import '../../data/models/dhikr_progress_model.dart';
import 'dhikr_state.dart';

final dhikrProvider =
    StateNotifierProvider<DhikrPresenter, DhikrState>((ref) {
  return DhikrPresenter(
    repo: ref.read(dhikrRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class DhikrPresenter extends Presenter<DhikrState> {
  final DhikrRepo repo;
  final AppEvents appEvents;

  DhikrPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const DhikrState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true);

    final dhikrsRes = await repo.getDhikrs();
    final progressRes = await repo.getTodayProgress();

    dhikrsRes.when(
      (dhikrs) => state = state.copyWith(dhikrs: dhikrs),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    progressRes.when(
      (progress) => state = state.copyWith(
        progressByDhikrId: {for (final p in progress) p.dhikrId: p},
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    state = state.copyWith(isLoading: false);
  }

  /// Persists [count] for [dhikrId]. Called when the user taps "I'm done" or
  /// pops the dhikr page. The DB trigger owns completion + ajr.
  Future<void> saveProgress({required int dhikrId, required int count}) async {
    // Nothing changed → skip the round-trip.
    if (count == state.currentCountOf(dhikrId)) return;

    final response = await repo.saveProgress(dhikrId: dhikrId, count: count);

    response.when(
      (saved) {
        final next = Map<int, DhikrProgressModel>.from(state.progressByDhikrId)
          ..[dhikrId] = saved;
        state = state.copyWith(progressByDhikrId: next);
      },
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }
}
