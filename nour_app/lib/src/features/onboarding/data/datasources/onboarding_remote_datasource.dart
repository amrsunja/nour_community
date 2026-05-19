import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

final onboardingRemoteDataProvider = Provider(
  (ref) => OnboardingRemoteDatasource(),
);

class OnboardingRemoteDatasource {
  static const _tableName = 'profiles';

  Future<void> updateLevel(LevelType level) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        message: 'The user is not authenticated',
      );
    }

    try {
      await supabaseClient
          .from(_tableName)
          .update({'level': level.dbValue})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to update profile level',
      );
    }
  }
}
