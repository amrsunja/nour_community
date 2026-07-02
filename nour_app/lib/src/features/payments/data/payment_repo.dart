import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/payment_remote_datasource.dart';
import 'models/payout_model.dart';
import 'models/transaction_model.dart';
import 'models/tx_enums.dart';
import 'services/stripe_payment_service.dart';

final paymentRepoProvider = Provider(
  (ref) => PaymentRepo(
    remoteDatasource: ref.read(paymentRemoteDataProvider),
    stripeService: ref.read(stripePaymentServiceProvider),
  ),
);

/// Orchestrates the payment flow: backend PaymentIntent creation, the native
/// PaymentSheet, and status reads/streams. Money truth still lives server-side.
class PaymentRepo {
  final PaymentRemoteDatasource remoteDatasource;
  final StripePaymentService stripeService;

  PaymentRepo({required this.remoteDatasource, required this.stripeService});

  Future<SuccessOrError<CreatedPaymentIntent>> createPaymentIntent({
    required TxType type,
    required String currency,
    required List<PaymentItem> items,
    required bool coverFees,
  }) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.createPaymentIntent(
        type: type,
        currency: currency,
        items: items,
        coverFees: coverFees,
      ),
    );
  }

  Future<PaymentSheetResult> presentPaymentSheet(String clientSecret) {
    return stripeService.presentPaymentSheet(clientSecret: clientSecret);
  }

  Stream<TxStatus> watchTransactionStatus(int transactionId) {
    return remoteDatasource.watchTransactionStatus(transactionId);
  }

  Future<TxStatus> fetchTransactionStatus(int transactionId) {
    return remoteDatasource.fetchTransactionStatus(transactionId);
  }

  Future<SuccessOrError<List<TransactionModel>>> getHistory() {
    return Failure.exceptionsCatcher(remoteDatasource.getHistory);
  }

  Future<SuccessOrError<List<PayoutModel>>> getProjectPayouts(int projectId) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getProjectPayouts(projectId),
    );
  }
}
