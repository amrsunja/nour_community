import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../../data/auth_repo.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthPresenter, AuthState>((ref) {
  return AuthPresenter(
    repo: ref.read(authRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
    ref: ref
  );
});

class AuthPresenter extends Presenter<AuthState> {
  final AuthRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;
  final Ref ref;

  AuthPresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
    required this.ref,
  }) : super(AuthState(
      isLoading: false,
      isAuthenticated: false,
    ));

  Future<bool> signInAnonymously() async {
    final response = await repo.signInAnonymously();

    return response.when(
      (s) async {
        talker.info('Signed in anonime session');
        return true;
      },
      (error) {
        appEvents.send(ShowErrorEvent(error));
        return false;
      }
    );
  }

  Future<void> authorization() async {
    final response = await repo.isAuthenticated();

    await response.when(
      (s) async {
        if (!s) {
          final r1 = await signInAnonymously();

          if (!r1) return ;
        }

        final r2 = await ref.read(profileProvider.notifier).initProfile();

        if (!r2) return ;

        state = state.copyWith(isAuthenticated: true);
      },
      (error) {
        appEvents.send(ShowErrorEvent(error));
        state = state.copyWith(isAuthenticated: false);
      }
    );
  }

  Future<void> signIn() async {
    throw UnimplementedError();
  }

  Future<void> getUser() async {
    throw UnimplementedError();
  }

  Future<bool> logout() async {
    throw UnimplementedError();
  }

  Future<bool> deleteUser() async {
    throw UnimplementedError();
  }
}
