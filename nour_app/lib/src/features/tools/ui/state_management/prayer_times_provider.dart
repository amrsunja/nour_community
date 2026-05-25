import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/notifications/notifications_services.dart';
import 'package:nour/src/core/utils/enums/calculation_method_type.dart';
import 'package:nour/src/core/utils/geolocator/geolocator_tools.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/prayer_settings_model.dart';
import '../../data/prayer_settings_repo.dart';
import 'prayer_times_state.dart';

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesPresenter, PrayerTimesState>((ref) {
  return PrayerTimesPresenter(
    repo: ref.read(prayerSettingsRepoProvider),
    appEvents: ref.read(appEventProvider),
    notifications: ref.read(notificationsServicesProvider),
    ref: ref,
  );
});

class PrayerTimesPresenter extends Presenter<PrayerTimesState> {
  final PrayerSettingsRepo repo;
  final AppEvents appEvents;
  final NotificationsServices notifications;
  final Ref ref;

  PrayerTimesPresenter({
    required this.repo,
    required this.appEvents,
    required this.notifications,
    required this.ref,
  }) : super(const PrayerTimesState());

  AppLocale get _l10n => ref.read(l10nProvider);

  Map<PrayerSlot, String> _prayerTitles() => {
        PrayerSlot.fajr: _l10n.notifications_prayer_fajr,
        PrayerSlot.dhuhr: _l10n.notifications_prayer_dhuhr,
        PrayerSlot.asr: _l10n.notifications_prayer_asr,
        PrayerSlot.maghrib: _l10n.notifications_prayer_maghrib,
        PrayerSlot.isha: _l10n.notifications_prayer_isha,
      };

  Future<void> init() async {
    state = state.copyWith(isLoading: true);

    final response = await repo.getSettings();
    response.when(
      (settings) => state = state.copyWith(settings: settings),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    await _recompute();
  }

  Future<void> changeMethod(CalculationMethodType method) async {
    if (method == state.settings.method) return;
    final next = state.settings.copyWith(method: method);
    await _persist(next);
    await _recompute();
    await _reschedule();
  }

  Future<void> toggleNotify(PrayerSlot slot, bool enable) async {
    final next = state.settings.withNotify(slot, enable);
    await _persist(next);
    await _reschedule();
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
    } catch (e, st) {
      talker.handle(e, st, 'Failed to compute prayer times');
      state = state.copyWith(isLoading: false, hasLocationError: true);
    }
  }

  /// Re-schedules exact-time notifications for the enabled prayers across the
  /// next [NotificationIds.prayersDaysAhead] days, reusing the prayer ID range.
  Future<void> _reschedule() async {
    try {
      await notifications.initialize();
      await notifications.cancelRange(
        NotificationIds.prayersBase,
        NotificationIds.prayersEnd,
      );

      final enabled = state.settings.notify;
      if (!enabled.values.any((v) => v)) return;

      final week = await IslamicTools.getUpcomingPrayerTimes(
        days: NotificationIds.prayersDaysAhead,
        method: state.settings.method,
      );
      final titles = _prayerTitles();

      for (int day = 0; day < week.length; day++) {
        final times = week[day];
        for (final slot in PrayerSlot.values) {
          if (enabled[slot] != true) continue;
          final when = tz.TZDateTime.from(times.forSlot(slot), tz.local);
          final id = NotificationIds.prayersBase + (day * 5) + slot.index;
          final name = titles[slot]!;
          await notifications.scheduleAt(
            id: id,
            title: name,
            body: _l10n.notifications_prayer_body(name),
            when: when,
          );
        }
      }
    } catch (e, st) {
      talker.handle(e, st, 'Failed to schedule prayer notifications');
      appEvents.send(
        ShowErrorEvent(
          null,
          defaultMessage: _l10n.notifications_error_prayers_schedule,
        ),
      );
    }
  }
}
