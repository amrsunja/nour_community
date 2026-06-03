import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/core/utils/enums/language_type.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/profile/data/models/profile_model.dart';

import 'datasources/profile_remote_datasource.dart';

final profileRepoProvider = Provider(
  (ref) => ProfileRepo(
    remoteDatasource: ref.read(profileRemoteDataProvider),
  ),
);

class ProfileRepo {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepo({
    required this.remoteDatasource
  });

  Future<SuccessOrError<ProfileModel>> getProfile() async {
		return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getProfile();
		});
  }

  /// Live profile stream (Supabase Realtime). Errors surface through the
  /// stream's `onError`; the presenter keeps the last good state on failure.
  Stream<ProfileModel> watchProfile() => remoteDatasource.watchProfile();

  Future<SuccessOrError<void>> updateDailyPracticeTime(int minutes) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateDailyPracticeTime(minutes);
    });
  }

  Future<SuccessOrError<void>> updateLevel(LevelType level) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateLevel(level);
    });
  }

  Future<SuccessOrError<void>> updateName(String name) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateName(name);
    });
  }

  Future<SuccessOrError<void>> updateGender(GenderType gender) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateGender(gender);
    });
  }

  Future<SuccessOrError<void>> updateLanguage(LanguageType lang) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateLanguage(lang);
    });
  }

  Future<SuccessOrError<void>> updateLastOnboardingScreen(int page) async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.updateLastOnboardingScreen(page);
    });
  }

  /// Uploads a new avatar and returns its public URL on success.
  Future<SuccessOrError<String>> uploadAvatar(File file) async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.uploadAvatar(file);
    });
  }

  Future<SuccessOrError<void>> deleteAvatar() async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.deleteAvatar();
    });
  }

  Future<SuccessOrError<void>> markOnboardingCompleted() async {
    return await Failure.exceptionsCatcher(() async {
      await remoteDatasource.markOnboardingCompleted();
    });
  }
}
