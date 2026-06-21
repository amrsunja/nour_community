import 'package:equatable/equatable.dart';

import '../../data/models/dua_model.dart';
import '../../data/models/dua_progress_model.dart';

/// Hand-written immutable state (no freezed codegen) — same convention as the
/// quran / hadith features — so the feature builds without running build_runner.
class DuaState extends Equatable {
  /// True while the initial library / progress load is in flight.
  final bool isLoading;

  /// True if the initial load failed (drives the error state).
  final bool hasError;

  /// The full dua library (ordered by position then id).
  final List<DuaModel> library;

  /// The user's single reading-progress row.
  final DuaProgressModel? progress;

  /// Dua ids the current user has liked.
  final Set<int> likedDuas;

  // ── Daily Dua quick action ─────────────────────────────────────────────────

  final bool isLoadingDailyDua;

  /// All-time ajr the user has earned from duas.
  final int dailyDuaTotalAjr;

  /// Whether today's daily dua is already completed.
  final bool dailyDuaDoneToday;

  /// Ajr earnable by completing today's daily dua (0 once done).
  final int dailyDuaAjr;

  const DuaState({
    this.isLoading = false,
    this.hasError = false,
    this.library = const [],
    this.progress,
    this.likedDuas = const {},
    this.isLoadingDailyDua = false,
    this.dailyDuaTotalAjr = 0,
    this.dailyDuaDoneToday = false,
    this.dailyDuaAjr = 5,
  });

  bool get isEmpty => library.isEmpty;

  int get total => library.length;

  bool isDuaLiked(int duaId) => likedDuas.contains(duaId);

  /// 1-based position of [duaId] within the loaded library (0 if not found).
  int positionOf(int? duaId) {
    if (duaId == null) return 0;
    final i = library.indexWhere((d) => d.id == duaId);
    return i < 0 ? 0 : i + 1;
  }

  /// 1-based reading position resolved from the library order (0 = not started).
  int get currentPosition => positionOf(progress?.currentDuaId);

  bool get hasProgress =>
      progress?.currentDuaId != null && currentPosition > 0;

  /// Earnable ajr shown as "+N" while today's daily dua isn't done yet.
  int get dailyDuaEarnableAjr => dailyDuaDoneToday ? 0 : dailyDuaAjr;

  DuaState copyWith({
    bool? isLoading,
    bool? hasError,
    List<DuaModel>? library,
    DuaProgressModel? progress,
    Set<int>? likedDuas,
    bool? isLoadingDailyDua,
    int? dailyDuaTotalAjr,
    bool? dailyDuaDoneToday,
    int? dailyDuaAjr,
  }) =>
      DuaState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        library: library ?? this.library,
        progress: progress ?? this.progress,
        likedDuas: likedDuas ?? this.likedDuas,
        isLoadingDailyDua: isLoadingDailyDua ?? this.isLoadingDailyDua,
        dailyDuaTotalAjr: dailyDuaTotalAjr ?? this.dailyDuaTotalAjr,
        dailyDuaDoneToday: dailyDuaDoneToday ?? this.dailyDuaDoneToday,
        dailyDuaAjr: dailyDuaAjr ?? this.dailyDuaAjr,
      );

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        library,
        progress,
        likedDuas,
        isLoadingDailyDua,
        dailyDuaTotalAjr,
        dailyDuaDoneToday,
        dailyDuaAjr,
      ];
}
