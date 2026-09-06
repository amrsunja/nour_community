import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/mosque_onboarding/data/models/mosque_onboarding_draft.dart';

import 'datasources/mosque_remote_datasource.dart';
import 'models/mosque_enums.dart';
import 'models/mosque_model.dart';

final mosqueRepoProvider = Provider(
  (ref) => MosqueRepo(remote: ref.read(mosqueRemoteDataProvider)),
);

class MosqueRepo {
  final MosqueRemoteDatasource remote;

  MosqueRepo({required this.remote});

  Future<SuccessOrError<int>> registerMosque(MosqueOnboardingDraft draft) =>
      Failure.exceptionsCatcher(() => remote.registerMosque(draft));

  Future<SuccessOrError<MyMosque?>> getMyMosque() =>
      Failure.exceptionsCatcher(remote.getMyMosque);

  Stream<MosqueStatus> watchStatus(int mosqueId) => remote.watchStatus(mosqueId);

  Future<SuccessOrError<MosqueModel>> updateProfile(MosqueModel mosque) =>
      Failure.exceptionsCatcher(() => remote.updateProfile(mosque));
}
