import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../data/models/tx_enums.dart';
import '../../data/payment_repo.dart';
import '../../data/services/stripe_payment_service.dart';
import 'donation_state.dart';

/// Auto-disposed per donation attempt (the donate sheet owns it).
final donationProvider =
    StateNotifierProvider.autoDispose<DonationPresenter, DonationState>((ref) {
  return DonationPresenter(
    repo: ref.read(paymentRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class DonationPresenter extends Presenter<DonationState> {
  final PaymentRepo repo;
  final AppEvents appEvents;

  StreamSubscription<TxStatus>? _sub;
  Timer? _fallback;

  DonationPresenter({required this.repo, required this.appEvents})
    : super(const DonationState());

  /// Runs the full flow: create intent → present sheet → track via Realtime.
  /// A single item is the common single-project donation; multiple items is the
  /// zakat-calculator split (one Stripe fee across N projects).
  Future<void> pay({
    required TxType type,
    required String currency,
    required List<PaymentItem> items,
    required bool coverFees,
  }) async {
    if (state.isBusy) return;
    state = state.copyWith(phase: DonationPhase.preparing);

    // 1. Backend creates the PaymentIntent + a pending transaction.
    final res = await repo.createPaymentIntent(
      type: type,
      currency: currency,
      items: items,
      coverFees: coverFees,
    );

    final intent = res.when((v) => v, (error) {
      appEvents.send(ShowErrorEvent(error));
      state = state.copyWith(phase: DonationPhase.failed);
      return null;
    });
    if (intent == null) return;

    state = state.copyWith(transactionId: intent.transactionId);

    // 2. Native PaymentSheet. A completed sheet is NOT proof of payment.
    final sheet = await repo.presentPaymentSheet(intent.clientSecret);
    switch (sheet) {
      case PaymentSheetResult.cancelled:
        state = state.copyWith(phase: DonationPhase.cancelled);
        return;
      case PaymentSheetResult.failed:
        appEvents.send(ShowErrorEvent(
          ServerFailure(
            exception: ServerException(
              type: .badRequest,
              messageKey: ApiErrorKey.paymentSheetFailed,
            ),
          ),
        ));
        state = state.copyWith(phase: DonationPhase.failed);
        return;
      case PaymentSheetResult.completed:
        break;
    }

    // 3. Show "processing" and wait for the webhook (the single authority).
    state = state.copyWith(phase: DonationPhase.processing);
    _trackTransaction(intent.transactionId);
  }

  void _trackTransaction(int transactionId) {
    _sub?.cancel();
    _sub = repo.watchTransactionStatus(transactionId).listen((status) {
      _applyStatus(status);
    });

    // Fallback: re-check with a direct select if the push is slow / app was
    // backgrounded during the wait.
    _fallback?.cancel();
    _fallback = Timer(const Duration(seconds: 45), () async {
      if (state.phase != DonationPhase.processing) return;
      final status = await repo.fetchTransactionStatus(transactionId);
      _applyStatus(status);
    });
  }

  void _applyStatus(TxStatus status) {
    switch (status) {
      case TxStatus.succeeded:
        _stopTracking();
        state = state.copyWith(phase: DonationPhase.success);
      case TxStatus.failed:
      case TxStatus.refunded:
        _stopTracking();
        state = state.copyWith(phase: DonationPhase.failed);
      case TxStatus.pending:
      case TxStatus.processing:
        break; // stay in processing
    }
  }

  void _stopTracking() {
    _sub?.cancel();
    _sub = null;
    _fallback?.cancel();
    _fallback = null;
  }

  /// Reset back to the editable form (e.g. after a cancel or a failure).
  void reset() {
    _stopTracking();
    state = const DonationState();
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}
