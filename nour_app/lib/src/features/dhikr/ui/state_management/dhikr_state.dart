import 'package:equatable/equatable.dart';

import '../../data/models/dhikr_model.dart';
import '../../data/models/dhikr_progress_model.dart';

/// Hand-written immutable state (no freezed codegen) to keep the feature
/// buildable without running build_runner.
class DhikrState extends Equatable {
  final bool isLoading;
  final List<DhikrModel> dhikrs;

  /// Today's progress keyed by `dhikrId`.
  final Map<int, DhikrProgressModel> progressByDhikrId;

  /// Total ajr earned today per `dhikrId` (from `ajr_log`). Reset-safe.
  final Map<int, int> earnedAjrByDhikrId;

  const DhikrState({
    this.isLoading = false,
    this.dhikrs = const [],
    this.progressByDhikrId = const {},
    this.earnedAjrByDhikrId = const {},
  });

  /// Dhikrs started today but not yet completed → "Continue dhikr" block.
  List<DhikrModel> get inProgress => dhikrs.where((d) {
    final p = progressByDhikrId[d.id];
    return p != null && p.currentCount > 0 && !p.isCompleted;
  }).toList();

  /// Dhikrs started today but not yet completed → "Continue dhikr" block.
  List<DhikrModel> get notInProgress {
    final filtered = dhikrs.where((d) {
      final p = progressByDhikrId[d.id];
      return p == null || p.currentCount == 0 || p.isCompleted;
    }).toList();

    return filtered;
  }

  int currentCountOf(int dhikrId) => progressByDhikrId[dhikrId]?.currentCount ?? 0;

  /// Total ajr already earned today for [dhikrId] (reset-safe, from ajr_log).
  int earnedAjrTodayOf(int dhikrId) => earnedAjrByDhikrId[dhikrId] ?? 0;

  bool isCompleted(int dhikrId) => progressByDhikrId[dhikrId]?.isCompleted ?? false;

  DhikrState copyWith({
    bool? isLoading,
    List<DhikrModel>? dhikrs,
    Map<int, DhikrProgressModel>? progressByDhikrId,
    Map<int, int>? earnedAjrByDhikrId,
  }) => DhikrState(
    isLoading: isLoading ?? this.isLoading,
    dhikrs: dhikrs ?? this.dhikrs,
    progressByDhikrId: progressByDhikrId ?? this.progressByDhikrId,
    earnedAjrByDhikrId: earnedAjrByDhikrId ?? this.earnedAjrByDhikrId,
  );

  @override
  List<Object?> get props =>
      [isLoading, dhikrs, progressByDhikrId, earnedAjrByDhikrId];
}
