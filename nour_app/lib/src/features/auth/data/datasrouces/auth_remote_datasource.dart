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


  /// The [OtpType] resolved by [sendEmailOtp] and consumed by
  /// [verifyEmailOtp]. Kept here so Supabase types never leak past the
  /// data layer.
  OtpType _pendingOtpType = OtpType.email;

  /// Sends a 6-digit verification code to [email].
  ///
  /// - When [email] is free, it is linked to the current anonymous user via
  ///   [updateUser] — anonymous data stays attached to the now-permanent
  ///   account and the code is verified as an [OtpType.emailChange].
  /// - When [email] already belongs to an account, we fall back to
  ///   passwordless [signInWithOtp], verified as [OtpType.email], swapping the
  ///   anonymous session for the existing account's session.
  Future<void> sendEmailOtp({required String email}) async {
    try {
      await supabaseClient.auth.updateUser(UserAttributes(email: email));
      _pendingOtpType = OtpType.emailChange;
    } on AuthException catch (e) {
      if (_isEmailAlreadyRegistered(e)) {
        try {
          await supabaseClient.auth.signInWithOtp(email: email);
          _pendingOtpType = OtpType.email;
          return;
        } on AuthException catch (signInError) {
          talker.info(signInError.message);
          throw ServerException(type: .badRequest, message: signInError.message);
        }
      }
      talker.info(e.message);
      throw ServerException(type: .badRequest, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, message: 'Failed to send code!');
    }
  }

  /// Verifies the [token] entered by the user against [email], completing the
  /// link/sign-in started by [sendEmailOtp].
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      await supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: _pendingOtpType,
      );
    } on AuthException catch (e) {
      talker.info(e.message);
      throw ServerException(type: .unauthorized, message: e.message);
    } catch (e) {
      talker.info(e);
      throw ServerException(type: .unknown, message: 'Code verification failed!');
    }
  }

  bool _isEmailAlreadyRegistered(AuthException e) {
    final code = e.code?.toLowerCase();
    if (code == 'same_password' || code == 'email_exists' || code == 'user_already_exists') return true;

    final message = e.message.toLowerCase();
    return message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('password should be differen') ||
        message.contains('already exists');
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
