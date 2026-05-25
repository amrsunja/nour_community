import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../enums/calculation_method_type.dart';
import '../geolocator/geolocator_tools.dart';

enum PrayerSlot { fajr, dhuhr, asr, maghrib, isha }

/// A single prayer occurrence: which [slot] it is and the absolute [time]
/// (already in the local timezone). Used to resolve the "next prayer".
class PrayerOccurrence {
  final PrayerSlot slot;
  final DateTime time;

  const PrayerOccurrence({required this.slot, required this.time});
}

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
    CalculationMethodType method = CalculationMethodType.defaultMethod,
    Madhab? madhab,
  }) async {
    await _ensureTimezone();

    final pos = position ?? await GeolocatorTools.currentOrCachedPosition();
    final target = date ?? DateTime.now();

    final coords = Coordinates(pos.latitude, pos.longitude);
    final params = method.buildParameters()..madhab = madhab ?? Madhab.shafi;

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
    CalculationMethodType method = CalculationMethodType.defaultMethod,
    Madhab? madhab,
  }) async {
    await _ensureTimezone();

    final pos = position ?? await GeolocatorTools.currentOrCachedPosition();
    final today = DateTime.now();
    return [
      for (int i = 0; i < days; i++)
        await getPrayerTimesForDate(
          date: today.add(Duration(days: i)),
          position: pos,
          method: method,
          madhab: madhab,
        ),
    ];
  }

  /// The five canonical prayer slots in chronological order (Sunrise/Chourouk
  /// is intentionally excluded — it is not a prayer).
  static const List<PrayerSlot> orderedSlots = [
    PrayerSlot.fajr,
    PrayerSlot.dhuhr,
    PrayerSlot.asr,
    PrayerSlot.maghrib,
    PrayerSlot.isha,
  ];

  /// Resolves the next upcoming prayer relative to [from] (defaults to now),
  /// rolling over to tomorrow's Fajr when every prayer for today has passed.
  static Future<PrayerOccurrence> getNextPrayer({
    DateTime? from,
    Position? position,
    CalculationMethodType method = CalculationMethodType.defaultMethod,
    Madhab? madhab,
  }) async {
    final pos = position ?? await GeolocatorTools.currentOrCachedPosition();
    final now = from ?? DateTime.now();

    final days = await getUpcomingPrayerTimes(
      days: 2,
      position: pos,
      method: method,
      madhab: madhab,
    );

    for (final day in days) {
      for (final slot in orderedSlots) {
        final time = day.forSlot(slot);
        if (time.isAfter(now)) {
          return PrayerOccurrence(slot: slot, time: time);
        }
      }
    }

    // Extremely unlikely fallback: tomorrow's Fajr.
    return PrayerOccurrence(slot: PrayerSlot.fajr, time: days.last.fajr);
  }

  /// Jumu'a (Friday) congregation time. `adhan_dart` does not expose a
  /// dedicated Jumu'a time (it is mosque-specific), so we derive it from the
  /// Dhuhr time of the upcoming Friday (today's Dhuhr when today is Friday).
  static Future<DateTime> getJumuaTime({
    Position? position,
    CalculationMethodType method = CalculationMethodType.defaultMethod,
    Madhab? madhab,
  }) async {
    final pos = position ?? await GeolocatorTools.currentOrCachedPosition();
    final now = DateTime.now();
    // DateTime.friday == 5.
    final daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
    final friday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysUntilFriday));

    final times = await getPrayerTimesForDate(
      date: friday,
      position: pos,
      method: method,
      madhab: madhab,
    );
    return times.dhuhr;
  }
}
