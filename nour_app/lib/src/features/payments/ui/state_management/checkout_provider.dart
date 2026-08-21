import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:uuid/uuid.dart';

import '../../data/fee_policy.dart';
import '../../data/models/tx_enums.dart';
import '../../data/payment_repo.dart';
import '../../data/services/stripe_payment_service.dart';
import 'checkout_state.dart';

/// Route-level inputs of a checkout. Everything else (project data) is read
/// from the impact detail provider by the page.
class CheckoutArgs extends Equatable {
  const CheckoutArgs({
    required this.projectId,
    required this.amount,
    required this.frequency,
    this.isZakat = false,
  });

  final int projectId;
  final double amount;
  final DonationFrequency frequency;

  /// Hidden in the impact-project flow (always a sadaqa). The zakat calculator
  /// flow will pass `true` once implemented.
  final bool isZakat;

  @override
  List<Object?> get props => [projectId, amount, frequency, isZakat];
}

/// One presenter per checkout screen; auto-disposed when the page is popped.
final checkoutProvider = StateNotifierProvider.autoDispose
    .family<CheckoutPresenter, CheckoutState, CheckoutArgs>((ref, args) {
  return CheckoutPresenter(
    args: args,
    repo: ref.read(paymentRepoProvider),
    analytics: ref.read(analyticsRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class CheckoutPresenter extends Presenter<CheckoutState> {
  CheckoutPresenter({
    required this.args,
    required this.repo,
    required this.analytics,
    required this.appEvents,
  }) : super(
          CheckoutState(
            amount: args.amount,
            frequency: args.frequency,
            isZakat: args.isZakat,
            // Zakat must arrive in full: fees are covered by default.
            coverFees: args.isZakat,
          ),
        ) {
    _probeWallets();
  }

  final CheckoutArgs args;
  final PaymentRepo repo;
  final AnalyticsRepo analytics;
  final AppEvents appEvents;

  static const double amountStep = 5;

  /// How long we wait for the webhook before offering the "keep waiting /
  /// check later" state. Realtime is usually < 2 s; PayPal / 3DS can be slower.
  static const Duration confirmationTimeout = Duration(seconds: 90);
  static const Duration pollInterval = Duration(seconds: 4);

  StreamSubscription<TxStatus>? _txSub;
  StreamSubscription<SubscriptionStatus>? _subSub;
  Timer? _poll;
  Timer? _timeout;
  String? _clientKey;

  // ── Form ────────────────────────────────────────────────────────────────────

  Future<void> _probeWallets() async {
    final results = await Future.wait([
      repo.isApplePaySupported(),
      repo.isGooglePaySupported(),
    ]);
    if (!mounted) return;
    state = state.copyWith(
      applePayAvailable: results[0],
      googlePayAvailable: results[1],
    );
  }

  void increment() => setAmount(state.amount + amountStep);
  void decrement() => setAmount(state.amount - amountStep);

  void setAmount(double value) {
    if (state.isBusy) return;
    final clamped = value.clamp(FeePolicy.minAmount, FeePolicy.maxAmount);
    state = state.copyWith(amount: _round2(clamped.toDouble()));
  }

  void setAnonymous(bool v) {
    if (state.isBusy) return;
    state = state.copyWith(isAnonymous: v);
  }

  void setCoverFees(bool v) {
    if (state.isBusy) return;
    state = state.copyWith(coverFees: v);
  }

  void setMethod(PaymentMethodKind m) {
    if (state.isBusy) return;
    state = state.copyWith(method: m);
    analytics.trackButtonClick('payment_method_${m.value}', screen: 'checkout');
  }

  /// Display-only estimate (server value wins, see [CheckoutState.quotedFee]).
  double get estimatedFee =>
      state.coverFees ? FeePolicy.estimate(state.amount, state.method) : 0;

  double get estimatedCharged => _round2(state.amount + estimatedFee);

  // ── Pay ─────────────────────────────────────────────────────────────────────

  /// Runs the full flow: create intent/subscription → native confirmation →
  /// wait for the webhook. [currency] / [projectTitle] come from the loaded
  /// project (needed for the wallet sheet label).
  Future<void> pay({required String currency, required String projectTitle}) async {
    if (state.isBusy) return;
    if (!repo.isStripeConfigured) {
      appEvents.send(_failure(ApiErrorKey.paymentIntentFailed));
      return;
    }
    if (state.amount < FeePolicy.minAmount) {
      appEvents.send(_failure(ApiErrorKey.paymentAmountTooSmall));
      return;
    }

    _stopTracking();
    _clientKey = const Uuid().v4();
    state = state.copyWith(
      phase: CheckoutPhase.preparing,
      timedOut: false,
      clearIds: true,
    );
    analytics.trackButtonClick('checkout_pay', screen: 'checkout');

    // 1. Backend creates the money row + Stripe object.
    late final String clientSecret;
    late final double amountCharged;
    String? customerId;
    String? ephemeralKey;

    if (state.isRecurring) {
      final res = await repo.createSubscription(
        projectId: args.projectId,
        amount: state.amount,
        currency: currency,
        frequency: state.frequency,
        coverFees: state.coverFees,
        isAnonymous: state.isAnonymous,
        paymentMethod: state.method,
        clientKey: _clientKey!,
      );
      final created = res.when((v) => v, (error) {
        appEvents.send(ShowErrorEvent(error));
        state = state.copyWith(phase: CheckoutPhase.idle);
        return null;
      });
      if (created == null) return;
      clientSecret = created.clientSecret;
      amountCharged = created.amountCharged;
      customerId = created.customerId;
      ephemeralKey = created.ephemeralKeySecret;
      state = state.copyWith(
        subscriptionId: created.subscriptionId,
        quotedFee: created.fee,
        quotedCharged: created.amountCharged,
      );
    } else {
      final res = await repo.createPaymentIntent(
        type: state.isZakat ? TxType.zakat : TxType.donation,
        currency: currency,
        items: [PaymentItem(projectId: args.projectId, amount: state.amount)],
        coverFees: state.coverFees,
        isAnonymous: state.isAnonymous,
        paymentMethod: state.method,
        clientKey: _clientKey!,
      );
      final created = res.when((v) => v, (error) {
        appEvents.send(ShowErrorEvent(error));
        state = state.copyWith(phase: CheckoutPhase.idle);
        return null;
      });
      if (created == null) return;
      clientSecret = created.clientSecret;
      amountCharged = created.amountCharged;
      state = state.copyWith(
        transactionId: created.transactionId,
        quotedFee: created.fee,
        quotedCharged: created.amountCharged,
      );
    }
    if (!mounted) return;

    // 2. Native confirmation. Completion is NOT proof of payment.
    final result = await repo.confirm(
      method: state.method,
      clientSecret: clientSecret,
      amount: amountCharged,
      currency: currency,
      label: projectTitle,
      customerId: customerId,
      customerEphemeralKeySecret: ephemeralKey,
    );
    if (!mounted) return;

    switch (result) {
      case PaymentSheetResult.cancelled:
        // Back to the editable form. The abandoned pending row is expired
        // server-side (fn_expire_pending_transactions); a retry gets a fresh
        // clientKey because the amount/options may have changed.
        state = state.copyWith(phase: CheckoutPhase.idle, clearIds: true);
        analytics.trackButtonClick('checkout_cancelled', screen: 'checkout');
        return;
      case PaymentSheetResult.failed:
        appEvents.send(_failure(ApiErrorKey.paymentSheetFailed));
        state = state.copyWith(phase: CheckoutPhase.failed);
        return;
      case PaymentSheetResult.completed:
        break;
    }

    // 3. Wait for the webhook — the single authority.
    state = state.copyWith(phase: CheckoutPhase.processing);
    _track();
  }

  /// Called by the page when the app returns to the foreground (wallet sheet,
  /// PayPal browser). Realtime may have been paused meanwhile.
  Future<void> onAppResumed() async {
    if (state.phase != CheckoutPhase.processing) return;
    await _pollOnce();
  }

  /// "Keep waiting" after a timeout.
  void keepWaiting() {
    if (state.phase != CheckoutPhase.processing) return;
    state = state.copyWith(timedOut: false);
    _armTimeout();
  }

  /// Reset back to the editable form (after a failure).
  void reset() {
    _stopTracking();
    state = state.copyWith(
      phase: CheckoutPhase.idle,
      timedOut: false,
      clearIds: true,
    );
  }

  // ── Tracking ────────────────────────────────────────────────────────────────

  void _track() {
    _stopTracking();
    final txId = state.transactionId;
    final subId = state.subscriptionId;

    if (subId != null) {
      _subSub = repo.watchSubscriptionStatus(subId).listen(_applySubStatus);
    } else if (txId != null) {
      _txSub = repo.watchTransactionStatus(txId).listen(_applyTxStatus);
    }

    // Belt and braces: poll in case the realtime channel drops.
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
      _applySubStatus(await repo.fetchSubscriptionStatus(subId));
    } else if (txId != null) {
      _applyTxStatus(await repo.fetchTransactionStatus(txId));
    }
  }

  void _applyTxStatus(TxStatus status) {
    if (!mounted || state.phase != CheckoutPhase.processing) return;
    switch (status) {
      case TxStatus.succeeded:
        _stopTracking();
        state = state.copyWith(phase: CheckoutPhase.success);
        analytics.trackButtonClick('donation_succeeded', screen: 'checkout');
      case TxStatus.failed:
      case TxStatus.refunded:
        _stopTracking();
        appEvents.send(_failure(ApiErrorKey.paymentSheetFailed));
        state = state.copyWith(phase: CheckoutPhase.failed);
      case TxStatus.pending:
      case TxStatus.processing:
        break; // stay in processing
    }
  }

  void _applySubStatus(SubscriptionStatus status) {
    if (!mounted || state.phase != CheckoutPhase.processing) return;
    switch (status) {
      case SubscriptionStatus.active:
        _stopTracking();
        state = state.copyWith(phase: CheckoutPhase.success);
        analytics.trackButtonClick('subscription_created', screen: 'checkout');
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

  ShowErrorEvent _failure(ApiErrorKey key) => ShowErrorEvent(
        ServerFailure(
          exception: ServerException(type: .badRequest, messageKey: key),
        ),
      );

  static double _round2(double v) => (v * 100).roundToDouble() / 100;

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}
