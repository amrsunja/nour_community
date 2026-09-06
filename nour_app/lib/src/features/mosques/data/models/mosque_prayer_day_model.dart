import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:timezone/timezone.dart' as tz;


/// One day of a mosque's prayer schedule (`mosque_prayer_times` row merged with
/// the day's overrides). Times are wall-clock in the mosque's timezone.
class MosquePrayerDayModel extends Equatable {
  final int mosqueId;
  final DateTime day;
  final String timezone;
  final Map<PrayerSlot, TimeOfDay> scheduled;
  final Map<PrayerSlot, TimeOfDay> overrides;
  final Map<PrayerSlot, int> iqamaOffsets;
  final TimeOfDay? sunrise;
  final TimeOfDay? jumua;
  final TimeOfDay? jumua2;
  final TimeOfDay? jumua3;
  final String source;

  const MosquePrayerDayModel({
    required this.mosqueId,
    required this.day,
    required this.timezone,
    required this.scheduled,
    this.overrides = const {},
    this.iqamaOffsets = const {},
    this.sunrise,
    this.jumua,
    this.jumua2,
    this.jumua3,
    this.source = 'manual',
  });

  static const defaultOffsets = {
    PrayerSlot.fajr: 10,
    PrayerSlot.dhuhr: 10,
    PrayerSlot.asr: 10,
    PrayerSlot.maghrib: 0,
    PrayerSlot.isha: 10,
  };

  /// A day the admin hasn't filled yet (00:00 everywhere).
  factory MosquePrayerDayModel.empty({required int mosqueId, required DateTime day, required String timezone}) =>
      MosquePrayerDayModel(
        mosqueId: mosqueId,
        day: DateTime(day.year, day.month, day.day),
        timezone: timezone,
        scheduled: const {},
        iqamaOffsets: defaultOffsets,
      );

  bool get isEmpty => scheduled.length < 5;

  TimeOfDay? effective(PrayerSlot slot) => overrides[slot] ?? scheduled[slot];
  bool isOverridden(PrayerSlot slot) => overrides.containsKey(slot);
  int offsetFor(PrayerSlot slot) => iqamaOffsets[slot] ?? defaultOffsets[slot] ?? 0;

  static TimeOfDay? parseTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String formatTime(TimeOfDay? t) =>
      t == null ? '--:--' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String toDb(TimeOfDay t) => '${formatTime(t)}:00';

  static String slotDb(PrayerSlot s) => s.name;
  static PrayerSlot? slotFromDb(String? s) {
    for (final e in PrayerSlot.values) {
      if (e.name == s) return e;
    }
    return null;
  }

  /// Builds from a `mosque_prayer_times` row (+ optional overrides map
  /// `{slot: 'HH:MM:SS'}`).
  factory MosquePrayerDayModel.fromRow(
    Json row, {
    required String timezone,
    Map<String, dynamic>? overrides,
    int? mosqueId,
    DateTime? day,
  }) {
    final scheduled = <PrayerSlot, TimeOfDay>{};
    for (final s in PrayerSlot.values) {
      final t = parseTime(row[s.name]?.toString());
      if (t != null) scheduled[s] = t;
    }
    final ov = <PrayerSlot, TimeOfDay>{};
    (overrides ?? const {}).forEach((k, v) {
      final s = slotFromDb(k);
      final t = parseTime(v?.toString());
      if (s != null && t != null) ov[s] = t;
    });
    final offsets = <PrayerSlot, int>{};
    final rawOffsets = row['iqama_offsets'];
    if (rawOffsets is Map) {
      rawOffsets.forEach((k, v) {
        final s = slotFromDb(k.toString());
        if (s != null) offsets[s] = (v as num?)?.toInt() ?? 0;
      });
    }
    return MosquePrayerDayModel(
      mosqueId: mosqueId ?? row['mosque_id'] as int,
      day: day ?? DateTime.parse(row['day'] as String),
      timezone: timezone,
      scheduled: scheduled,
      overrides: ov,
      iqamaOffsets: offsets.isEmpty ? defaultOffsets : offsets,
      sunrise: parseTime(row['sunrise']?.toString()),
      jumua: parseTime(row['jumua']?.toString()),
      jumua2: parseTime(row['jumua_2']?.toString()),
      jumua3: parseTime(row['jumua_3']?.toString()),
      source: row['source']?.toString() ?? 'manual',
    );
  }

  Json toUpsertJson() => {
        'mosque_id': mosqueId,
        'day': '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
        for (final s in PrayerSlot.values) s.name: toDb(scheduled[s] ?? const TimeOfDay(hour: 0, minute: 0)),
        'sunrise': sunrise == null ? null : toDb(sunrise!),
        'jumua': jumua == null ? null : toDb(jumua!),
        'jumua_2': jumua2 == null ? null : toDb(jumua2!),
        'jumua_3': jumua3 == null ? null : toDb(jumua3!),
        'iqama_offsets': {for (final s in PrayerSlot.values) s.name: offsetFor(s)},
        'source': 'manual',
      };

  /// Absolute instant of a wall-clock time in the mosque timezone.
  DateTime instant(TimeOfDay t) {
    tz.Location loc;
    try {
      loc = tz.getLocation(timezone);
    } catch (_) {
      loc = tz.local;
    }
    return tz.TZDateTime(loc, day.year, day.month, day.day, t.hour, t.minute);
  }

  /// Adapter to the existing computed type; [fallback] fills missing slots
  /// (e.g. sunrise) with the adhan_dart values.
  DailyPrayerTimes toDailyPrayerTimes({DailyPrayerTimes? fallback}) {
    DateTime pick(PrayerSlot s, DateTime? fb) {
      final t = effective(s);
      return t == null ? (fb ?? DateTime.now()) : instant(t);
    }

    return DailyPrayerTimes(
      fajr: pick(PrayerSlot.fajr, fallback?.fajr),
      sunrise: sunrise != null ? instant(sunrise!) : (fallback?.sunrise ?? pick(PrayerSlot.fajr, null).add(const Duration(hours: 1, minutes: 20))),
      dhuhr: pick(PrayerSlot.dhuhr, fallback?.dhuhr),
      asr: pick(PrayerSlot.asr, fallback?.asr),
      maghrib: pick(PrayerSlot.maghrib, fallback?.maghrib),
      isha: pick(PrayerSlot.isha, fallback?.isha),
    );
  }

  MosquePrayerDayModel copyWith({
    Map<PrayerSlot, TimeOfDay>? scheduled,
    Map<PrayerSlot, TimeOfDay>? overrides,
    Map<PrayerSlot, int>? iqamaOffsets,
    TimeOfDay? sunrise,
    TimeOfDay? jumua,
    TimeOfDay? jumua2,
    TimeOfDay? jumua3,
  }) =>
      MosquePrayerDayModel(
        mosqueId: mosqueId,
        day: day,
        timezone: timezone,
        scheduled: scheduled ?? this.scheduled,
        overrides: overrides ?? this.overrides,
        iqamaOffsets: iqamaOffsets ?? this.iqamaOffsets,
        sunrise: sunrise ?? this.sunrise,
        jumua: jumua ?? this.jumua,
        jumua2: jumua2 ?? this.jumua2,
        jumua3: jumua3 ?? this.jumua3,
        source: source,
      );

  @override
  List<Object?> get props => [mosqueId, day, timezone, scheduled, overrides, iqamaOffsets, sunrise, jumua, jumua2, jumua3, source];
}

/// Row of `mosque_prayer_overrides`.
class MosquePrayerOverride extends Equatable {
  final int id;
  final int mosqueId;
  final DateTime day;
  final PrayerSlot slot;
  final TimeOfDay time;
  final String? reason;

  const MosquePrayerOverride({
    required this.id,
    required this.mosqueId,
    required this.day,
    required this.slot,
    required this.time,
    this.reason,
  });

  factory MosquePrayerOverride.fromJson(Json json) => MosquePrayerOverride(
        id: json['id'] as int,
        mosqueId: json['mosque_id'] as int,
        day: DateTime.parse(json['day'] as String),
        slot: MosquePrayerDayModel.slotFromDb(json['slot'] as String?) ?? PrayerSlot.fajr,
        time: MosquePrayerDayModel.parseTime(json['time']?.toString()) ?? const TimeOfDay(hour: 0, minute: 0),
        reason: json['reason'] as String?,
      );

  @override
  List<Object?> get props => [id, mosqueId, day, slot, time, reason];
}

