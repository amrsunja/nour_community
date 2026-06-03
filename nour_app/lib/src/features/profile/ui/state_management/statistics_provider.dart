import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/models/statistics_models.dart';
import '../../data/statistics_repo.dart';
import 'statistics_state.dart';

final statisticsProvider =
    StateNotifierProvider<StatisticsPresenter, StatisticsState>((ref) {
  return StatisticsPresenter(
    repo: ref.read(statisticsRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class StatisticsPresenter extends Presenter<StatisticsState> {
  final StatisticsRepo repo;
  final AppEvents appEvents;

  StatisticsPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(const StatisticsState());

  /// Loads the current range. Idempotent — safe to call on first mount.
  Future<void> init() => load(state.range);

  /// Switches the active [range] and refetches. No-op refetch is fine; results
  /// are cheap (single RPC) and always reflect the latest data.
  Future<void> load(StatRange range) async {
    state = state.copyWith(range: range, isLoading: true);

    final response = await repo.fetchStatistics(range);

    response.when(
      (stats) => state = state.copyWith(stats: stats, isLoading: false),
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }
}
