import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/profile_model.dart';

final profileRemoteDataProvider = Provider(
  (ref) => ProfileRemoteDatasource(),
);

class ProfileRemoteDatasource {
  static const _tableName = 'profiles';

  Future<ProfileModel> getProfile() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(type: .unauthorized, message: 'The user is not authenticated');
    }

    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response == null) {
        throw ServerException(type: .badRequest, message: 'Can\'t find correct Profile Model');
      }

      return ProfileModel.fromJson(response);

    } catch (e) {
      talker.error(e);
      throw ServerException(type: .forbiden, message: 'Bad request for getting Profile');
    }
  }

  Future<void> setDailyPracticeTime(int minutes) async {
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
          .update({'daily_practice_time': minutes})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to update daily practice time',
      );
    }
  }
}
