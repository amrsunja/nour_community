import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/payment_remote_datasource.dart';
import 'models/donation_subscription_model.dart';
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

/// Orchestrates the payment flow: backend intent / subscription creation, the
/// native confirmation step, and status reads/streams. Money truth still lives
/// server-side.
class PaymentRepo {
  final PaymentRemoteDatasource remoteDatasource;
  final StripePaymentService stripeService;

  PaymentRepo({required this.remoteDatasource, required this.stripeService});

  bool get isStripeConfigured => stripeService.isConfigured;

  Future<bool> isApplePaySupported() => stripeService.isApplePaySupported();
  Future<bool> isGooglePaySupported() => stripeService.isGooglePaySupported();

  // ── One-time ────────────────────────────────────────────────────────────────

  Future<SuccessOrError<CreatedPaymentIntent>> createPaymentIntent({
    required TxType type,
    required String currency,
    required List<PaymentItem> items,
    required bool coverFees,
    required bool isAnonymous,
    required PaymentMethodKind paymentMethod,
    required String clientKey,
  }) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.createPaymentIntent(
        type: type,
        currency: currency,
        items: items,
        coverFees: coverFees,
        isAnonymous: isAnonymous,
        paymentMethod: paymentMethod,
        clientKey: clientKey,
      ),
    );
  }

  Stream<TxStatus> watchTransactionStatus(int transactionId) =>
      remoteDatasource.watchTransactionStatus(transactionId);

  Future<TxStatus> fetchTransactionStatus(int transactionId) =>
      remoteDatasource.fetchTransactionStatus(transactionId);

  // ── Recurring ───────────────────────────────────────────────────────────────

  Future<SuccessOrError<CreatedSubscription>> createSubscription({
    required int projectId,
    required double amount,
    required String currency,
    required DonationFrequency frequency,
    required bool coverFees,
    required bool isAnonymous,
    required PaymentMethodKind paymentMethod,
    required String clientKey,
  }) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.createSubscription(
        projectId: projectId,
        amount: amount,
        currency: currency,
        frequency: frequency,
        coverFees: coverFees,
        isAnonymous: isAnonymous,
        paymentMethod: paymentMethod,
        clientKey: clientKey,
      ),
    );
  }

  Stream<SubscriptionStatus> watchSubscriptionStatus(int subscriptionId) =>
      remoteDatasource.watchSubscriptionStatus(subscriptionId);

  Future<SubscriptionStatus> fetchSubscriptionStatus(int subscriptionId) =>
      remoteDatasource.fetchSubscriptionStatus(subscriptionId);

  Future<SuccessOrError<List<DonationSubscriptionModel>>> getMySubscriptions() =>
      Failure.exceptionsCatcher(remoteDatasource.getMySubscriptions);

  Future<SuccessOrError<void>> cancelSubscription(
    int subscriptionId, {
    bool immediately = false,
  }) {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.cancelSubscription(
        subscriptionId,
        immediately: immediately,
      ),
    );
  }

  // ── Client confirmation (Stripe SDK) ───────────────────────────────────────

  Future<PaymentSheetResult> confirm({
    required PaymentMethodKind method,
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
    String? customerId,
    String? customerEphemeralKeySecret,
    String? stripeAccountId,
  }) {
    return stripeService.confirm(
      method: method,
      clientSecret: clientSecret,
      amount: amount,
      currency: currency,
      label: label,
      customerId: customerId,
      customerEphemeralKeySecret: customerEphemeralKeySecret,
      stripeAccountId: stripeAccountId,
    );
  }

  // ── History / transparency ─────────────────────────────────────────────────

  Future<SuccessOrError<List<TransactionModel>>> getHistory() =>
      Failure.exceptionsCatcher(remoteDatasource.getHistory);

  Future<SuccessOrError<List<PayoutModel>>> getProjectPayouts(int projectId) =>
      Failure.exceptionsCatcher(() => remoteDatasource.getProjectPayouts(projectId));

  Future<List<RecentDonor>> getRecentDonors(int projectId, {int limit = 3}) =>
      remoteDatasource.getRecentDonors(projectId, limit: limit);
}
