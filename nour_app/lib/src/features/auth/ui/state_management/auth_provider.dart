import 'dart:async';

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
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/mosque_onboarding/data/datasources/mosque_onboarding_local_datasource.dart';
import 'package:nour/src/features/mosque_onboarding/data/models/mosque_onboarding_draft.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/notifications/ui/state_management/push_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';

import '../../data/auth_repo.dart';
import 'auth_state.dart';

/// Outcome of [AuthPresenter.connectEmail].
/// [routed] = signed in and [AuthPresenter] already navigated (mosque account
/// or mosque registration) — the caller must not pop.
enum EmailConnectResult { linked, otpSent, failed, routed }

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

  /// Mosque-manager onboarding draft waiting for an account (§3.1). Set by
  /// the mosque onboarding "account" step right before sign-in / sign-up so
  /// [_afterLogin] can register the mosque once the session exists.
  MosqueOnboardingDraft? _pendingMosqueDraft;

  void setPendingMosqueDraft(MosqueOnboardingDraft? draft) {
    _pendingMosqueDraft = draft;
  }

  /// App bootstrap.
  ///
  /// * A session exists → load the profile (+ the managed mosque for mosque
  ///   accounts) and mark authenticated; [AuthGuard] routes by account type.
  /// * No session → stay unauthenticated. [AuthGuard] shows the Welcome /
  ///   profile-type screens; the anonymous session is only created when the
  ///   user picks "worshipper" ([startAsWorshipper]). Mosque accounts are
  ///   never anonymous.
  Future<void> authorization() async {
    final response = await repo.isAuthenticated();

    await response.when(
      (hasSession) async {
        if (!hasSession) {
          state = state.copyWith(isAuthenticated: false);
          return;
        }

        final r2 = await ref.read(profileProvider.notifier).initProfile();

        if (!r2) {
          await repo.logout();
          state = state.copyWith(isAuthenticated: false);
          return;
        }

        await _loadMyMosqueIfNeeded();
        state = state.copyWith(isAuthenticated: true);
        _identify();
        unawaited(ref.read(pushProvider.notifier).syncToken());
      },
      (error) {
        appEvents.send(ShowErrorEvent(error));
        state = state.copyWith(isAuthenticated: false);
      }
    );
  }

  /// "I am a worshipper" → anonymous session (today's behaviour) → onboarding.
  Future<bool> startAsWorshipper() async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true);

    final ok = await signInAnonymously();
    if (!ok) {
      state = state.copyWith(isLoading: false);
      return false;
    }
    final r2 = await ref.read(profileProvider.notifier).initProfile();
    if (!r2) {
      await repo.logout();
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      return false;
    }
    await ref.read(mosqueOnboardingLocalDataProvider).clear();
    state = state.copyWith(isLoading: false, isAuthenticated: true);
    _identify();
    unawaited(ref.read(pushProvider.notifier).syncToken());
    ref.read(navigationServicesProvider).toOnboarding();
    return true;
  }

  Future<void> _loadMyMosqueIfNeeded() async {
    final profile = ref.read(profileProvider).profile;
    if (profile?.isMosqueAccount ?? false) {
      await ref.read(myMosqueProvider.notifier).load(silent: true);
    } else {
      ref.read(myMosqueProvider.notifier).clear();
    }
  }

  void _identify() {
    unawaited(ref.read(appConfigProvider.notifier).load());
    final isAnon = repo.isAnonymousSession();
    ref.read(analyticsRepoProvider).identifyUser(
          userId: supabaseClient.auth.currentUser?.id,
          isAnonymous: isAnon,
        );
    ref.read(analyticsRepoProvider).trackLogin(
          method: isAnon ? 'anonymous' : 'email',
        );
  }

  /// Post-login routing (§3.1). Called after every successful sign-in / link.
  ///
  /// Returns `true` when the caller may continue its own flow (worshipper
  /// account: the sign-in page simply closes). Returns `false` when this
  /// method already navigated away (mosque account, or a mosque just
  /// registered) — the caller must not pop.
  Future<bool> _afterLogin() async {
    final ok = await ref.read(profileProvider.notifier).initProfile();
    if (!ok) return false;
    unawaited(ref.read(pushProvider.notifier).syncToken());
    unawaited(ref.read(appConfigProvider.notifier).load());

    final profile = ref.read(profileProvider).profile!;
    final draftStore = ref.read(mosqueOnboardingLocalDataProvider);
    final nav = ref.read(navigationServicesProvider);
    final draft = _pendingMosqueDraft;

    if (profile.isMosqueAccount) {
      // Existing mosque account (from either onboarding flow).
      _pendingMosqueDraft = null;
      await draftStore.clear();
      await ref.read(myMosqueProvider.notifier).load(silent: true);
      state = state.copyWith(isAuthenticated: true);
      nav.toMosqueAdminOrReview();
      return false;
    }

    if (draft != null && !profile.onboardingCompleted) {
      // Brand-new account created by the mosque onboarding → register it.
      final res = await ref.read(mosqueRepoProvider).registerMosque(draft);
      final registered = res.when((_) => true, (error) {
        appEvents.send(ShowErrorEvent(error));
        return false;
      });
      if (!registered) {
        // Keep the draft; the user stays on the account step and can retry.
        state = state.copyWith(isAuthenticated: false);
        return false;
      }
      _pendingMosqueDraft = null;
      await draftStore.clear();
      await ref.read(profileProvider.notifier).initProfile();
      await ref.read(myMosqueProvider.notifier).load(silent: true);
      state = state.copyWith(isAuthenticated: true);
      nav.toMosqueReview();
      return false;
    }

    // Existing worshipper (or anonymous session just made permanent).
    if (draft != null) {
      // Came from the mosque onboarding but logged into a worshipper
      // account: discard the draft and continue as a worshipper.
      _pendingMosqueDraft = null;
      await draftStore.clear();
      ref.read(myMosqueProvider.notifier).clear();
      state = state.copyWith(isAuthenticated: true);
      profile.onboardingCompleted ? nav.toHome() : nav.toOnboarding();
      return false;
    }

    state = state.copyWith(isAuthenticated: true);
    return true;
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
        final stay = await _afterLogin();
        if (!stay && !state.isAuthenticated) return EmailConnectResult.failed;
        appEvents.send(ShowSuccessMessageEvent(locale.auth_link_success));
        return stay ? EmailConnectResult.linked : EmailConnectResult.routed;
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
        // Refresh the profile bound to the (now permanent) account and route
        // by account type (§3.1). `true` = caller may close its page.
        final stay = await _afterLogin();
        if (!stay && !state.isAuthenticated) return false;
        appEvents.send(ShowSuccessMessageEvent(locale.auth_link_success));
        return stay;
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

    await ref.read(pushProvider.notifier).revoke();
    final response = await repo.logout();

    final result = response.when(
      (_) {
        ref.read(analyticsRepoProvider).trackLogout();
        ref.read(analyticsRepoProvider).identifyUser(userId: null);
        ref.read(myMosqueProvider.notifier).clear();
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

    await ref.read(pushProvider.notifier).revoke();
    final response = await repo.deleteUser();

    final result = response.when(
      (_) {
        ref.read(analyticsRepoProvider).trackLogout();
        ref.read(analyticsRepoProvider).identifyUser(userId: null);
        ref.read(myMosqueProvider.notifier).clear();
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
