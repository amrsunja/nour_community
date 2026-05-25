import 'package:hijri/hijri_calendar.dart';

/// A resolved Hijri date paired with its Gregorian equivalent (date-only).
class HijriDate {
  final int year;
  final int month; // 1..12
  final int day; // 1..30
  final DateTime gregorian;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.gregorian,
  });

  bool isSameDay(HijriDate other) =>
      year == other.year && month == other.month && day == other.day;
}

/// One cell of the month grid (includes leading/trailing days from the
/// adjacent months so the grid is weekday-aligned).
class HijriDayCell {
  final HijriDate hijri;
  final bool inMonth;
  final bool isToday;
  final bool isWhiteDay; // Ayyam al-Beed: 13, 14, 15.

  const HijriDayCell({
    required this.hijri,
    required this.inMonth,
    required this.isToday,
    required this.isWhiteDay,
  });

  DateTime get gregorian => hijri.gregorian;
}

/// A weekday-aligned view of a single Hijri month.
class HijriMonthView {
  final int year;
  final int month;
  final int daysInMonth;
  final DateTime firstDayGregorian;
  final List<HijriDayCell> cells;

  const HijriMonthView({
    required this.year,
    required this.month,
    required this.daysInMonth,
    required this.firstDayGregorian,
    required this.cells,
  });
}

/// A notable Islamic date expressed in the Hijri calendar.
class IslamicEvent {
  final String id;
  final int month;
  final int day;

  const IslamicEvent(this.id, this.month, this.day);
}

/// A concrete upcoming occurrence of an [IslamicEvent].
class IslamicEventOccurrence {
  final IslamicEvent event;
  final DateTime gregorian;
  final HijriDate hijri;
  final int daysUntil;

  const IslamicEventOccurrence({
    required this.event,
    required this.gregorian,
    required this.hijri,
    required this.daysUntil,
  });
}

/// Hijri calendar helper built on the `hijri` package.
///
/// All conversions go through the reliable Gregorian → Hijri direction
/// ([HijriCalendar.fromDate]); month boundaries and event dates are derived by
/// walking days (one Hijri day == one Gregorian day), so the only upstream
/// dependency is the `hijri` package's date conversion.
class HijriTool {
  const HijriTool._();

  static HijriDate _toHijri(DateTime g) {
    final dateOnly = DateTime(g.year, g.month, g.day);
    final h = HijriCalendar.fromDate(dateOnly);
    return HijriDate(
      year: h.hYear,
      month: h.hMonth,
      day: h.hDay,
      gregorian: dateOnly,
    );
  }

  static HijriDate today() => _toHijri(DateTime.now());

  static HijriDate fromGregorian(DateTime date) => _toHijri(date);

  static bool isWhiteDay(int hijriDay) =>
      hijriDay == 13 || hijriDay == 14 || hijriDay == 15;

  static (int year, int month) previousMonth(int year, int month) =>
      month == 1 ? (year - 1, 12) : (year, month - 1);

  static (int year, int month) nextMonth(int year, int month) =>
      month == 12 ? (year + 1, 1) : (year, month + 1);

  /// Gregorian date of Hijri day 1 for the given month. Estimates the offset
  /// (~29.53 days/month) from today, then refines day-by-day.
  static DateTime _gregorianForHijriDay1(int year, int month) {
    DateTime g = DateTime.now();
    g = DateTime(g.year, g.month, g.day);
    HijriDate h = _toHijri(g);

    final monthDiff = (year - h.year) * 12 + (month - h.month);
    g = g.add(Duration(days: (monthDiff * 2953 / 100).round()));
    h = _toHijri(g);

    final targetSerial = year * 12 + month;
    int guard = 0;
    while ((h.year != year || h.month != month) && guard < 120) {
      final cmp = (h.year * 12 + h.month).compareTo(targetSerial);
      g = g.add(Duration(days: cmp > 0 ? -1 : 1));
      h = _toHijri(g);
      guard++;
    }

    // Walk back to the first day of the target month.
    guard = 0;
    while (h.day > 1 && guard < 40) {
      g = g.subtract(const Duration(days: 1));
      h = _toHijri(g);
      guard++;
    }
    return g;
  }

  static int _daysInHijriMonth(int year, int month, DateTime day1Gregorian) {
    int count = 0;
    DateTime g = day1Gregorian;
    HijriDate h = _toHijri(g);
    while (h.year == year && h.month == month && count < 31) {
      count++;
      g = g.add(const Duration(days: 1));
      h = _toHijri(g);
    }
    return count;
  }

  /// Builds a weekday-aligned grid for [year]/[month].
  ///
  /// [firstWeekday] uses `DateTime` weekday constants (defaults to Sunday).
  static HijriMonthView monthView(
    int year,
    int month, {
    int firstWeekday = DateTime.sunday,
  }) {
    final day1 = _gregorianForHijriDay1(year, month);
    final daysInMonth = _daysInHijriMonth(year, month, day1);
    final todayH = today();

    // Number of leading cells (days of the previous month) before day 1.
    final firstIndex = firstWeekday % 7; // Sunday=0, Monday=1, ... Saturday=6.
    final day1Index = day1.weekday % 7;
    final leading = (day1Index - firstIndex + 7) % 7;

    final start = day1.subtract(Duration(days: leading));
    final totalCells = (((leading + daysInMonth) + 6) ~/ 7) * 7;

    final cells = <HijriDayCell>[];
    for (int i = 0; i < totalCells; i++) {
      final g = start.add(Duration(days: i));
      final h = _toHijri(g);
      final inMonth = h.year == year && h.month == month;
      cells.add(
        HijriDayCell(
          hijri: h,
          inMonth: inMonth,
          isToday: h.isSameDay(todayH),
          isWhiteDay: inMonth && isWhiteDay(h.day),
        ),
      );
    }

    return HijriMonthView(
      year: year,
      month: month,
      daysInMonth: daysInMonth,
      firstDayGregorian: day1,
      cells: cells,
    );
  }

  /// Notable Islamic dates, sorted within the Hijri year.
  static const List<IslamicEvent> events = [
    IslamicEvent('islamic_new_year', 1, 1),
    IslamicEvent('ashura', 1, 10),
    IslamicEvent('mawlid', 3, 12),
    IslamicEvent('isra_miraj', 7, 27),
    IslamicEvent('ramadan_begins', 9, 1),
    IslamicEvent('laylat_al_qadr', 9, 27),
    IslamicEvent('eid_al_fitr', 10, 1),
    IslamicEvent('dhul_hijjah_begins', 12, 1),
    IslamicEvent('day_of_arafah', 12, 9),
    IslamicEvent('eid_al_adha', 12, 10),
  ];

  /// Soonest [max] upcoming events from [from] (defaults to today),
  /// searched within a [horizonDays] window (one Hijri year ≈ 354 days).
  static List<IslamicEventOccurrence> upcomingEvents({
    int max = 5,
    DateTime? from,
    int horizonDays = 400,
  }) {
    final base = from ?? DateTime.now();
    final start = DateTime(base.year, base.month, base.day);
    final found = <String, IslamicEventOccurrence>{};

    DateTime g = start;
    for (int i = 0; i <= horizonDays && found.length < events.length; i++) {
      final h = _toHijri(g);
      for (final e in events) {
        if (!found.containsKey(e.id) && h.month == e.month && h.day == e.day) {
          found[e.id] = IslamicEventOccurrence(
            event: e,
            gregorian: g,
            hijri: h,
            daysUntil: i,
          );
        }
      }
      g = g.add(const Duration(days: 1));
    }

    final list = found.values.toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return list.take(max).toList();
  }
}
