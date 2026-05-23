import 'package:equatable/equatable.dart';

/// Server-side state of the Daily Ayah quick action for the current user:
/// the all-time ajr earned from ayahs and whether today's ayah is already done.
class DailyAyahStatusModel extends Equatable {
  /// All-time ajr earned from the Daily Ayah (source = 'ayah').
  final int totalAjr;

  /// Whether the user already completed today's ayah (idempotency guard).
  final bool doneToday;

  const DailyAyahStatusModel({
    this.totalAjr = 0,
    this.doneToday = false,
  });

  static const empty = DailyAyahStatusModel();

  factory DailyAyahStatusModel.fromJson(Map<String, dynamic> json) =>
      DailyAyahStatusModel(
        totalAjr: (json['total_ajr'] as num?)?.toInt() ?? 0,
        doneToday: json['done_today'] as bool? ?? false,
      );

  DailyAyahStatusModel copyWith({int? totalAjr, bool? doneToday}) =>
      DailyAyahStatusModel(
        totalAjr: totalAjr ?? this.totalAjr,
        doneToday: doneToday ?? this.doneToday,
      );

  @override
  List<Object?> get props => [totalAjr, doneToday];
}
