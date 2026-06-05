import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/notifications/notifications_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nour/src/core/utils/enums/calculation_method_type.dart';
import 'package:nour/src/core/utils/geolocator/geolocator_tools.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/tools/data/prayer_settings_repo.dart';
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
    ref: ref,
  );
});

/// Single owner of all local-notification scheduling. The prayer-times page and
/// the onboarding flow drive it through the public `set*` methods; it always
/// schedules against the calculation method persisted by the prayer-times
/// feature so the fired notifications match the times shown to the user.
class NotificationsPresenter extends Presenter<NotificationsState> {
  final NotificationsRepo repo;
  final AppEvents appEvents;
  final NotificationsServices notifications;
  final Ref ref;

  NotificationsPresenter({
    required this.repo,
    required this.appEvents,
    required this.notifications,
    required this.ref,
  }) : super(NotificationsState.initial);

  AppLocale get _l10n => ref.read(l10nProvider);

  /// Calculation method currently selected on the prayer-times page (persisted
  /// in the settings DB). Falls back to the default when unavailable.
  Future<CalculationMethodType> _method() async {
    final response = await ref.read(prayerSettingsRepoProvider).getSettings();
    return response.when(
      (settings) => settings.method,
      (_) => CalculationMethodType.defaultMethod,
    );
  }

  /// Resolve a location for scheduling without ever depending on a live GPS
  /// fix. Returns `null` when no location has ever been obtained/set — callers
  /// skip scheduling in that case instead of throwing.
  Future<Position?> _schedulingPosition() async {
    final pos = await GeolocatorTools.positionForScheduling();
    if (pos == null) {
      talker.info(
        'Skipping notification scheduling: no location available yet.',
      );
    }
    return pos;
  }

  Map<PrayerSlot, String> _prayerTitles() => {
        PrayerSlot.fajr: _l10n.notifications_prayer_fajr,
        PrayerSlot.dhuhr: _l10n.notifications_prayer_dhuhr,
        PrayerSlot.asr: _l10n.notifications_prayer_asr,
        PrayerSlot.maghrib: _l10n.notifications_prayer_maghrib,
        PrayerSlot.isha: _l10n.notifications_prayer_isha,
      };

  Future<void> initSettings() async {
    final response = await repo.getSettings();
    response.when(
      (settings) => state = state.copyWith(settings: settings),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }

  // ---------------------------------------------------------------------------
  // Public toggles
  // ---------------------------------------------------------------------------

  /// Enable/disable the notification for a single prayer. Reschedules the whole
  /// prayer range so it reflects the new enabled set.
  Future<bool> setPrayer(PrayerSlot slot, bool enable) async {
    final ok = await _runUpdate(() => repo.setPrayer(slot, enable));
    if (!ok) return false;
    await _schedulePrayers();
    return true;
  }

  /// Enable/disable every prayer at once (used by onboarding and the
  /// prayer-times page "all on/off" control).
  Future<bool> setAllPrayers(bool enable) async {
    final ok = await _runUpdate(() => repo.setAllPrayers(enable));
    if (!ok) return false;
    await _schedulePrayers();
    return true;
  }

  Future<bool> setMorningAdhkar(bool enable) async {
    final ok = await _runUpdate(() => repo.setMorningAdhkar(enable));
    if (!ok) return false;

    if (enable) {
      await _scheduleAdhkar(
        baseId: NotificationIds.morningAdhkarBase,
        title: _l10n.notifications_morning_adhkar_title,
        body: _l10n.notifications_morning_adhkar_body,
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
        title: _l10n.notifications_evening_adhkar_title,
        body: _l10n.notifications_evening_adhkar_body,
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
        title: _l10n.notifications_daily_ayah_title,
        body: _l10n.notifications_daily_ayah_body,
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

  /// Re-build all schedules from the persisted settings using the currently
  /// selected calculation method. Call on app start (after
  /// `NotificationsServices.initialize`), whenever the calculation method
  /// changes, and whenever location changes.
  Future<void> rescheduleAll() async {
    // Make sure we operate on the freshest persisted toggles.
    await initSettings();
    final s = state.settings;
    final method = await _method();

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

    if (s.anyPrayer) await _schedulePrayers(method: method);
    if (s.morningAdhkar) {
      await _scheduleAdhkar(
        baseId: NotificationIds.morningAdhkarBase,
        title: _l10n.notifications_morning_adhkar_title,
        body: _l10n.notifications_morning_adhkar_body,
        offsetMinutes: 30,
        anchor: _AdhkarAnchor.afterFajr,
        method: method,
      );
    }
    if (s.eveningAdhkar) {
      await _scheduleAdhkar(
        baseId: NotificationIds.eveningAdhkarBase,
        title: _l10n.notifications_evening_adhkar_title,
        body: _l10n.notifications_evening_adhkar_body,
        offsetMinutes: 30,
        anchor: _AdhkarAnchor.afterMaghrib,
        method: method,
      );
    }
    if (s.dailyAyah) {
      await notifications.scheduleDailyAt(
        id: NotificationIds.dailyAyah,
        title: _l10n.notifications_daily_ayah_title,
        body: _l10n.notifications_daily_ayah_body,
        hour: 19,
        minute: 0,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Internal scheduling
  // ---------------------------------------------------------------------------

  /// Cancels the prayer ID range then re-schedules exact-time notifications for
  /// the enabled prayers across the next [NotificationIds.prayersDaysAhead]
  /// days. [method] defaults to the persisted selection.
  Future<void> _schedulePrayers({CalculationMethodType? method}) async {
    try {
      await notifications.initialize();
      await notifications.cancelRange(
        NotificationIds.prayersBase,
        NotificationIds.prayersEnd,
      );

      final settings = state.settings;
      if (!settings.anyPrayer) return;

      final position = await _schedulingPosition();
      if (position == null) return;

      final resolvedMethod = method ?? await _method();
      final week = await IslamicTools.getUpcomingPrayerTimes(
        days: NotificationIds.prayersDaysAhead,
        position: position,
        method: resolvedMethod,
      );
      final titles = _prayerTitles();

      for (int day = 0; day < week.length; day++) {
        final times = week[day];
        for (final slot in PrayerSlot.values) {
          if (!settings.prayerFor(slot)) continue;
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

  Future<void> _scheduleAdhkar({
    required int baseId,
    required String title,
    required String body,
    required int offsetMinutes,
    required _AdhkarAnchor anchor,
    CalculationMethodType? method,
  }) async {
    try {
      await notifications.initialize();
      final position = await _schedulingPosition();
      if (position == null) return;

      final resolvedMethod = method ?? await _method();
      final week = await IslamicTools.getUpcomingPrayerTimes(
        days: NotificationIds.prayersDaysAhead,
        position: position,
        method: resolvedMethod,
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
        ShowErrorEvent(
          null,
          defaultMessage: _l10n.notifications_error_adhkar_schedule,
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
