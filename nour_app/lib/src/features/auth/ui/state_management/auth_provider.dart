import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
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

        if (!r2) {
          await repo.logout();
          await authorization();

          return ;
        }

        state = state.copyWith(isAuthenticated: true);
      },
      (error) {
        appEvents.send(ShowErrorEvent(error));
        state = state.copyWith(isAuthenticated: false);
      }
    );
  }

  /// Converts the current anonymous session into a permanent account by
  /// linking an email/password identity.
  Future<bool> linkWithEmail({
    required String email,
    required String password,
  }) {
    return _runLinking(
      () => repo.linkEmailPassword(email: email, password: password),
    );
  }

  Future<bool> linkWithGoogle() => _runLinking(repo.signInWithGoogle);

  Future<bool> linkWithApple() => _runLinking(repo.signInWithApple);

  Future<bool> _runLinking(Future<SuccessOrError<void>> Function() action) async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true);

    final response = await action();

    final result = await response.when(
      (_) async {
        // Refresh the profile bound to the (now permanent) account.
        final ok = await ref.read(profileProvider.notifier).initProfile();
        if (!ok) return false;
        state = state.copyWith(isAuthenticated: true);
        appEvents.send(ShowSuccessMessageEvent(locale.auth_link_success));
        return true;
      },
      (error) async {
        // Swallow user-initiated cancellations — they are not errors.
        final isCancelled = error is ServerFailure &&
            error.exception.type == ServerExceptionType.cancel;
        if (!isCancelled) {
          appEvents.send(ShowErrorEvent(error));
        }
        return false;
      },
    );

    state = state.copyWith(isLoading: false);
    return result;
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
