import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/enums/calculation_method_type.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';

/// Persisted prayer-times preferences. Serialized to a single JSON column
/// (`prayer_settings`) to avoid a column-per-flag migration.
class PrayerSettingsModel extends Equatable {
  final CalculationMethodType method;

  /// Whether an exact-time notification is enabled for each prayer.
  final Map<PrayerSlot, bool> notify;

  const PrayerSettingsModel({
    required this.method,
    required this.notify,
  });

  /// Display-only iqama offsets (minutes) shown next to each time as "+N".
  /// Not user-editable for now; mirrors the reference design.
  static const Map<PrayerSlot, int> displayOffsets = {
    PrayerSlot.fajr: 10,
    PrayerSlot.dhuhr: 10,
    PrayerSlot.asr: 10,
    PrayerSlot.maghrib: 0,
    PrayerSlot.isha: 10,
  };

  int offsetFor(PrayerSlot slot) => displayOffsets[slot] ?? 0;

  bool notifyFor(PrayerSlot slot) {
    print(notify);
    print(slot);
    return notify[slot] ?? false;
  }

  static const Map<PrayerSlot, bool> _defaultNotify = {
    PrayerSlot.fajr: true,
    PrayerSlot.dhuhr: false,
    PrayerSlot.asr: false,
    PrayerSlot.maghrib: false,
    PrayerSlot.isha: false,
  };

  static const PrayerSettingsModel initial = PrayerSettingsModel(
    method: CalculationMethodType.defaultMethod,
    notify: _defaultNotify,
  );

  factory PrayerSettingsModel.fromColumn(String? raw) {
    if (raw == null || raw.isEmpty) return initial;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final method = CalculationMethodType.fromId(json['method'] as String?);
      final notifyRaw = (json['notify'] as Map?)?.cast<String, dynamic>() ?? {};
      final notify = <PrayerSlot, bool>{
        for (final slot in PrayerSlot.values)
          slot: notifyRaw[slot.name] is bool
              ? notifyRaw[slot.name] as bool
              : (_defaultNotify[slot] ?? false),
      };
      return PrayerSettingsModel(method: method, notify: notify);
    } catch (_) {
      return initial;
    }
  }

  String toColumn() => jsonEncode({
        'method': method.id,
        'notify': {
          for (final entry in notify.entries) entry.key.name: entry.value,
        },
      });

  PrayerSettingsModel copyWith({
    CalculationMethodType? method,
    Map<PrayerSlot, bool>? notify,
  }) {
    return PrayerSettingsModel(
      method: method ?? this.method,
      notify: notify ?? this.notify,
    );
  }

  PrayerSettingsModel withNotify(PrayerSlot slot, bool value) {
    final next = Map<PrayerSlot, bool>.from(notify)..[slot] = value;
    return copyWith(notify: next);
  }

  @override
  List<Object?> get props => [method, notify];
}
