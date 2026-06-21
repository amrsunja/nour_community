import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';

import '../../data/models/prayer_settings_model.dart';

/// Immutable prayer-times screen state (hand-written, no codegen).
class PrayerTimesState extends Equatable {
  final bool isLoading;
  final bool hasLocationError;
  final PrayerSettingsModel settings;

  /// Today's resolved prayer times (null until loaded / on error).
  final DailyPrayerTimes? times;

  /// The next upcoming prayer and its absolute time.
  final PrayerSlot? nextSlot;
  final DateTime? nextTime;

  /// Jumu'a (Friday) time derived from the upcoming Friday's Dhuhr.
  final DateTime? jumua;

  const PrayerTimesState({
    this.isLoading = false,
    this.hasLocationError = false,
    this.settings = PrayerSettingsModel.initial,
    this.times,
    this.nextSlot,
    this.nextTime,
    this.jumua,
  });

  /// Sunrise (Chourouk) time.
  DateTime? get chourouk => times?.sunrise;

  PrayerTimesState copyWith({
    bool? isLoading,
    bool? hasLocationError,
    PrayerSettingsModel? settings,
    DailyPrayerTimes? times,
    PrayerSlot? nextSlot,
    DateTime? nextTime,
    DateTime? jumua,
  }) {
    return PrayerTimesState(
      isLoading: isLoading ?? this.isLoading,
      hasLocationError: hasLocationError ?? this.hasLocationError,
      settings: settings ?? this.settings,
      times: times ?? this.times,
      nextSlot: nextSlot ?? this.nextSlot,
      nextTime: nextTime ?? this.nextTime,
      jumua: jumua ?? this.jumua,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        hasLocationError,
        settings,
        times,
        nextSlot,
        nextTime,
        jumua,
      ];
}
