import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasrouces/auth_local_datasource.dart';
import 'datasrouces/auth_remote_datasource.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepo(
    localDatasource: ref.read(authLocalDataProvider),
    remoteDatasource: ref.read(authRemoteDataProvider),
  ),
);

class AuthRepo {
  final AuthLocalDatasource localDatasource;
  final AuthRemoteDatasource remoteDatasource;

  AuthRepo({
    required this.localDatasource,
    required this.remoteDatasource
  });

  Future<SuccessOrError<void>> signInAnonymously() async {
		return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.signInAnonymously();
		});
  }

  Future<SuccessOrError<bool>> isAuthenticated() async {
		return await Failure.exceptionsCatcher(() async {
      return remoteDatasource.isAuthenticated();
		});
  }

  Future<SuccessOrError<bool>> logout() async {
		return await Failure.exceptionsCatcher(() async {
      return remoteDatasource.logout();
		});
  }

  /// Synchronous session snapshots backed by the locally persisted user.
  bool isAnonymousSession() => remoteDatasource.isAnonymous();

  String? currentEmail() => remoteDatasource.currentEmail();

  /// Returns `true` when an OTP was sent (existing account -> must verify),
  /// `false` when the email was linked instantly to the anonymous session.
  Future<SuccessOrError<bool>> startEmailAuth({required String email}) async {
		return await Failure.exceptionsCatcher<bool>(() async {
      return await remoteDatasource.startEmailAuth(email: email);
		});
  }

  Future<SuccessOrError<void>> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
		return await Failure.exceptionsCatcher<void>(() async {
      await remoteDatasource.verifyEmailOtp(email: email, token: token);
		});
  }

  Future<SuccessOrError<void>> signInWithGoogle() async {
		return await Failure.exceptionsCatcher<void>(() async {
      await remoteDatasource.signInWithGoogle();
		});
  }

  Future<SuccessOrError<void>> signInWithApple() async {
		return await Failure.exceptionsCatcher<void>(() async {
      await remoteDatasource.signInWithApple();
		});
  }


  Future<SuccessOrError<void>> deleteUser() async {
		return await Failure.exceptionsCatcher<void>(() async {
      throw UnimplementedError();
		});
  }
}
