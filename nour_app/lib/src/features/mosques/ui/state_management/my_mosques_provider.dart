import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/datasources/mosque_catalog_remote_datasource.dart';
import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_prayer_day_model.dart';
import '../../data/mosque_repo.dart';

/// Worshipper's principal / secondary mosque + the principal's prayer days
/// (today .. +7) used by the prayer-times override (§9).
class MyMosquesState extends Equatable {
  final bool isLoading;
  final bool loaded;
  final MosqueModel? principal;
  final MosqueModel? secondary;
  final MyMosquePrayerDays? prayerDays;

  const MyMosquesState({
    this.isLoading = false,
    this.loaded = false,
    this.principal,
    this.secondary,
    this.prayerDays,
  });

  bool get hasPrincipal => principal != null;

  bool isMine(int mosqueId) => principal?.id == mosqueId || secondary?.id == mosqueId;

  /// Effective mosque schedule for [date] (mosque timezone day), or null →
  /// caller falls back to the computed times.
  MosquePrayerDayModel? effectiveDayFor(DateTime date) {
    final pd = prayerDays;
    if (pd == null) return null;
    return pd.days[DateTime(date.year, date.month, date.day)];
  }

  MyMosquesState copyWith({
    bool? isLoading,
    bool? loaded,
    MosqueModel? principal,
    MosqueModel? secondary,
    MyMosquePrayerDays? prayerDays,
    bool clear = false,
  }) =>
      MyMosquesState(
        isLoading: isLoading ?? this.isLoading,
        loaded: loaded ?? this.loaded,
        principal: clear ? null : (principal ?? this.principal),
        secondary: clear ? null : (secondary ?? this.secondary),
        prayerDays: clear ? null : (prayerDays ?? this.prayerDays),
      );

  @override
  List<Object?> get props => [isLoading, loaded, principal, secondary, prayerDays?.mosqueId, prayerDays?.days.length, prayerDays?.days];
}

final myMosquesProvider = StateNotifierProvider<MyMosquesPresenter, MyMosquesState>((ref) {
  return MyMosquesPresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider));
});

class MyMosquesPresenter extends Presenter<MyMosquesState> {
  final MosqueRepo repo;
  final AppEvents appEvents;
  DateTime? _lastLoad;

  MyMosquesPresenter({required this.repo, required this.appEvents}) : super(const MyMosquesState());

  /// Loads both mosques and the principal's prayer days. Cheap to call again
  /// (skips when refreshed < 10 min ago unless [force]).
  Future<void> init({bool force = false}) async {
    if (!force && _lastLoad != null && DateTime.now().difference(_lastLoad!) < const Duration(minutes: 10) && state.loaded) return;
    // Yield before the first state write so a synchronous caller (e.g. a
    // widget lifecycle) can never mutate this provider during a build.
    await Future<void>.delayed(Duration.zero);
    state = state.copyWith(isLoading: true);
    final res = await repo.getUserMosques();
    await res.when(
      (map) async {
        final principal = map[1];
        final secondary = map[2];
        MyMosquePrayerDays? days;
        if (principal != null) {
          final d = await repo.getMyMosquePrayerDays(days: 8);
          days = d.when((v) => v, (_) => null);
        }
        state = MyMosquesState(isLoading: false, loaded: true, principal: principal, secondary: secondary, prayerDays: days);
        _lastLoad = DateTime.now();
      },
      (error) async {
        state = state.copyWith(isLoading: false, loaded: true);
      },
    );
  }

  Future<void> refresh() => init(force: true);

  /// Saves the sheet selection (§7.4 "My mosques").
  Future<bool> save({int? principal, int? secondary}) async {
    state = state.copyWith(isLoading: true);
    final res = await repo.setUserMosques(principal: principal, secondary: secondary);
    return res.when(
      (_) async {
        await init(force: true);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// "Add to my mosques": principal if none, else secondary, else replace secondary.
  Future<bool> add(int mosqueId) async {
    if (state.principal == null) return save(principal: mosqueId, secondary: state.secondary?.id);
    if (state.principal!.id == mosqueId) return true;
    return save(principal: state.principal!.id, secondary: mosqueId);
  }

  Future<bool> remove(int mosqueId) async {
    final p = state.principal?.id == mosqueId ? null : state.principal?.id;
    final s = state.secondary?.id == mosqueId ? null : state.secondary?.id;
    // Promote the secondary when the principal is removed.
    return save(principal: p ?? s, secondary: p == null ? null : s);
  }

  void clear() {
    _lastLoad = null;
    state = const MyMosquesState();
  }
}
