import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/prayer_settings_local_datasource.dart';
import 'models/prayer_settings_model.dart';

final prayerSettingsRepoProvider = Provider(
  (ref) => PrayerSettingsRepo(
    localDatasource: ref.read(prayerSettingsLocalDataProvider),
  ),
);

class PrayerSettingsRepo {
  final PrayerSettingsLocalDatasource localDatasource;

  PrayerSettingsRepo({required this.localDatasource});

  Future<SuccessOrError<PrayerSettingsModel>> getSettings() {
    return Failure.exceptionsCatcher(() => localDatasource.getSettings());
  }

  Future<SuccessOrError<PrayerSettingsModel>> save(
    PrayerSettingsModel settings,
  ) {
    return Failure.exceptionsCatcher(() => localDatasource.save(settings));
  }
}
