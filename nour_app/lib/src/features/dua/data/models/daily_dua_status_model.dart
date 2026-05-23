import 'package:equatable/equatable.dart';

/// Server-side state of the Daily Dua quick action for the current user:
/// the all-time ajr earned from duas and whether today's daily dua is done.
class DailyDuaStatusModel extends Equatable {
  /// All-time ajr earned from duas (source = 'dua').
  final int totalAjr;

  /// Whether the user already completed today's daily dua (idempotency guard).
  final bool doneToday;

  const DailyDuaStatusModel({
    this.totalAjr = 0,
    this.doneToday = false,
  });

  static const empty = DailyDuaStatusModel();

  factory DailyDuaStatusModel.fromJson(Map<String, dynamic> json) =>
      DailyDuaStatusModel(
        totalAjr: (json['total_ajr'] as num?)?.toInt() ?? 0,
        doneToday: json['done_today'] as bool? ?? false,
      );

  DailyDuaStatusModel copyWith({int? totalAjr, bool? doneToday}) =>
      DailyDuaStatusModel(
        totalAjr: totalAjr ?? this.totalAjr,
        doneToday: doneToday ?? this.doneToday,
      );

  @override
  List<Object?> get props => [totalAjr, doneToday];
}
