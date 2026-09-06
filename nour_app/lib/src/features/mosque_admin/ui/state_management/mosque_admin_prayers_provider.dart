import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_prayer_day_model.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/mosque_profile_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

/// Admin prayer-schedule editor (Figma "Mosquée profile - Prayers" admin):
/// week strip, per-day rows, copy from another day, today's overrides.
class MosqueAdminPrayersState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final DateTime selectedDay;
  /// Filled days in the loaded window.
  final Map<DateTime, MosquePrayerDayModel> days;
  final List<MosquePrayerOverride> overrides;
  /// Pending (unsaved) edits of the selected day.
  final MosquePrayerDayModel? draft;

  const MosqueAdminPrayersState({
    this.isLoading = false,
    this.isSaving = false,
    required this.selectedDay,
    this.days = const {},
    this.overrides = const [],
    this.draft,
  });

  MosquePrayerDayModel? get selected => days[selectedDay];
  bool get isDirty => draft != null;

  List<MosquePrayerOverride> overridesFor(DateTime day) =>
      overrides.where((o) => o.day.year == day.year && o.day.month == day.month && o.day.day == day.day).toList();

  MosqueAdminPrayersState copyWith({
    bool? isLoading,
    bool? isSaving,
    DateTime? selectedDay,
    Map<DateTime, MosquePrayerDayModel>? days,
    List<MosquePrayerOverride>? overrides,
    MosquePrayerDayModel? draft,
    bool clearDraft = false,
  }) =>
      MosqueAdminPrayersState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        selectedDay: selectedDay ?? this.selectedDay,
        days: days ?? this.days,
        overrides: overrides ?? this.overrides,
        draft: clearDraft ? null : (draft ?? this.draft),
      );

  @override
  List<Object?> get props => [isLoading, isSaving, selectedDay, days, overrides, draft];
}

final mosqueAdminPrayersProvider =
    StateNotifierProvider.autoDispose<MosqueAdminPrayersPresenter, MosqueAdminPrayersState>((ref) {
  return MosqueAdminPrayersPresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider), ref: ref);
});

class MosqueAdminPrayersPresenter extends Presenter<MosqueAdminPrayersState> {
  final MosqueRepo repo;
  final AppEvents appEvents;
  final Ref ref;

  MosqueAdminPrayersPresenter({required this.repo, required this.appEvents, required this.ref})
      : super(MosqueAdminPrayersState(selectedDay: _today()));

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _d(DateTime d) => DateTime(d.year, d.month, d.day);

  int? get _mosqueId => ref.read(myMosqueProvider).mosque?.id;
  String get _tz => ref.read(myMosqueProvider).mosque?.timezone ?? 'Europe/Paris';

  /// Loads a window around the selected day (±6 weeks) + future overrides.
  Future<void> load({DateTime? around}) async {
    final id = _mosqueId;
    if (id == null) return;
    final center = _d(around ?? state.selectedDay);
    state = state.copyWith(isLoading: true);
    final from = center.subtract(const Duration(days: 42));
    final to = center.add(const Duration(days: 42));
    final results = await Future.wait([
      repo.getPrayerRange(id, from, to, timezone: _tz),
      repo.getOverrides(id, from: _today().subtract(const Duration(days: 1))),
    ]);
    (results[0] as dynamic).when(
      (map) => state = state.copyWith(days: {...state.days, ...(map as Map<DateTime, MosquePrayerDayModel>)}),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
    (results[1] as dynamic).when(
      (list) => state = state.copyWith(overrides: (list as List).cast<MosquePrayerOverride>()),
      (_) {},
    );
    state = state.copyWith(isLoading: false);
  }

  void selectDay(DateTime day) {
    final d = _d(day);
    state = state.copyWith(selectedDay: d, clearDraft: true);
    // Prefetch when leaving the loaded window.
    final loadedAround = state.days.keys.isEmpty ? null : state.days.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    if (loadedAround == null || d.difference(loadedAround).inDays.abs() > 30) load(around: d);
  }

  MosquePrayerDayModel _draftOrCurrent() {
    final id = _mosqueId!;
    return state.draft ?? state.selected ?? MosquePrayerDayModel.empty(mosqueId: id, day: state.selectedDay, timezone: _tz);
  }

  void setTime(PrayerSlot slot, TimeOfDay t) {
    final d = _draftOrCurrent();
    state = state.copyWith(draft: d.copyWith(scheduled: {...d.scheduled, slot: t}));
  }

  void setOffset(PrayerSlot slot, int minutes) {
    final d = _draftOrCurrent();
    state = state.copyWith(draft: d.copyWith(iqamaOffsets: {...d.iqamaOffsets, slot: minutes.clamp(0, 90)}));
  }

  void setSunrise(TimeOfDay t) => state = state.copyWith(draft: _draftOrCurrent().copyWith(sunrise: t));
  void setJumua(TimeOfDay t) => state = state.copyWith(draft: _draftOrCurrent().copyWith(jumua: t));

  void discard() => state = state.copyWith(clearDraft: true);

  Future<bool> save() async {
    final d = state.draft;
    if (d == null) return true;
    if (d.isEmpty) {
      appEvents.send(ShowErrorEvent(null, defaultMessage: 'Fill the 5 prayer times first.'));
      return false;
    }
    state = state.copyWith(isSaving: true);
    final res = await repo.upsertPrayerDay(d);
    return res.when((saved) {
      state = state.copyWith(isSaving: false, days: {...state.days, saved.day: saved}, clearDraft: true);
      _syncPublicToday(saved);
      return true;
    }, (error) {
      state = state.copyWith(isSaving: false);
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  /// Copy [from] to the selected day or a range. Returns the number of days written.
  Future<int?> copy({required DateTime from, required DateTime toStart, required DateTime toEnd}) async {
    final id = _mosqueId;
    if (id == null) return null;
    state = state.copyWith(isSaving: true);
    final res = await repo.copyPrayerTimes(mosqueId: id, from: from, toStart: toStart, toEnd: toEnd);
    return await res.when((n) async {
      state = state.copyWith(isSaving: false, clearDraft: true);
      await load(around: state.selectedDay);
      final t = state.days[_today()];
      if (t != null) _syncPublicToday(t);
      return n;
    }, (error) async {
      state = state.copyWith(isSaving: false);
      appEvents.send(ShowErrorEvent(error));
      return null;
    });
  }

  Future<bool> addOverride({required DateTime day, required PrayerSlot slot, required TimeOfDay time, String? reason}) async {
    final id = _mosqueId;
    if (id == null) return false;
    final res = await repo.upsertOverride(mosqueId: id, day: day, slot: slot, time: MosquePrayerDayModel.toDb(time), reason: reason);
    return res.when((o) {
      state = state.copyWith(overrides: [...state.overrides.where((x) => x.id != o.id), o]);
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  Future<bool> removeOverride(MosquePrayerOverride o) async {
    final res = await repo.deleteOverride(o.id);
    return res.when((_) {
      state = state.copyWith(overrides: state.overrides.where((x) => x.id != o.id).toList());
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  void _syncPublicToday(MosquePrayerDayModel d) {
    final id = _mosqueId;
    if (id == null) return;
    if (d.day == _today()) {
      final ov = {for (final o in state.overridesFor(d.day)) o.slot: o.time};
      ref.read(mosqueProfileProvider(id).notifier).setToday(d.copyWith(overrides: ov));
    }
  }
}
