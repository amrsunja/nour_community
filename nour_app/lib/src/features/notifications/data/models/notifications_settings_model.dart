import 'package:equatable/equatable.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class NotificationsSettingsModel extends Equatable {
  final bool prayers;
  final bool morningAdhkar;
  final bool eveningAdhkar;
  final bool dailyAyah;

  const NotificationsSettingsModel({
    required this.prayers,
    required this.morningAdhkar,
    required this.eveningAdhkar,
    required this.dailyAyah,
  });

  static const NotificationsSettingsModel initial = NotificationsSettingsModel(
    prayers: false,
    morningAdhkar: false,
    eveningAdhkar: false,
    dailyAyah: false,
  );

  factory NotificationsSettingsModel.fromJson(Json json) {
    bool read(String key) {
      final v = json[key];
      if (v is bool) return v;
      if (v is int) return v == 1;
      return false;
    }

    return NotificationsSettingsModel(
      prayers: read(SQLiteConfig.notifPrayersKey),
      morningAdhkar: read(SQLiteConfig.notifMorningAdhkarKey),
      eveningAdhkar: read(SQLiteConfig.notifEveningAdhkarKey),
      dailyAyah: read(SQLiteConfig.notifDailyAyahKey),
    );
  }

  Json toJson() => {
        SQLiteConfig.notifPrayersKey: prayers ? 1 : 0,
        SQLiteConfig.notifMorningAdhkarKey: morningAdhkar ? 1 : 0,
        SQLiteConfig.notifEveningAdhkarKey: eveningAdhkar ? 1 : 0,
        SQLiteConfig.notifDailyAyahKey: dailyAyah ? 1 : 0,
      };

  NotificationsSettingsModel copyWith({
    bool? prayers,
    bool? morningAdhkar,
    bool? eveningAdhkar,
    bool? dailyAyah,
  }) {
    return NotificationsSettingsModel(
      prayers: prayers ?? this.prayers,
      morningAdhkar: morningAdhkar ?? this.morningAdhkar,
      eveningAdhkar: eveningAdhkar ?? this.eveningAdhkar,
      dailyAyah: dailyAyah ?? this.dailyAyah,
    );
  }

  @override
  List<Object?> get props => [prayers, morningAdhkar, eveningAdhkar, dailyAyah];
}
