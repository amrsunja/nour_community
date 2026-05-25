import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';

import '../models/notifications_settings_model.dart';

final notificationsLocalDataProvider = Provider(
  (ref) => NotificationsLocalDatasource(
    services: ref.read(sqliteServicesProvider),
  ),
);

class NotificationsLocalDatasource {
  final SQLiteServices services;

  NotificationsLocalDatasource({required this.services});

  static const List<String> _columns = [
    SQLiteConfig.notifPrayerFajrKey,
    SQLiteConfig.notifPrayerDhuhrKey,
    SQLiteConfig.notifPrayerAsrKey,
    SQLiteConfig.notifPrayerMaghribKey,
    SQLiteConfig.notifPrayerIshaKey,
    SQLiteConfig.notifMorningAdhkarKey,
    SQLiteConfig.notifEveningAdhkarKey,
    SQLiteConfig.notifDailyAyahKey,
  ];

  static String _prayerColumn(PrayerSlot slot) {
    switch (slot) {
      case PrayerSlot.fajr:
        return SQLiteConfig.notifPrayerFajrKey;
      case PrayerSlot.dhuhr:
        return SQLiteConfig.notifPrayerDhuhrKey;
      case PrayerSlot.asr:
        return SQLiteConfig.notifPrayerAsrKey;
      case PrayerSlot.maghrib:
        return SQLiteConfig.notifPrayerMaghribKey;
      case PrayerSlot.isha:
        return SQLiteConfig.notifPrayerIshaKey;
    }
  }

  /// Reads the singleton settings row and projects only the notification
  /// columns. Falls back to [NotificationsSettingsModel.initial] if no row
  /// exists yet.
  Future<NotificationsSettingsModel> getSettings() async {
    await services.initDatabase();
    final db = services.db;

    final rows = await db.query(
      SQLiteConfig.settingsTableName,
      columns: _columns,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return NotificationsSettingsModel.initial;
    return NotificationsSettingsModel.fromJson(rows.first);
  }

  Future<NotificationsSettingsModel> setPrayer(PrayerSlot slot, bool enable) =>
      _updateColumns({_prayerColumn(slot): enable ? 1 : 0});

  Future<NotificationsSettingsModel> setAllPrayers(bool enable) {
    final value = enable ? 1 : 0;
    return _updateColumns({
      SQLiteConfig.notifPrayerFajrKey: value,
      SQLiteConfig.notifPrayerDhuhrKey: value,
      SQLiteConfig.notifPrayerAsrKey: value,
      SQLiteConfig.notifPrayerMaghribKey: value,
      SQLiteConfig.notifPrayerIshaKey: value,
    });
  }

  Future<NotificationsSettingsModel> setMorningAdhkar(bool enable) =>
      _updateColumns({SQLiteConfig.notifMorningAdhkarKey: enable ? 1 : 0});

  Future<NotificationsSettingsModel> setEveningAdhkar(bool enable) =>
      _updateColumns({SQLiteConfig.notifEveningAdhkarKey: enable ? 1 : 0});

  Future<NotificationsSettingsModel> setDailyAyah(bool enable) =>
      _updateColumns({SQLiteConfig.notifDailyAyahKey: enable ? 1 : 0});

  Future<NotificationsSettingsModel> _updateColumns(
    Map<String, Object?> values,
  ) async {
    await services.initDatabase();
    final db = services.db;

    // Upsert the singleton settings row (id = 1).
    final updated = await db.update(
      SQLiteConfig.settingsTableName,
      values,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (updated == 0) {
      await db.insert(SQLiteConfig.settingsTableName, {
        'id': 1,
        SQLiteConfig.themeModeKey: 'system',
        ...values,
      });
    }

    return getSettings();
  }
}
