import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/geolocator/geolocator_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import '../../data/models/notifications_settings_model.dart';
import '../../data/notifications_repo.dart';
import 'notifications_state.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsPresenter, NotificationsState>((ref) {
  return NotificationsPresenter(
    repo: ref.read(notificationsRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class NotificationsPresenter extends Presenter<NotificationsState> {
  final NotificationsRepo repo;
  final AppEvents appEvents;

  NotificationsPresenter({
    required this.repo,
    required this.appEvents,
  }) : super(NotificationsState.initial);

  Future<void> initSettings() async {
    final response = await repo.getSettings();
    response.when(
      (settings) => state = state.copyWith(settings: settings),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
  }

  Future<bool> setPrayers(bool enable) {
    return _runUpdate(() => repo.setPrayers(enable));
  }

  Future<bool> setMorningAdhkar(bool enable) =>
      _runUpdate(() => repo.setMorningAdhkar(enable));

  Future<bool> setEveningAdhkar(bool enable) =>
      _runUpdate(() => repo.setEveningAdhkar(enable));

  Future<bool> setDailyAyah(bool enable) =>
      _runUpdate(() => repo.setDailyAyah(enable));

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
  
  Future<void> scheduleMorningAdhkarNotifs() async {
    // Schedule 7 AM Notification
  }

  Future<void> removeMorningAdhkarNotifs() async {
    // remove all Scheduled evening adhkars notifs at  7:00 AM
  }

  Future<void> scheduleEveningAdhkarNotifs() async {
    // Schedule 6:30 PM Notification
  }

  Future<void> removeEveningAdhkarNotifs() async {
    // remove all Scheduled evening adhkars notifs at  7 AM
  }

  Future<void> scheduleDailyAyahNotifs() async {
    // Schedule 7 PM Notification
  }

  Future<void> removeDailyAyahNotifs() async {
    // remove all Scheduled evening adhkars notifs at  7 PM
  }
}
