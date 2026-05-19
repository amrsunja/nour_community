import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../geolocator/geolocator_tools.dart';

enum PrayerSlot { fajr, dhuhr, asr, maghrib, isha }

class DailyPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  DateTime forSlot(PrayerSlot slot) {
    switch (slot) {
      case PrayerSlot.fajr:
        return fajr;
      case PrayerSlot.dhuhr:
        return dhuhr;
      case PrayerSlot.asr:
        return asr;
      case PrayerSlot.maghrib:
        return maghrib;
      case PrayerSlot.isha:
        return isha;
    }
  }
}

class IslamicTools {
  static bool _tzReady = false;

  /// Lazy timezone init — safe to call multiple times. Mirrors the work
  /// `NotificationsServices.initialize()` does so this tool also works
  /// when called before (or independently of) that service.
  static Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _tzReady = true;
  }

  /// Resolve `PrayerTimes` for [date] (defaults to today) at the device location.
  /// Returned `DateTime`s are in the local timezone (`tz.local`).
  static Future<DailyPrayerTimes> getPrayerTimesForDate({
    DateTime? date,
    Position? position,
  }) async {
    await _ensureTimezone();

    final pos = position ?? await GeolocatorTools.currentOrCachedPosition();
    final target = date ?? DateTime.now();

    final coords = Coordinates(pos.latitude, pos.longitude);
    final params = CalculationMethodParameters.muslimWorldLeague()
      ..madhab = Madhab.shafi;

    // adhan_dart expects a date "for that day" — strip time but keep local zone.
    final dayDate = tz.TZDateTime(
      tz.local,
      target.year,
      target.month,
      target.day,
    );

    final pt = PrayerTimes(
      coordinates: coords,
      date: dayDate,
      calculationParameters: params,
      precision: true,
    );

    DateTime toLocal(DateTime utc) => tz.TZDateTime.from(utc, tz.local);

    return DailyPrayerTimes(
      fajr: toLocal(pt.fajr),
      sunrise: toLocal(pt.sunrise),
      dhuhr: toLocal(pt.dhuhr),
      asr: toLocal(pt.asr),
      maghrib: toLocal(pt.maghrib),
      isha: toLocal(pt.isha),
    );
  }

  /// Returns prayer times for the next [days] days (including today).
  static Future<List<DailyPrayerTimes>> getUpcomingPrayerTimes({
    int days = 7,
    Position? position,
  }) async {
    await _ensureTimezone();

    final pos = position ?? await GeolocatorTools.currentOrCachedPosition();
    final today = DateTime.now();
    return [
      for (int i = 0; i < days; i++)
        await getPrayerTimesForDate(
          date: today.add(Duration(days: i)),
          position: pos,
        ),
    ];
  }
}
