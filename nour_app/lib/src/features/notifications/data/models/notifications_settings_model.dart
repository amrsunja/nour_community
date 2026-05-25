import 'package:equatable/equatable.dart';
import 'package:nour/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Local-notification preferences. Each of the five daily prayers owns its own
/// flag so the user can manage them independently from the prayer-times page,
/// while the onboarding flow flips them all at once.
class NotificationsSettingsModel extends Equatable {
  final bool fajrPrayer;
  final bool dhuhrPrayer;
  final bool asrPrayer;
  final bool maghribPrayer;
  final bool ishaPrayer;
  final bool morningAdhkar;
  final bool eveningAdhkar;
  final bool dailyAyah;

  const NotificationsSettingsModel({
    required this.fajrPrayer,
    required this.dhuhrPrayer,
    required this.asrPrayer,
    required this.maghribPrayer,
    required this.ishaPrayer,
    required this.morningAdhkar,
    required this.eveningAdhkar,
    required this.dailyAyah,
  });

  static const NotificationsSettingsModel initial = NotificationsSettingsModel(
    fajrPrayer: false,
    dhuhrPrayer: false,
    asrPrayer: false,
    maghribPrayer: false,
    ishaPrayer: false,
    morningAdhkar: false,
    eveningAdhkar: false,
    dailyAyah: false,
  );

  /// Whether the given prayer slot has its notification enabled.
  bool prayerFor(PrayerSlot slot) {
    switch (slot) {
      case PrayerSlot.fajr:
        return fajrPrayer;
      case PrayerSlot.dhuhr:
        return dhuhrPrayer;
      case PrayerSlot.asr:
        return asrPrayer;
      case PrayerSlot.maghrib:
        return maghribPrayer;
      case PrayerSlot.isha:
        return ishaPrayer;
    }
  }

  /// True when every prayer notification is enabled.
  bool get allPrayers =>
      fajrPrayer && dhuhrPrayer && asrPrayer && maghribPrayer && ishaPrayer;

  /// True when at least one prayer notification is enabled.
  bool get anyPrayer =>
      fajrPrayer || dhuhrPrayer || asrPrayer || maghribPrayer || ishaPrayer;

  factory NotificationsSettingsModel.fromJson(Json json) {
    bool read(String key) {
      final v = json[key];
      if (v is bool) return v;
      if (v is int) return v == 1;
      return false;
    }

    return NotificationsSettingsModel(
      fajrPrayer: read(SQLiteConfig.notifPrayerFajrKey),
      dhuhrPrayer: read(SQLiteConfig.notifPrayerDhuhrKey),
      asrPrayer: read(SQLiteConfig.notifPrayerAsrKey),
      maghribPrayer: read(SQLiteConfig.notifPrayerMaghribKey),
      ishaPrayer: read(SQLiteConfig.notifPrayerIshaKey),
      morningAdhkar: read(SQLiteConfig.notifMorningAdhkarKey),
      eveningAdhkar: read(SQLiteConfig.notifEveningAdhkarKey),
      dailyAyah: read(SQLiteConfig.notifDailyAyahKey),
    );
  }

  Json toJson() => {
        SQLiteConfig.notifPrayerFajrKey: fajrPrayer ? 1 : 0,
        SQLiteConfig.notifPrayerDhuhrKey: dhuhrPrayer ? 1 : 0,
        SQLiteConfig.notifPrayerAsrKey: asrPrayer ? 1 : 0,
        SQLiteConfig.notifPrayerMaghribKey: maghribPrayer ? 1 : 0,
        SQLiteConfig.notifPrayerIshaKey: ishaPrayer ? 1 : 0,
        SQLiteConfig.notifMorningAdhkarKey: morningAdhkar ? 1 : 0,
        SQLiteConfig.notifEveningAdhkarKey: eveningAdhkar ? 1 : 0,
        SQLiteConfig.notifDailyAyahKey: dailyAyah ? 1 : 0,
      };

  NotificationsSettingsModel copyWith({
    bool? fajrPrayer,
    bool? dhuhrPrayer,
    bool? asrPrayer,
    bool? maghribPrayer,
    bool? ishaPrayer,
    bool? morningAdhkar,
    bool? eveningAdhkar,
    bool? dailyAyah,
  }) {
    return NotificationsSettingsModel(
      fajrPrayer: fajrPrayer ?? this.fajrPrayer,
      dhuhrPrayer: dhuhrPrayer ?? this.dhuhrPrayer,
      asrPrayer: asrPrayer ?? this.asrPrayer,
      maghribPrayer: maghribPrayer ?? this.maghribPrayer,
      ishaPrayer: ishaPrayer ?? this.ishaPrayer,
      morningAdhkar: morningAdhkar ?? this.morningAdhkar,
      eveningAdhkar: eveningAdhkar ?? this.eveningAdhkar,
      dailyAyah: dailyAyah ?? this.dailyAyah,
    );
  }

  /// Returns a copy with a single prayer slot's flag set to [value].
  NotificationsSettingsModel withPrayer(PrayerSlot slot, bool value) {
    switch (slot) {
      case PrayerSlot.fajr:
        return copyWith(fajrPrayer: value);
      case PrayerSlot.dhuhr:
        return copyWith(dhuhrPrayer: value);
      case PrayerSlot.asr:
        return copyWith(asrPrayer: value);
      case PrayerSlot.maghrib:
        return copyWith(maghribPrayer: value);
      case PrayerSlot.isha:
        return copyWith(ishaPrayer: value);
    }
  }

  /// Returns a copy with every prayer flag set to [value].
  NotificationsSettingsModel withAllPrayers(bool value) {
    return copyWith(
      fajrPrayer: value,
      dhuhrPrayer: value,
      asrPrayer: value,
      maghribPrayer: value,
      ishaPrayer: value,
    );
  }

  @override
  List<Object?> get props => [
        fajrPrayer,
        dhuhrPrayer,
        asrPrayer,
        maghribPrayer,
        ishaPrayer,
        morningAdhkar,
        eveningAdhkar,
        dailyAyah,
      ];
}
