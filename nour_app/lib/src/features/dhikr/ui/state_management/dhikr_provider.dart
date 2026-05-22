import 'package:collection/collection.dart';
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
    final ajrRes = await repo.getTodayDhikrAjr();

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

    ajrRes.when(
      (earned) => state = state.copyWith(earnedAjrByDhikrId: earned),
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

        // Keep the running ajr total in sync with the trigger's high-water mark:
        // total today = ajr * floor(maxCountReached / minCount). The trigger
        // never claws back, so we only ever raise the stored value.
        final dhikr = state.dhikrs.firstWhereOrNull((d) => d.id == dhikrId);
        final earned = Map<int, int>.from(state.earnedAjrByDhikrId);
        if (dhikr != null && dhikr.minCount > 0) {
          final live = dhikr.ajr * (count ~/ dhikr.minCount);
          final prev = earned[dhikrId] ?? 0;
          if (live > prev) earned[dhikrId] = live;
        }

        state = state.copyWith(progressByDhikrId: next, earnedAjrByDhikrId: earned);
      },
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }
}
