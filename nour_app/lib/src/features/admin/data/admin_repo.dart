import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';
import 'package:nour/src/features/payments/data/models/transaction_model.dart';

import 'datasources/admin_remote_datasource.dart';
import 'models/project_analytics_model.dart';
import 'models/record_payout_params.dart';

final adminRepoProvider = Provider(
  (ref) => AdminRepo(remoteDatasource: ref.read(adminRemoteDataProvider)),
);

class AdminRepo {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<ProjectAnalyticsModel>>> fetchAnalytics() {
    return Failure.exceptionsCatcher(remoteDatasource.fetchAnalytics);
  }

  Future<SuccessOrError<List<ImpactProjectModel>>> fetchAllProjects() {
    return Failure.exceptionsCatcher(remoteDatasource.fetchAllProjects);
  }

  Future<SuccessOrError<List<PayoutModel>>> fetchPayouts() {
    return Failure.exceptionsCatcher(remoteDatasource.fetchPayouts);
  }

  Future<SuccessOrError<List<TransactionModel>>> fetchTransactions() {
    return Failure.exceptionsCatcher(remoteDatasource.fetchTransactions);
  }

  Future<SuccessOrError<String>> uploadProof({
    required Uint8List bytes,
    required String fileExt,
    required String contentType,
  }) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.uploadProof(
        bytes: bytes,
        fileExt: fileExt,
        contentType: contentType,
      ),
    );
  }

  Future<String?> signedProofUrl(String path) {
    return remoteDatasource.signedProofUrl(path);
  }

  Future<SuccessOrError<void>> createPayout(
    RecordPayoutParams params, {
    List<int> transactionItemIds = const [],
  }) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.createPayout(
        params,
        transactionItemIds: transactionItemIds,
      ),
    );
  }
}
