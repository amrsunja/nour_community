import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_model.dart';
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
      (my) {
        if (my == null) {
          state = state.copyWith(isLoading: false, loaded: true, clearMosque: true);
          return false;
        }
        state = state.copyWith(isLoading: false, loaded: true, mosque: my.mosque, role: my.role);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false, loaded: true);
        if (!silent) appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

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
