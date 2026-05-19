import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasrouces/notifications_local_datasource.dart';
import 'models/notifications_settings_model.dart';

final notificationsRepoProvider = Provider(
  (ref) => NotificationsRepo(
    localDatasource: ref.read(notificationsLocalDataProvider),
  ),
);

class NotificationsRepo {
  final NotificationsLocalDatasource localDatasource;

  NotificationsRepo({required this.localDatasource});

  Future<SuccessOrError<NotificationsSettingsModel>> getSettings() async {
    return Failure.exceptionsCatcher(() => localDatasource.getSettings());
  }

  Future<SuccessOrError<NotificationsSettingsModel>> setPrayers(bool enable) {
    return Failure.exceptionsCatcher(() => localDatasource.setPrayers(enable));
  }

  Future<SuccessOrError<NotificationsSettingsModel>> setMorningAdhkar(
    bool enable,
  ) {
    return Failure.exceptionsCatcher(
      () => localDatasource.setMorningAdhkar(enable),
    );
  }

  Future<SuccessOrError<NotificationsSettingsModel>> setEveningAdhkar(
    bool enable,
  ) {
    return Failure.exceptionsCatcher(
      () => localDatasource.setEveningAdhkar(enable),
    );
  }

  Future<SuccessOrError<NotificationsSettingsModel>> setDailyAyah(bool enable) {
    return Failure.exceptionsCatcher(
      () => localDatasource.setDailyAyah(enable),
    );
  }
}
