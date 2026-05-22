import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Per-user, per-day progress for a single dhikr.
/// Mirrors `public.dhikr_progress`. `isCompleted` is owned by the DB trigger
/// (`fn_dhikr_progress_after_change`) — the client only writes `current_count`.
/// Earned ajr is NOT stored here; it lives in `ajr_log` (one row per cycle).
class DhikrProgressModel extends Equatable {
  final int dhikrId;
  final int currentCount;
  final bool isCompleted;
  final DateTime progressDate;

  const DhikrProgressModel({
    required this.dhikrId,
    required this.currentCount,
    required this.isCompleted,
    required this.progressDate,
  });

  factory DhikrProgressModel.fromJson(Json json) => DhikrProgressModel(
    dhikrId: json['dhikr_id'],
    currentCount: json['current_count'] ?? 0,
    isCompleted: json['is_completed'] ?? false,
    progressDate: DateTime.tryParse(json['progress_date'] ?? '') ?? DateTime.now(),
  );

  DhikrProgressModel copyWith({
    int? currentCount,
    bool? isCompleted,
  }) => DhikrProgressModel(
    dhikrId: dhikrId,
    currentCount: currentCount ?? this.currentCount,
    isCompleted: isCompleted ?? this.isCompleted,
    progressDate: progressDate,
  );

  @override
  List<Object?> get props => [dhikrId, currentCount, isCompleted, progressDate];
}
