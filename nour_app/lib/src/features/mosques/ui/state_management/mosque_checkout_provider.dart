import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/payments/data/fee_policy.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:nour/src/features/payments/data/payment_repo.dart';
import 'package:nour/src/features/payments/data/services/stripe_payment_service.dart';
import 'package:nour/src/features/payments/ui/state_management/checkout_state.dart';
import 'package:uuid/uuid.dart';

import '../../data/mosque_repo.dart';

/// Route-level inputs of a mosque checkout (Sadaqa, campaign gift, or the
/// yearly membership fee).
class MosqueCheckoutArgs extends Equatable {
  const MosqueCheckoutArgs({
    required this.mosqueId,
    required this.amount,
    required this.frequency,
    this.campaignId,
    this.membershipId,
  });

  final int mosqueId;
  final double amount;
  final DonationFrequency frequency;
  final int? campaignId;
  final int? membershipId;

  bool get isMembership => membershipId != null;
  bool get isCampaign => campaignId != null;

  @override
  List<Object?> get props => [mosqueId, amount, frequency, campaignId, membershipId];
}

final mosqueCheckoutProvider = StateNotifierProvider.autoDispose.family<MosqueCheckoutPresenter, CheckoutState, MosqueCheckoutArgs>((ref, args) {
  return MosqueCheckoutPresenter(
    args: args,
    repo: ref.read(mosqueRepoProvider),
    payments: ref.read(paymentRepoProvider),
    analytics: ref.read(analyticsRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

/// Same state machine as the impact [CheckoutPresenter] but on the mosque
/// edge functions (Stripe Connect DIRECT charges — no platform fee, no
/// "cover fees" option, no PayPal).
class MosqueCheckoutPresenter extends Presenter<CheckoutState> {
  MosqueCheckoutPresenter({
    required this.args,
    required this.repo,
    required this.payments,
    required this.analytics,
    required this.appEvents,
  }) : super(CheckoutState(amount: args.amount, frequency: args.frequency, isZakat: false, paypalAvailable: false)) {
    _probeWallets();
  }

  final MosqueCheckoutArgs args;
  final MosqueRepo repo;
  final PaymentRepo payments;
  final AnalyticsRepo analytics;
  final AppEvents appEvents;

  static const double amountStep = 5;
  static const Duration confirmationTimeout = Duration(seconds: 90);
  static const Duration pollInterval = Duration(seconds: 4);

  StreamSubscription<TxStatus>? _txSub;
  StreamSubscription<SubscriptionStatus>? _subSub;
  Timer? _poll;
  Timer? _timeout;
  String? _clientKey;

  Future<void> _probeWallets() async {
    final results = await Future.wait([payments.isApplePaySupported(), payments.isGooglePaySupported()]);
    if (!mounted) return;
    state = state.copyWith(applePayAvailable: results[0], googlePayAvailable: results[1]);
  }

  void increment() => setAmount(state.amount + amountStep);
  void decrement() => setAmount(state.amount - amountStep);

  void setAmount(double value) {
    if (state.isBusy) return;
    final clamped = value.clamp(FeePolicy.minAmount, FeePolicy.maxAmount);
    state = state.copyWith(amount: _round2(clamped.toDouble()));
  }

  void setFrequency(DonationFrequency f) {
    if (state.isBusy || args.isMembership) return;
    state = state.copyWith(frequency: f);
  }

  void setAnonymous(bool v) {
    if (state.isBusy) return;
    state = state.copyWith(isAnonymous: v);
  }

  void setMethod(PaymentMethodKind m) {
    if (state.isBusy || m == PaymentMethodKind.paypal) return;
    state = state.copyWith(method: m);
    analytics.trackButtonClick('payment_method_${m.value}', screen: 'mosque_checkout');
  }

  /// [label] is shown on the wallet sheet (mosque or campaign name).
  Future<void> pay({required String currency, required String label}) async {
    if (state.isBusy) return;
    if (!payments.isStripeConfigured) {
      appEvents.send(_failure(ApiErrorKey.paymentIntentFailed));
      return;
    }
    if (state.amount < FeePolicy.minAmount) {
      appEvents.send(_failure(ApiErrorKey.paymentAmountTooSmall));
      return;
    }

    _stopTracking();
    _clientKey = const Uuid().v4();
    state = state.copyWith(phase: CheckoutPhase.preparing, timedOut: false, clearIds: true);
    analytics.trackButtonClick('mosque_checkout_pay', screen: 'mosque_checkout');

    final res = state.isRecurring
        ? await repo.createMosqueSubscription(
            mosqueId: args.mosqueId,
            amount: state.amount,
            currency: currency,
            frequency: state.frequency,
            membershipId: args.membershipId,
            isAnonymous: state.isAnonymous,
            paymentMethod: state.method,
            clientKey: _clientKey!,
          )
        : await repo.createMosquePaymentIntent(
            mosqueId: args.mosqueId,
            amount: state.amount,
            currency: currency,
            campaignId: args.campaignId,
            membershipId: args.membershipId,
            isAnonymous: state.isAnonymous,
            paymentMethod: state.method,
            clientKey: _clientKey!,
          );
    if (!mounted) return;
    final created = res.when((v) => v, (error) {
      appEvents.send(ShowErrorEvent(error));
      state = state.copyWith(phase: CheckoutPhase.idle);
      return null;
    });
    if (created == null) return;
    state = state.copyWith(
      transactionId: created.transactionId,
      subscriptionId: created.subscriptionId,
      quotedFee: 0,
      quotedCharged: created.amountCharged,
    );

    final result = await payments.confirm(
      method: state.method,
      clientSecret: created.clientSecret,
      amount: created.amountCharged,
      currency: currency,
      label: label,
      customerId: created.customerId,
      customerEphemeralKeySecret: created.ephemeralKeySecret,
      stripeAccountId: created.stripeAccountId,
    );
    if (!mounted) return;

    switch (result) {
      case PaymentSheetResult.cancelled:
        state = state.copyWith(phase: CheckoutPhase.idle, clearIds: true);
        analytics.trackButtonClick('mosque_checkout_cancelled', screen: 'mosque_checkout');
        return;
      case PaymentSheetResult.failed:
        appEvents.send(_failure(ApiErrorKey.paymentSheetFailed));
        state = state.copyWith(phase: CheckoutPhase.failed);
        return;
      case PaymentSheetResult.completed:
        break;
    }

    state = state.copyWith(phase: CheckoutPhase.processing);
    _track();
  }

  Future<void> onAppResumed() async {
    if (state.phase != CheckoutPhase.processing) return;
    await _pollOnce();
  }

  void keepWaiting() {
    if (state.phase != CheckoutPhase.processing) return;
    state = state.copyWith(timedOut: false);
    _armTimeout();
  }

  void reset() {
    _stopTracking();
    state = state.copyWith(phase: CheckoutPhase.idle, timedOut: false, clearIds: true);
  }

  // ── Tracking (rows live in the shared tables → same streams) ──────────────

  void _track() {
    _stopTracking();
    final txId = state.transactionId;
    final subId = state.subscriptionId;
    if (subId != null) {
      _subSub = payments.watchSubscriptionStatus(subId).listen(_applySubStatus);
    } else if (txId != null) {
      _txSub = payments.watchTransactionStatus(txId).listen(_applyTxStatus);
    }
    _poll = Timer.periodic(pollInterval, (_) => _pollOnce());
    _armTimeout();
  }

  void _armTimeout() {
    _timeout?.cancel();
    _timeout = Timer(confirmationTimeout, () {
      if (state.phase != CheckoutPhase.processing) return;
      state = state.copyWith(timedOut: true);
    });
  }

  Future<void> _pollOnce() async {
    if (state.phase != CheckoutPhase.processing) return;
    final subId = state.subscriptionId;
    final txId = state.transactionId;
    if (subId != null) {
      _applySubStatus(await payments.fetchSubscriptionStatus(subId));
    } else if (txId != null) {
      _applyTxStatus(await payments.fetchTransactionStatus(txId));
    }
  }

  void _applyTxStatus(TxStatus status) {
    if (!mounted || state.phase != CheckoutPhase.processing) return;
    switch (status) {
      case TxStatus.succeeded:
        _stopTracking();
        state = state.copyWith(phase: CheckoutPhase.success);
        analytics.trackButtonClick('mosque_donation_succeeded', screen: 'mosque_checkout');
      case TxStatus.failed:
      case TxStatus.refunded:
        _stopTracking();
        appEvents.send(_failure(ApiErrorKey.paymentSheetFailed));
        state = state.copyWith(phase: CheckoutPhase.failed);
      case TxStatus.pending:
      case TxStatus.processing:
        break;
    }
  }

  void _applySubStatus(SubscriptionStatus status) {
    if (!mounted || state.phase != CheckoutPhase.processing) return;
    switch (status) {
      case SubscriptionStatus.active:
        _stopTracking();
        state = state.copyWith(phase: CheckoutPhase.success);
        analytics.trackButtonClick('mosque_subscription_created', screen: 'mosque_checkout');
      case SubscriptionStatus.canceled:
      case SubscriptionStatus.unpaid:
        _stopTracking();
        appEvents.send(_failure(ApiErrorKey.paymentSheetFailed));
        state = state.copyWith(phase: CheckoutPhase.failed);
      case SubscriptionStatus.incomplete:
      case SubscriptionStatus.pastDue:
      case SubscriptionStatus.paused:
        break;
    }
  }

  void _stopTracking() {
    _txSub?.cancel();
    _txSub = null;
    _subSub?.cancel();
    _subSub = null;
    _poll?.cancel();
    _poll = null;
    _timeout?.cancel();
    _timeout = null;
  }

  ShowErrorEvent _failure(ApiErrorKey key) => ShowErrorEvent(ServerFailure(exception: ServerException(type: .badRequest, messageKey: key)));

  static double _round2(double v) => (v * 100).roundToDouble() / 100;

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}
