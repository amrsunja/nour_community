import 'package:equatable/equatable.dart';

import 'package:nour/src/core/utils/typedefs.dart';

/// Time window applied to the profile statistics query.
enum StatRange {
  all,
  week,
  today;

  /// Lower bound passed to `fn_user_statistics(p_from)`. `null` = all time.
  /// `today` is anchored to the start of the device's local day; `week` covers
  /// the trailing 7 days.
  DateTime? get from {
    final now = DateTime.now();
    return switch (this) {
      StatRange.all => null,
      StatRange.week => now.subtract(const Duration(days: 7)),
      StatRange.today => DateTime(now.year, now.month, now.day),
    };
  }
}

/// Aggregated profile counters for a [StatRange]. Mirrors the single row
/// returned by the `fn_user_statistics` RPC.
class UserStatistics extends Equatable {
  final int earnedAjr;
  final int dhikrCompleted;
  final int completedDeeds;
  final int activeDays;
  final int ayahsRead;
  final int hadithsRead;
  final int duasRecited;

  const UserStatistics({
    required this.earnedAjr,
    required this.dhikrCompleted,
    required this.completedDeeds,
    required this.activeDays,
    required this.ayahsRead,
    required this.hadithsRead,
    required this.duasRecited,
  });

  const UserStatistics.empty()
      : earnedAjr = 0,
        dhikrCompleted = 0,
        completedDeeds = 0,
        activeDays = 0,
        ayahsRead = 0,
        hadithsRead = 0,
        duasRecited = 0;

  factory UserStatistics.fromJson(Json json) => UserStatistics(
        earnedAjr: (json['earned_ajr'] as num?)?.toInt() ?? 0,
        dhikrCompleted: (json['dhikr_completed'] as num?)?.toInt() ?? 0,
        completedDeeds: (json['completed_deeds'] as num?)?.toInt() ?? 0,
        activeDays: (json['active_days'] as num?)?.toInt() ?? 0,
        ayahsRead: (json['ayahs_read'] as num?)?.toInt() ?? 0,
        hadithsRead: (json['hadiths_read'] as num?)?.toInt() ?? 0,
        duasRecited: (json['duas_recited'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [
        earnedAjr,
        dhikrCompleted,
        completedDeeds,
        activeDays,
        ayahsRead,
        hadithsRead,
        duasRecited,
      ];
}
