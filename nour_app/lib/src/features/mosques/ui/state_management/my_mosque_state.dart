import 'package:equatable/equatable.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/data/models/mosque_model.dart';
import 'package:nour/src/features/mosques/data/models/mosque_prayer_day_model.dart';

/// The mosque managed by the current (mosque) account.
class MyMosqueState extends Equatable {
  final bool isLoading;
  final bool loaded;
  final MosqueModel? mosque;
  final MosqueAdminRole? role;

  /// The mosque's own published schedule for today .. +7, overrides merged.
  /// Only the days the admin actually filled are present — a missing day means
  /// "no prayer times published", and nothing is notified for it.
  final Map<DateTime, MosquePrayerDayModel> prayerDays;

  const MyMosqueState({
    this.isLoading = false,
    this.loaded = false,
    this.mosque,
    this.role,
    this.prayerDays = const {},
  });

  bool get isApproved => mosque?.status == MosqueStatus.approved;

  /// True as soon as at least one upcoming day carries a full schedule.
  bool get hasPublishedPrayerTimes =>
      prayerDays.values.any((d) => !d.isEmpty);

  /// The mosque's schedule for [date], or null when that day was never filled.
  MosquePrayerDayModel? prayerDayFor(DateTime date) {
    final d = prayerDays[DateTime(date.year, date.month, date.day)];
    return (d == null || d.isEmpty) ? null : d;
  }

  MyMosqueState copyWith({
    bool? isLoading,
    bool? loaded,
    MosqueModel? mosque,
    MosqueAdminRole? role,
    Map<DateTime, MosquePrayerDayModel>? prayerDays,
    bool clearMosque = false,
  }) {
    return MyMosqueState(
      isLoading: isLoading ?? this.isLoading,
      loaded: loaded ?? this.loaded,
      mosque: clearMosque ? null : (mosque ?? this.mosque),
      role: clearMosque ? null : (role ?? this.role),
      prayerDays: clearMosque ? const {} : (prayerDays ?? this.prayerDays),
    );
  }

  @override
  List<Object?> get props => [isLoading, loaded, mosque, role, prayerDays];
}
