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

  /// Native Google sign in -> Supabase [signInWithIdToken].
  ///
  /// NOTE: id-token sign in authenticates against the Google identity directly;
  /// it does not merge an existing anonymous session. Configure the provider in
  /// the Supabase dashboard and the client ids in [EnvServices].
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
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

      await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
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

  /// Native Apple sign in -> Supabase [signInWithIdToken] using a hashed nonce.
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

      await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
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
