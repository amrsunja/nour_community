import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_services.dart';

import '../models/prayer_settings_model.dart';

final prayerSettingsLocalDataProvider = Provider(
  (ref) => PrayerSettingsLocalDatasource(
    services: ref.read(sqliteServicesProvider),
  ),
);

/// Reads/writes the prayer preferences from the singleton settings row
/// (`id = 1`), projecting the single [SQLiteConfig.prayerSettingsKey] column.
class PrayerSettingsLocalDatasource {
  final SQLiteServices services;

  PrayerSettingsLocalDatasource({required this.services});

  Future<PrayerSettingsModel> getSettings() async {
    await services.initDatabase();
    final db = services.db;

    final rows = await db.query(
      SQLiteConfig.settingsTableName,
      columns: [SQLiteConfig.prayerSettingsKey],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return PrayerSettingsModel.initial;
    return PrayerSettingsModel.fromColumn(
      rows.first[SQLiteConfig.prayerSettingsKey] as String?,
    );
  }

  Future<PrayerSettingsModel> save(PrayerSettingsModel settings) async {
    await services.initDatabase();
    final db = services.db;

    final value = settings.toColumn();

    final updated = await db.update(
      SQLiteConfig.settingsTableName,
      {SQLiteConfig.prayerSettingsKey: value},
      where: 'id = ?',
      whereArgs: [1],
    );

    if (updated == 0) {
      await db.insert(SQLiteConfig.settingsTableName, {
        'id': 1,
        SQLiteConfig.themeModeKey: 'system',
        SQLiteConfig.prayerSettingsKey: value,
      });
    }

    return getSettings();
  }
}
