import 'package:equatable/equatable.dart';

import '../../data/models/tx_enums.dart';

/// The checkout is a small state machine driven by [CheckoutPhase].
///
/// idle        → form editable
/// preparing   → creating the PaymentIntent / Subscription + running the
///               native confirmation (PaymentSheet, wallet, PayPal browser)
/// processing  → confirmation UI finished; waiting for the webhook (truth)
/// success     → webhook flipped the tx to `succeeded` (or sub → active)
/// failed      → payment failed (sheet error, webhook `failed`, or timeout)
/// cancelled   → user dismissed the native surface (back to idle-like form)
enum CheckoutPhase { idle, preparing, processing, success, failed, cancelled }

class CheckoutState extends Equatable {
  final double amount;
  final DonationFrequency frequency;
  final bool isZakat;
  final bool isAnonymous;
  final bool coverFees;
  final PaymentMethodKind method;
  final bool applePayAvailable;
  final bool googlePayAvailable;
  final bool paypalAvailable;
  final CheckoutPhase phase;

  /// Set once the backend created the money row (one-time / recurring).
  final int? transactionId;
  final int? subscriptionId;

  /// Server-quoted numbers for the attempt in flight (or just confirmed).
  final double? quotedFee;
  final double? quotedCharged;

  /// True while a timeout was hit and the UI offers to keep waiting.
  final bool timedOut;

  const CheckoutState({
    required this.amount,
    required this.frequency,
    required this.isZakat,
    this.isAnonymous = false,
    this.coverFees = false,
    this.method = PaymentMethodKind.card,
    this.applePayAvailable = false,
    this.googlePayAvailable = false,
    this.paypalAvailable = true,
    this.phase = CheckoutPhase.idle,
    this.transactionId,
    this.subscriptionId,
    this.quotedFee,
    this.quotedCharged,
    this.timedOut = false,
  });

  bool get isBusy =>
      phase == CheckoutPhase.preparing || phase == CheckoutPhase.processing;

  bool get isRecurring => frequency.isRecurring;

  CheckoutState copyWith({
    double? amount,
    DonationFrequency? frequency,
    bool? isZakat,
    bool? isAnonymous,
    bool? coverFees,
    PaymentMethodKind? method,
    bool? applePayAvailable,
    bool? googlePayAvailable,
    bool? paypalAvailable,
    CheckoutPhase? phase,
    int? transactionId,
    int? subscriptionId,
    double? quotedFee,
    double? quotedCharged,
    bool? timedOut,
    bool clearIds = false,
  }) => CheckoutState(
    amount: amount ?? this.amount,
    frequency: frequency ?? this.frequency,
    isZakat: isZakat ?? this.isZakat,
    isAnonymous: isAnonymous ?? this.isAnonymous,
    coverFees: coverFees ?? this.coverFees,
    method: method ?? this.method,
    applePayAvailable: applePayAvailable ?? this.applePayAvailable,
    googlePayAvailable: googlePayAvailable ?? this.googlePayAvailable,
    paypalAvailable: paypalAvailable ?? this.paypalAvailable,
    phase: phase ?? this.phase,
    transactionId: clearIds ? null : (transactionId ?? this.transactionId),
    subscriptionId: clearIds ? null : (subscriptionId ?? this.subscriptionId),
    quotedFee: clearIds ? null : (quotedFee ?? this.quotedFee),
    quotedCharged: clearIds ? null : (quotedCharged ?? this.quotedCharged),
    timedOut: timedOut ?? this.timedOut,
  );

  @override
  List<Object?> get props => [
    amount,
    frequency,
    isZakat,
    isAnonymous,
    coverFees,
    method,
    applePayAvailable,
    googlePayAvailable,
    paypalAvailable,
    phase,
    transactionId,
    subscriptionId,
    quotedFee,
    quotedCharged,
    timedOut,
  ];
}
