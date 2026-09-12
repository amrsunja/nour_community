import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_prayer_day_model.dart';
import '../../data/mosque_repo.dart';
import 'my_mosque_state.dart';

final myMosqueProvider = StateNotifierProvider<MyMosquePresenter, MyMosqueState>((ref) {
  return MyMosquePresenter(
    repo: ref.read(mosqueRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

/// App-lifetime presenter for mosque accounts: loads the managed mosque and
/// watches its review status (pending → approved flips the admin shell in).
class MyMosquePresenter extends Presenter<MyMosqueState> {
  final MosqueRepo repo;
  final AppEvents appEvents;
  StreamSubscription<MosqueStatus>? _statusSub;

  MyMosquePresenter({required this.repo, required this.appEvents}) : super(const MyMosqueState());

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  /// Loads (or reloads) the caller's mosque. Returns true when the account
  /// manages a mosque.
  Future<bool> load({bool silent = false}) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.getMyMosque();
    return response.when(
      (my) async {
        if (my == null) {
          state = state.copyWith(isLoading: false, loaded: true, clearMosque: true);
          return false;
        }
        state = state.copyWith(isLoading: false, loaded: true, mosque: my.mosque, role: my.role);
        await loadPrayerDays();
        return true;
      },
      (error) async {
        state = state.copyWith(isLoading: false, loaded: true);
        if (!silent) appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Loads the mosque's own schedule for today .. +[days] (overrides merged).
  ///
  /// A mosque account has no `user_mosques` row, so `fn_my_mosque_prayer_days`
  /// (worshipper-side) never returns anything for it — read the range straight
  /// from `mosque_prayer_times` / `mosque_prayer_overrides` instead. Days the
  /// admin never filled are simply absent from the map, which is what makes
  /// "notify only when the mosque published its times" possible.
  Future<void> loadPrayerDays({int days = 8}) async {
    final mosque = state.mosque;
    if (mosque == null) return;
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(Duration(days: days - 1));

    final rangeRes = await repo.getPrayerRange(mosque.id, from, to, timezone: mosque.timezone);
    final rows = rangeRes.when((map) => map, (error) {
      talker.warning('my mosque prayer days: $error');
      return <DateTime, MosquePrayerDayModel>{};
    });

    final overridesRes = await repo.getOverrides(mosque.id, from: from);
    final overrides = overridesRes.when((list) => list, (_) => const <MosquePrayerOverride>[]);

    final merged = <DateTime, MosquePrayerDayModel>{};
    rows.forEach((day, model) {
      final key = DateTime(day.year, day.month, day.day);
      final ov = {
        for (final o in overrides)
          if (DateTime(o.day.year, o.day.month, o.day.day) == key) o.slot: o.time,
      };
      merged[key] = ov.isEmpty ? model : model.copyWith(overrides: ov);
    });

    state = state.copyWith(prayerDays: merged);
  }

  /// Re-reads the schedule after the admin edited it (save / copy / override).
  Future<void> refreshPrayerDays() => loadPrayerDays();

  /// Applies an updated row (after an admin save) without a refetch.
  void setMosque(MosqueModel mosque) {
    state = state.copyWith(mosque: mosque);
  }

  void clear() {
    _statusSub?.cancel();
    state = const MyMosqueState();
  }

  /// Realtime status watcher used by the "in review" page.
  void watchStatus() {
    final id = state.mosque?.id;
    if (id == null) return;
    _statusSub?.cancel();
    _statusSub = repo.watchStatus(id).listen((status) {
      final current = state.mosque;
      if (current == null || current.status == status) return;
      state = state.copyWith(mosque: current.copyWith(status: status));
      // Reload to get review_note etc.
      unawaited(load(silent: true));
    }, onError: (e, st) => talker.handle(e, st, 'mosque status stream'));
  }

  void stopWatching() {
    _statusSub?.cancel();
    _statusSub = null;
  }
}
