import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/enums/calculation_method_type.dart';
import 'package:nour/src/core/utils/geolocator/geolocator_tools.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/notifications/ui/state_management/notifications_provider.dart';

import '../../data/models/prayer_settings_model.dart';
import '../../data/prayer_settings_repo.dart';
import 'prayer_times_state.dart';

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesPresenter, PrayerTimesState>((ref) {
  return PrayerTimesPresenter(
    repo: ref.read(prayerSettingsRepoProvider),
    appEvents: ref.read(appEventProvider),
    ref: ref,
  );
});

class PrayerTimesPresenter extends Presenter<PrayerTimesState> {
  final PrayerSettingsRepo repo;
  final AppEvents appEvents;
  final Ref ref;

  /// Fires when the current `nextTime` elapses to roll the state over to the
  /// following prayer, keeping the dashboard countdown self-advancing.
  Timer? _rolloverTimer;

  PrayerTimesPresenter({
    required this.repo,
    required this.appEvents,
    required this.ref,
  }) : super(const PrayerTimesState());

  @override
  void dispose() {
    _rolloverTimer?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);

    final response = await repo.getSettings();
    response.when(
      (settings) => state = state.copyWith(settings: settings),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    await _recompute();
  }

  /// Lightweight re-sync of the current/next prayer without re-reading
  /// settings. Used on app resume to recover from suspended timers.
  Future<void> refresh() => _recompute();

  /// Persists the new calculation method and reschedules every notification
  /// (prayers + adhkar + daily ayah) so they match the new prayer times.
  Future<void> changeMethod(CalculationMethodType method) async {
    if (method == state.settings.method) return;
    final next = state.settings.copyWith(method: method);
    await _persist(next);
    await _recompute();
    await ref.read(notificationsProvider.notifier).rescheduleAll();
  }

  Future<void> _persist(PrayerSettingsModel settings) async {
    final response = await repo.save(settings);
    response.when(
      (saved) => state = state.copyWith(settings: saved),
      (error) {
        // Keep the optimistic value so the UI stays responsive.
        state = state.copyWith(settings: settings);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  Future<void> _recompute() async {
    try {
      final position = await GeolocatorTools.currentOrCachedPosition();
      final method = state.settings.method;

      final times = await IslamicTools.getPrayerTimesForDate(
        position: position,
        method: method,
      );
      final next = await IslamicTools.getNextPrayer(
        position: position,
        method: method,
      );
      final jumua = await IslamicTools.getJumuaTime(
        position: position,
        method: method,
      );

      state = state.copyWith(
        isLoading: false,
        hasLocationError: false,
        times: times,
        nextSlot: next.slot,
        nextTime: next.time,
        jumua: jumua,
      );

      _scheduleRollover(next.time);
    } catch (e, st) {
      talker.handle(e, st, 'Failed to compute prayer times');
      state = state.copyWith(isLoading: false, hasLocationError: true);
    }
  }

  /// Schedules a one-shot timer to recompute the next prayer the instant the
  /// current one elapses, so the countdown rolls over in real time without a
  /// manual refresh. A 1s buffer guards against firing a hair early.
  void _scheduleRollover(DateTime nextTime) {
    _rolloverTimer?.cancel();

    final delay = nextTime.difference(DateTime.now()) + const Duration(seconds: 1);
    if (delay.isNegative) {
      // Target already passed (e.g. stale data) — recompute immediately.
      unawaited(_recompute());
      return;
    }

    _rolloverTimer = Timer(delay, () {
      if (!mounted) return;
      unawaited(_recompute());
    });
  }
}
