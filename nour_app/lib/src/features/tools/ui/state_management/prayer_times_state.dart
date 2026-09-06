import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';

import '../../data/models/prayer_settings_model.dart';

/// Where today's times come from (§9): computed locally (adhan_dart) or the
/// principal mosque's published schedule.
enum PrayerSource { computed, mosque }

/// Immutable prayer-times screen state (hand-written, no codegen).
class PrayerTimesState extends Equatable {
  final bool isLoading;
  final bool hasLocationError;
  final PrayerSettingsModel settings;

  /// Source of [times]; [mosqueName] is set when [source] == mosque.
  final PrayerSource source;
  final String? mosqueName;
  final int? mosqueId;

  /// Iqama offsets shown as "+N" (mosque values when source == mosque).
  final Map<PrayerSlot, int> offsets;

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
    this.source = PrayerSource.computed,
    this.mosqueName,
    this.mosqueId,
    this.offsets = PrayerSettingsModel.displayOffsets,
    this.times,
    this.nextSlot,
    this.nextTime,
    this.jumua,
  });

  /// Sunrise (Chourouk) time.
  DateTime? get chourouk => times?.sunrise;

  int offsetFor(PrayerSlot slot) => offsets[slot] ?? 0;

  PrayerTimesState copyWith({
    bool? isLoading,
    bool? hasLocationError,
    PrayerSettingsModel? settings,
    PrayerSource? source,
    String? mosqueName,
    int? mosqueId,
    Map<PrayerSlot, int>? offsets,
    DailyPrayerTimes? times,
    PrayerSlot? nextSlot,
    DateTime? nextTime,
    DateTime? jumua,
    bool clearMosque = false,
  }) {
    return PrayerTimesState(
      isLoading: isLoading ?? this.isLoading,
      hasLocationError: hasLocationError ?? this.hasLocationError,
      settings: settings ?? this.settings,
      source: clearMosque ? PrayerSource.computed : (source ?? this.source),
      mosqueName: clearMosque ? null : (mosqueName ?? this.mosqueName),
      mosqueId: clearMosque ? null : (mosqueId ?? this.mosqueId),
      offsets: clearMosque ? PrayerSettingsModel.displayOffsets : (offsets ?? this.offsets),
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
        source,
        mosqueName,
        mosqueId,
        offsets,
        times,
        nextSlot,
        nextTime,
        jumua,
      ];
}
