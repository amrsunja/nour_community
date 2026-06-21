import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../../data/auth_repo.dart';
import 'auth_state.dart';

/// Outcome of [AuthPresenter.connectEmail].
enum EmailConnectResult { linked, otpSent, failed }

final authProvider = StateNotifierProvider<AuthPresenter, AuthState>((ref) {
  return AuthPresenter(
    repo: ref.read(authRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
    ref: ref
  );
});

/// Read-only snapshot of the active Supabase session, recomputed whenever
/// [authProvider] mutates (sign-in, link, logout). Lets the UI branch on
/// anonymous vs. connected without leaking the data layer into widgets.
final authSessionProvider = Provider<AuthSession>((ref) {
  ref.watch(authProvider);
  final repo = ref.read(authRepoProvider);
  return AuthSession(
    isAnonymous: repo.isAnonymousSession(),
    email: repo.currentEmail(),
  );
});

class AuthSession {
  final bool isAnonymous;
  final String? email;

  const AuthSession({required this.isAnonymous, this.email});
}

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

        // Attach a non-PII identity to the analytics session.
        final isAnon = repo.isAnonymousSession();
        ref.read(analyticsRepoProvider).identifyUser(
              userId: supabaseClient.auth.currentUser?.id,
              isAnonymous: isAnon,
            );
        ref.read(analyticsRepoProvider).trackLogin(
              method: isAnon ? 'anonymous' : 'email',
            );
      },
      (error) {
        appEvents.send(ShowErrorEvent(error));
        state = state.copyWith(isAuthenticated: false);
      }
    );
  }

  /// Starts the connect-email flow from the current anonymous session.
  ///
  /// - [EmailConnectResult.linked]  -> email was new; linked instantly and the
  ///   user is already authenticated (no OTP step).
  /// - [EmailConnectResult.otpSent] -> email belongs to an existing account;
  ///   a code was sent and the caller must call [linkEmailWithOTP].
  /// - [EmailConnectResult.failed]  -> nothing happened.
  Future<EmailConnectResult> connectEmail({required String email}) async {
    if (state.isLoading) return EmailConnectResult.failed;
    state = state.copyWith(isLoading: true);

    final response = await repo.startEmailAuth(email: email);

    final result = await response.when(
      (otpSent) async {
        if (otpSent) {
          appEvents.send(ShowSuccessMessageEvent(locale.auth_otp_sent));
          return EmailConnectResult.otpSent;
        }
        // Instant link: refresh profile bound to the now-permanent account.
        final ok = await ref.read(profileProvider.notifier).initProfile();
        if (!ok) return EmailConnectResult.failed;
        state = state.copyWith(isAuthenticated: true);
        appEvents.send(ShowSuccessMessageEvent(locale.auth_link_success));
        return EmailConnectResult.linked;
      },
      (error) async {
        appEvents.send(ShowErrorEvent(error));
        return EmailConnectResult.failed;
      },
    );

    state = state.copyWith(isLoading: false);
    return result;
  }

  /// Converts the current anonymous session into a permanent account by
  /// verifying the OTP code [token] sent to [email].
  Future<bool> linkEmailWithOTP({
    required String email,
    required String token,
  }) {
    return _runLinking(
      () => repo.verifyEmailOtp(email: email, token: token),
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

  /// Signs the user out of their permanent account and bounces back to
  /// [RootRoute], whose bootstrap re-runs [authorization] and provisions a
  /// fresh anonymous session.
  Future<bool> logout() async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true);

    final response = await repo.logout();

    final result = response.when(
      (_) {
        ref.read(analyticsRepoProvider).trackLogout();
        ref.read(analyticsRepoProvider).identifyUser(userId: null);
        state = state.copyWith(isAuthenticated: false, isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );

    return result;
  }

  /// Permanently deletes the user's account (all owned data is cascade-deleted
  /// server-side) and clears the local session. Mirrors [logout]: the caller is
  /// expected to re-run [authorization] and bounce to [RootRoute], which
  /// provisions a fresh anonymous session and routes to onboarding.
  Future<bool> deleteUser() async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true);

    final response = await repo.deleteUser();

    final result = response.when(
      (_) {
        ref.read(analyticsRepoProvider).trackLogout();
        ref.read(analyticsRepoProvider).identifyUser(userId: null);
        state = state.copyWith(isAuthenticated: false, isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );

    return result;
  }
}
