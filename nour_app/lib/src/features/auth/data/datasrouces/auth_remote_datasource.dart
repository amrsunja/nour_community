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
      throw ServerException(type: .forbiden, message: 'Anonime sign in failed!');
    }
  }

  Future<bool> isAuthenticated() async {
    // Supabase persists the session locally; if a session is present,
    // the user is considered authenticated.
    return supabaseClient.auth.currentSession != null;
  }

  Future<bool> logout() async {
    // Supabase persists the session locally; if a session is present,
    // the user is considered authenticated.
    await supabaseClient.auth.signOut();
    return supabaseClient.auth.currentSession != null;
  }


  /// Sends a 6-digit verification code to [email] via passwordless OTP.
  ///
  /// [signInWithOtp] (with the default `shouldCreateUser: true`) handles both
  /// cases transparently: it creates the account when [email] is new and reuses
  /// it when the account already exists — always emailing a fresh code.
  ///
  /// NOTE: this swaps the anonymous session for the email account's session on
  /// verification; it does not merge anonymous data into the account. Preserving
  /// anonymous data would require [updateUser] + an email-change confirmation,
  /// which is incompatible with email verification being disabled.
  Future<void> sendEmailOtp({required String email}) async {
    try {
      await supabaseClient.auth.signInWithOtp(email: email);
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, message: 'Failed to send code!');
    }
  }

  /// Verifies the [token] entered by the user against [email], completing the
  /// sign-in/sign-up started by [sendEmailOtp].
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
      throw ServerException(type: .unknown, message: 'Code verification failed!');
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
        throw ServerException(type: .cancel, message: 'Sign in cancelled');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        throw ServerException(type: .unauthorized, message: 'Missing Google id token');
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
      throw ServerException(type: .unknown, message: 'Google sign in failed!');
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
        throw ServerException(type: .unauthorized, message: 'Missing Apple id token');
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
        throw ServerException(type: .cancel, message: 'Sign in cancelled');
      }
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, message: 'Apple sign in failed!');
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
