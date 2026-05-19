import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_services.dart';

import '../models/notifications_settings_model.dart';

final notificationsLocalDataProvider = Provider(
  (ref) => NotificationsLocalDatasource(
    services: ref.read(sqliteServicesProvider),
  ),
);

class NotificationsLocalDatasource {
  final SQLiteServices services;

  NotificationsLocalDatasource({required this.services});

  /// Reads the singleton settings row and projects only the notification
  /// columns. Falls back to [NotificationsSettingsModel.initial] if no row
  /// exists yet.
  Future<NotificationsSettingsModel> getSettings() async {
    await services.initDatabase();
    final db = services.db;

    final rows = await db.query(
      SQLiteConfig.settingsTableName,
      columns: [
        SQLiteConfig.notifPrayersKey,
        SQLiteConfig.notifMorningAdhkarKey,
        SQLiteConfig.notifEveningAdhkarKey,
        SQLiteConfig.notifDailyAyahKey,
      ],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return NotificationsSettingsModel.initial;
    return NotificationsSettingsModel.fromJson(rows.first);
  }

  Future<NotificationsSettingsModel> setPrayers(bool enable) =>
      _updateColumn(SQLiteConfig.notifPrayersKey, enable);

  Future<NotificationsSettingsModel> setMorningAdhkar(bool enable) =>
      _updateColumn(SQLiteConfig.notifMorningAdhkarKey, enable);

  Future<NotificationsSettingsModel> setEveningAdhkar(bool enable) =>
      _updateColumn(SQLiteConfig.notifEveningAdhkarKey, enable);

  Future<NotificationsSettingsModel> setDailyAyah(bool enable) =>
      _updateColumn(SQLiteConfig.notifDailyAyahKey, enable);

  Future<NotificationsSettingsModel> _updateColumn(
    String column,
    bool enable,
  ) async {
    await services.initDatabase();
    final db = services.db;

    final value = enable ? 1 : 0;

    // Upsert the singleton settings row (id = 1).
    final updated = await db.update(
      SQLiteConfig.settingsTableName,
      {column: value},
      where: 'id = ?',
      whereArgs: [1],
    );

    if (updated == 0) {
      await db.insert(SQLiteConfig.settingsTableName, {
        'id': 1,
        SQLiteConfig.themeModeKey: 'system',
        column: value,
      });
    }

    return getSettings();
  }
}
