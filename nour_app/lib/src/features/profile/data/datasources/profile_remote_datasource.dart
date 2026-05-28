import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/core/utils/enums/language_type.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/profile_model.dart';

final profileRemoteDataProvider = Provider(
  (ref) => ProfileRemoteDatasource(),
);

class ProfileRemoteDatasource {
  static const _tableName = 'profiles';

  /// Realtime stream of the authenticated user's profile row.
  ///
  /// Backed by Supabase Realtime (`profiles` is in the `supabase_realtime`
  /// publication) and scoped by RLS to the caller's own row, so
  /// `current_streak` / `earned_ajr_count` stay live without polling.
  Stream<ProfileModel> watchProfile() {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        message: 'The user is not authenticated',
      );
    }

    return supabaseClient
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', authUser.id)
        .map((rows) {
          if (rows.isEmpty) {
            throw ServerException(
              type: .notFound,
              message: 'Can\'t find correct Profile Model',
            );
          }
          return ProfileModel.fromJson(rows.first);
        });
  }

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

  Future<void> updateDailyPracticeTime(int minutes) async {
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

  Future<void> updateName(String name) async {
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
          .update({'name': name})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to update profile name',
      );
    }
  }

  Future<void> updateGender(GenderType gender) async {
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
          .update({'gender': gender == GenderType.undefined ? null : gender.dbValue})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to update profile gender',
      );
    }
  }

  Future<void> updateLanguage(LanguageType lang) async {
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
          .update({'language': lang.dbValue})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to update profile language',
      );
    }
  }

  Future<void> updateLastOnboardingScreen(int page) async {
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
          .update({'last_onboarding_screen': page})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to update last onboarding screen',
      );
    }
  }

  Future<void> markOnboardingCompleted() async {
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
          .update({'onboarding_completed': true})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to mark onboarding as completed',
      );
    }
  }
}
