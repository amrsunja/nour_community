import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
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
}
