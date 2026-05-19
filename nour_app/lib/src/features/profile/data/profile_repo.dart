import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
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
}
