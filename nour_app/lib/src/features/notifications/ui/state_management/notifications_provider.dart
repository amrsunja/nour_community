import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/notifications/notifications_services.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/notifications_settings_model.dart';
import '../../data/notifications_repo.dart';
import 'notifications_state.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsPresenter, NotificationsState>((ref) {
  return NotificationsPresenter(
    repo: ref.read(notificationsRepoProvider),
    appEvents: ref.read(appEventProvider),
    notifications: ref.read(notificationsServicesProvider),
  );
});

class NotificationsPresenter extends Presenter<NotificationsState> {
  final NotificationsRepo repo;
  final AppEvents appEvents;
  final NotificationsServices notifications;

  // Localized copy lives in arb files; using literals here as placeholders
  // matching the rest of the codebase until the keys are added.
  static const _prayerTitles = {
    PrayerSlot.fajr: 'Fajr',
    PrayerSlot.dhuhr: 'Dhuhr',
    PrayerSlot.asr: 'Asr',
    PrayerSlot.maghrib: 'Maghrib',
    PrayerSlot.isha: 'Isha',
  };

  NotificationsPresenter({
    required this.repo,
    required this.appEvents,
    required this.notifications,
  }) : super(NotificationsState.initial);

  Future<void> initSettings() async {
    final response = await repo.getSettings();
    response.when(
      (settings) => state = state.copyWith(settings: settings),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }

  Future<bool> setPrayers(bool enable) async {
    final ok = await _runUpdate(() => repo.setPrayers(enable));
    if (!ok) return false;

    if (enable) {
      await _schedulePrayers();
    } else {
      await notifications.cancelRange(
        NotificationIds.prayersBase,
        NotificationIds.prayersEnd,
      );
    }
    return true;
  }

  Future<bool> setMorningAdhkar(bool enable) async {
    final ok = await _runUpdate(() => repo.setMorningAdhkar(enable));
    if (!ok) return false;

    if (enable) {
      await _scheduleAdhkar(
        baseId: NotificationIds.morningAdhkarBase,
        title: 'Morning Adhkar',
        body: 'Time for your morning adhkar.',
        offsetMinutes: 30,
        anchor: _AdhkarAnchor.afterFajr,
      );
    } else {
      await notifications.cancelRange(
        NotificationIds.morningAdhkarBase,
        NotificationIds.morningAdhkarEnd,
      );
    }
    return true;
  }

  Future<bool> setEveningAdhkar(bool enable) async {
    final ok = await _runUpdate(() => repo.setEveningAdhkar(enable));
    if (!ok) return false;

    if (enable) {
      await _scheduleAdhkar(
        baseId: NotificationIds.eveningAdhkarBase,
        title: 'Evening Adhkar',
        body: 'Time for your evening adhkar.',
        offsetMinutes: 30,
        anchor: _AdhkarAnchor.afterMaghrib,
      );
    } else {
      await notifications.cancelRange(
        NotificationIds.eveningAdhkarBase,
        NotificationIds.eveningAdhkarEnd,
      );
    }
    return true;
  }

  Future<bool> setDailyAyah(bool enable) async {
    final ok = await _runUpdate(() => repo.setDailyAyah(enable));
    if (!ok) return false;

    if (enable) {
      await notifications.scheduleDailyAt(
        id: NotificationIds.dailyAyah,
        title: 'Daily Ayah',
        body: 'A new ayah is waiting for you.',
        hour: 19,
        minute: 0,
      );
    } else {
      await notifications.removeScheduledNotifications(
        NotificationIds.dailyAyah,
      );
    }
    return true;
  }

  /// Re-build all schedules from the persisted settings. Call on app start
  /// (after `NotificationsServices.initialize`) and whenever location changes.
  Future<void> rescheduleAll() async {
    final s = state.settings;
    await notifications.cancelRange(
      NotificationIds.prayersBase,
      NotificationIds.prayersEnd,
    );
    await notifications.cancelRange(
      NotificationIds.morningAdhkarBase,
      NotificationIds.morningAdhkarEnd,
    );
    await notifications.cancelRange(
      NotificationIds.eveningAdhkarBase,
      NotificationIds.eveningAdhkarEnd,
    );

    if (s.prayers) await _schedulePrayers();
    if (s.morningAdhkar) {
      await _scheduleAdhkar(
        baseId: NotificationIds.morningAdhkarBase,
        title: 'Morning Adhkar',
        body: 'Time for your morning adhkar.',
        offsetMinutes: 30,
        anchor: _AdhkarAnchor.afterFajr,
      );
    }
    if (s.eveningAdhkar) {
      await _scheduleAdhkar(
        baseId: NotificationIds.eveningAdhkarBase,
        title: 'Evening Adhkar',
        body: 'Time for your evening adhkar.',
        offsetMinutes: 30,
        anchor: _AdhkarAnchor.afterMaghrib,
      );
    }
    if (s.dailyAyah) {
      await notifications.scheduleDailyAt(
        id: NotificationIds.dailyAyah,
        title: 'Daily Ayah',
        body: 'A new ayah is waiting for you.',
        hour: 19,
        minute: 0,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Internal scheduling
  // ---------------------------------------------------------------------------

  Future<void> _schedulePrayers() async {
    try {
      await notifications.initialize();
      final week = await IslamicTools.getUpcomingPrayerTimes(
        days: NotificationIds.prayersDaysAhead,
      );

      for (int day = 0; day < week.length; day++) {
        final times = week[day];
        for (final slot in PrayerSlot.values) {
          final when = tz.TZDateTime.from(times.forSlot(slot), tz.local);
          final id =
              NotificationIds.prayersBase + (day * 5) + slot.index;
          await notifications.scheduleAt(
            id: id,
            title: _prayerTitles[slot]!,
            body: 'It is time for ${_prayerTitles[slot]} prayer.',
            when: when,
          );
        }
      }
    } catch (e, st) {
      talker.handle(e, st, 'Failed to schedule prayer notifications');
      appEvents.send(
        const ShowErrorEvent(
          null,
          defaultMessage: 'Could not schedule prayer notifications.',
        ),
      );
    }
  }

  Future<void> _scheduleAdhkar({
    required int baseId,
    required String title,
    required String body,
    required int offsetMinutes,
    required _AdhkarAnchor anchor,
  }) async {
    try {
      await notifications.initialize();
      final week = await IslamicTools.getUpcomingPrayerTimes(
        days: NotificationIds.prayersDaysAhead,
      );

      for (int day = 0; day < week.length; day++) {
        final times = week[day];
        final anchorTime = anchor == _AdhkarAnchor.afterFajr
            ? times.fajr
            : times.maghrib;
        final scheduled = tz.TZDateTime.from(anchorTime, tz.local)
            .add(Duration(minutes: offsetMinutes));
        await notifications.scheduleAt(
          id: baseId + day,
          title: title,
          body: body,
          when: scheduled,
        );
      }
    } catch (e, st) {
      talker.handle(e, st, 'Failed to schedule adhkar notifications');
      appEvents.send(
        const ShowErrorEvent(
          null,
          defaultMessage: 'Could not schedule adhkar notifications.',
        ),
      );
    }
  }

  Future<bool> _runUpdate(
    Future<SuccessOrError<NotificationsSettingsModel>> Function() action,
  ) async {
    state = state.copyWith(isLoading: true);
    final response = await action();
    return response.when(
      (settings) {
        state = state.copyWith(isLoading: false, settings: settings);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }
}

enum _AdhkarAnchor { afterFajr, afterMaghrib }
