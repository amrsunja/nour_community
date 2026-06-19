import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/env_services.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

final authRemoteDataProvider = Provider(
  (ref) => AuthRemoteDatasource(),
);

class AuthRemoteDatasource {

  Future<void> signInAnonymously() async {
    try {
      await supabaseClient.auth.signInAnonymously();
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .forbiden, messageKey: ApiErrorKey.authAnonymousFailed);
    }
  }

  Future<bool> isAuthenticated() async {
    // Supabase persists the session locally; if a session is present,
    // the user is considered authenticated.
    return supabaseClient.auth.currentSession != null;
  }

  /// True when there is no session OR the active session is anonymous.
  /// Synchronous: reads the locally persisted Supabase user.
  bool isAnonymous() => supabaseClient.auth.currentUser?.isAnonymous ?? true;

  /// Email bound to the active (permanent) account, if any.
  String? currentEmail() => supabaseClient.auth.currentUser?.email;

  Future<bool> logout() async {
    // Supabase persists the session locally; if a session is present,
    // the user is considered authenticated.
    await supabaseClient.auth.signOut();
    return supabaseClient.auth.currentSession != null;
  }

  /// Permanently deletes the current (PERMANENT) account.
  ///
  /// Calls the `delete_account` SECURITY DEFINER RPC, which removes the caller's
  /// auth.users row and cascades to all owned data. The local session is then
  /// cleared via [signOut] — the JWT is technically still valid until expiry but
  /// the user it references no longer exists.
  Future<void> deleteUser() async {
    try {
      await supabaseClient.rpc('delete_account');
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.authDeleteFailed);
    }
  }


  /// Starts the connect-email flow from the current ANONYMOUS session.
  ///
  /// Returns `true` when an OTP was sent and the caller must finish via
  /// [verifyEmailOtp]; `false` when the email was linked INSTANTLY (no OTP).
  ///
  /// - [email] NOT in db  -> [updateUser] attaches it to the current anonymous
  ///   user. With "Confirm email" OFF this applies immediately: the anonymous
  ///   user becomes permanent keeping the same `auth.uid()`, so all owned rows
  ///   (progress, ajr logs, streaks, favorites…) stay attached. No OTP.
  /// - [email] IN db -> the account already exists; we cannot merge it into the
  ///   anonymous user. Send a passwordless OTP ([shouldCreateUser] = false);
  ///   [verifyEmailOtp] then signs into that pre-existing account (the current
  ///   anonymous session is discarded).
  Future<bool> startEmailAuth({required String email}) async {
    try {
      final exists = await _emailExists(email);

      if (exists) {
        await supabaseClient.auth.signInWithOtp(
          email: email,
          shouldCreateUser: false,
        );
        return true; // OTP sent — caller must verify.
      }

      await supabaseClient.auth.updateUser(
        UserAttributes(email: email),
      );
      return false; // Linked instantly — user is already signed in.
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } on ServerException {
      rethrow;
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.authStartFailed);
    }
  }

  /// True if a PERMANENT (non-anonymous) account already owns [email].
  Future<bool> _emailExists(String email) async {
    try {
      final result = await supabaseClient.rpc(
        'email_exists',
        params: {'p_email': email.trim()},
      );
      return result == true;
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.authCheckEmailFailed);
    }
  }

  /// Verifies the [token] for the EXISTING-account path of [startEmailAuth]
  /// (the one that returned `true`). On success the session is the pre-existing
  /// email account; the prior anonymous session is replaced.
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      await supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .unauthorized, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.authCodeVerificationFailed);
    }
  }

  /// Native Google sign in connected to the current ANONYMOUS session.
  ///
  /// Mirrors the email flow: when the session is anonymous and the Google email
  /// is NOT already owned by a permanent account, the identity is LINKED to the
  /// anonymous user via [linkIdentityWithIdToken] keeping the same `auth.uid()`,
  /// so all owned rows stay attached. Otherwise (existing account, or an already
  /// permanent session) it falls back to [signInWithIdToken].
  /// Configure the provider in the Supabase dashboard and the client ids in
  /// [EnvServices]. "Enable Manual Linking" must be ON in Auth settings.
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        // 6.x: clientId must be null on Android (the app is identified by
        // package name + SHA-1). Passing the Android client id here breaks the
        // token audience and crashes signIn(). iOS still needs its clientId.
        clientId: Platform.isIOS ? EnvServices.googleIosClientId : null,
        serverClientId: EnvServices.googleWebClientId,
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        // User aborted the picker.
        throw ServerException(type: .cancel, messageKey: ApiErrorKey.authSignInCancelled);
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        throw ServerException(type: .unauthorized, messageKey: ApiErrorKey.authMissingGoogleToken);
      }

      await _connectIdentity(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
        email: account.email,
      );
    } on ServerException {
      rethrow;
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.authGoogleFailed);
    }
  }

  /// Native Apple sign in connected to the current ANONYMOUS session using a
  /// hashed nonce. Same link-or-signin logic as [signInWithGoogle].
  ///
  /// Apple only returns the email on the FIRST authorization, so the email is
  /// read from the id-token `email` claim ([_emailFromJwt]) rather than the
  /// credential.
  Future<void> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw ServerException(type: .unauthorized, messageKey: ApiErrorKey.authMissingAppleToken);
      }

      await _connectIdentity(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
        email: credential.email ?? _emailFromJwt(idToken),
      );
    } on ServerException {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw ServerException(type: .cancel, messageKey: ApiErrorKey.authSignInCancelled);
      }
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.authAppleFailed);
    }
  }

  /// Connects an OAuth id-token identity to the active session, mirroring the
  /// email-link logic of [startEmailAuth]:
  ///
  /// - ANONYMOUS session + [email] NOT owned by a permanent account ->
  ///   [linkIdentityWithIdToken] attaches the identity to the current anonymous
  ///   user, keeping the same `auth.uid()`. All owned rows stay attached.
  /// - existing permanent account (or already-permanent session) ->
  ///   [signInWithIdToken] signs into that account; the anonymous session is
  ///   discarded (same trade-off as the OTP existing-account path).
  ///
  /// Requires "Enable Manual Linking" in the Supabase Auth settings.
  Future<void> _connectIdentity({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
    String? nonce,
    required String? email,
  }) async {
    final canLink = isAnonymous() &&
        email != null &&
        email.isNotEmpty &&
        !(await _emailExists(email));

    if (canLink) {
      try {
        await supabaseClient.auth.linkIdentityWithIdToken(
          provider: provider,
          idToken: idToken,
          accessToken: accessToken,
          nonce: nonce,
        );
        return;
      } on AuthException catch (e) {
        // The provider identity is already linked to another user even though
        // _emailExists missed it -> fall through to a normal id-token sign in.
        if (e.code != 'identity_already_exists') rethrow;
      }
    }

    await supabaseClient.auth.signInWithIdToken(
      provider: provider,
      idToken: idToken,
      accessToken: accessToken,
      nonce: nonce,
    );
  }

  /// Reads the `email` claim from an unverified JWT payload. The token is still
  /// verified server-side by Supabase; this is only used to decide the link vs
  /// sign-in branch.
  String? _emailFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final email = payload['email'];
      return email is String ? email : null;
    } catch (_) {
      return null;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
