import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/enums/calculation_method_type.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';

/// Persisted prayer-times preferences. Serialized to a single JSON column
/// (`prayer_settings`). Only the calculation method lives here now — per-prayer
/// notification toggles are owned by the notifications feature.
class PrayerSettingsModel extends Equatable {
  final CalculationMethodType method;

  const PrayerSettingsModel({
    required this.method,
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

  static const PrayerSettingsModel initial = PrayerSettingsModel(
    method: CalculationMethodType.defaultMethod,
  );

  factory PrayerSettingsModel.fromColumn(String? raw) {
    if (raw == null || raw.isEmpty) return initial;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final method = CalculationMethodType.fromId(json['method'] as String?);
      return PrayerSettingsModel(method: method);
    } catch (_) {
      return initial;
    }
  }

  String toColumn() => jsonEncode({'method': method.id});

  PrayerSettingsModel copyWith({
    CalculationMethodType? method,
  }) {
    return PrayerSettingsModel(
      method: method ?? this.method,
    );
  }

  @override
  List<Object?> get props => [method];
}
