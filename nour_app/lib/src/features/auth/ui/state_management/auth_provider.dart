import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';

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
      isAuthorized: false,
    ));

  Future<void> isAuthorized() async {
    throw UnimplementedError();
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
