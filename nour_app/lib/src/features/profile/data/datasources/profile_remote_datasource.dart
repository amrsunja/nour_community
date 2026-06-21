import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/profile_model.dart';

final profileRemoteDataProvider = Provider(
  (ref) => ProfileRemoteDatasource(),
);

class ProfileRemoteDatasource {
  static const _tableName = 'profiles';
  static const _avatarBucket = 'avatars';

  static const _contentTypes = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
  };

  /// Uploads [file] to the user's `avatars/<uid>/` folder, replaces any existing
  /// avatar (single file per user), persists the new public URL on the profile
  /// row and returns it. Uses a timestamped object name so the public URL is
  /// unique and never served stale from the CDN.
  Future<String> uploadAvatar(File file) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
      );
    }

    try {
      final storage = supabaseClient.storage.from(_avatarBucket);
      final folder = authUser.id;

      // Drop any previously stored avatar(s) so the folder holds a single file.
      final existing = await storage.list(path: folder);
      if (existing.isNotEmpty) {
        await storage.remove(
          existing.map((f) => '$folder/${f.name}').toList(),
        );
      }

      final ext = file.path.split('.').last.toLowerCase();
      final objectPath =
          '$folder/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await storage.upload(
        objectPath,
        file,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _contentTypes[ext] ?? 'image/jpeg',
        ),
      );

      final url = storage.getPublicUrl(objectPath);

      await supabaseClient
          .from(_tableName)
          .update({'avatar_url': url})
          .eq('id', authUser.id);

      return url;
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.profileAvatarUploadFailed,
      );
    }
  }

  /// Removes every object in the user's avatar folder and clears `avatar_url`.
  Future<void> deleteAvatar() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
      );
    }

    try {
      final storage = supabaseClient.storage.from(_avatarBucket);
      final folder = authUser.id;

      final existing = await storage.list(path: folder);
      if (existing.isNotEmpty) {
        await storage.remove(
          existing.map((f) => '$folder/${f.name}').toList(),
        );
      }

      await supabaseClient
          .from(_tableName)
          .update({'avatar_url': null})
          .eq('id', authUser.id);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.profileAvatarDeleteFailed,
      );
    }
  }

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
        messageKey: ApiErrorKey.userNotAuthenticated,
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
              messageKey: ApiErrorKey.profileInvalid,
            );
          }
          return ProfileModel.fromJson(rows.first);
        });
  }

  Future<ProfileModel> getProfile() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(type: .unauthorized, messageKey: ApiErrorKey.userNotAuthenticated);
    }

    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response == null) {
        throw ServerException(type: .badRequest, messageKey: ApiErrorKey.profileInvalid);
      }

      return ProfileModel.fromJson(response);

    } catch (e) {
      talker.error(e);
      throw ServerException(type: .forbiden, messageKey: ApiErrorKey.profileLoadFailed);
    }
  }

  Future<void> updateDailyPracticeTime(int minutes) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
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
        messageKey: ApiErrorKey.profileUpdatePracticeTimeFailed,
      );
    }
  }

  Future<void> updateLevel(LevelType level) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
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
        messageKey: ApiErrorKey.profileUpdateLevelFailed,
      );
    }
  }

  Future<void> updateName(String name) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
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
        messageKey: ApiErrorKey.profileUpdateNameFailed,
      );
    }
  }

  Future<void> updateGender(GenderType gender) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
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
        messageKey: ApiErrorKey.profileUpdateGenderFailed,
      );
    }
  }

  Future<void> updateLastOnboardingScreen(int page) async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
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
        messageKey: ApiErrorKey.profileUpdateOnboardingScreenFailed,
      );
    }
  }

  Future<void> markOnboardingCompleted() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
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
        messageKey: ApiErrorKey.profileCompleteOnboardingFailed,
      );
    }
  }

  /// Reports the device's current UTC offset (minutes) so the server can derive
  /// the user's local calendar day itself (`fn_local_date`) instead of trusting
  /// a client-sent date. Best-effort: a failure here only means the day falls
  /// back to a stale/UTC value, so it degrades silently.
  Future<void> reportTimezoneOffset() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) return;
    try {
      await supabaseClient.rpc(
        'fn_set_tz_offset',
        params: {'p_minutes': DateTime.now().timeZoneOffset.inMinutes},
      );
    } catch (e) {
      talker.warning('reportTimezoneOffset fallback: $e');
    }
  }
}
