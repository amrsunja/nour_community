import 'package:equatable/equatable.dart';

/// Mirrors `public.tx_type`. The payment cause — kept strictly separate from
/// zakat through to payout (never mixed).
enum TxType {
  zakat,
  donation;

  static TxType fromString(String value) => switch (value) {
    'zakat' => TxType.zakat,
    _ => TxType.donation,
  };

  String get value => name;
}

/// Mirrors `public.tx_status`. Lifecycle of a Stripe-backed transaction.
enum TxStatus {
  pending,
  processing,
  succeeded,
  failed,
  refunded;

  static TxStatus fromString(String value) => switch (value) {
    'processing' => TxStatus.processing,
    'succeeded' => TxStatus.succeeded,
    'failed' => TxStatus.failed,
    'refunded' => TxStatus.refunded,
    _ => TxStatus.pending,
  };

  String get value => name;

  bool get isTerminal =>
      this == succeeded || this == failed || this == refunded;
}

/// Mirrors `public.payout_method`.
enum PayoutMethod {
  bank,
  wise,
  cash,
  other;

  static PayoutMethod fromString(String value) => switch (value) {
    'bank' => PayoutMethod.bank,
    'wise' => PayoutMethod.wise,
    'cash' => PayoutMethod.cash,
    _ => PayoutMethod.other,
  };

  String get value => name;
}

/// Mirrors `public.payout_status`.
enum PayoutStatus {
  pending,
  sent,
  confirmed;

  static PayoutStatus fromString(String value) => switch (value) {
    'sent' => PayoutStatus.sent,
    'confirmed' => PayoutStatus.confirmed,
    _ => PayoutStatus.pending,
  };

  String get value => name;
}

/// The payment method picked on the Checkout page. Every value runs on the
/// same Stripe PaymentIntent pipeline; only the confirmation call differs
/// (see `StripePaymentService`). Wire values match the edge functions.
enum PaymentMethodKind {
  card('card'),
  applePay('apple_pay'),
  googlePay('google_pay'),
  paypal('paypal');

  const PaymentMethodKind(this.value);

  final String value;

  static PaymentMethodKind fromString(String? value) => switch (value) {
    'apple_pay' => PaymentMethodKind.applePay,
    'google_pay' => PaymentMethodKind.googlePay,
    'paypal' => PaymentMethodKind.paypal,
    _ => PaymentMethodKind.card,
  };

  /// Wallets and PayPal hand the payment off to a native / browser surface.
  bool get isRedirectBased => this == paypal;
}

/// How often the donor gives. `oneTime` = a single PaymentIntent; the others
/// create a Stripe Subscription (`public.donation_subscriptions`).
enum DonationFrequency {
  yearly,
  monthly,
  oneTime;

  bool get isRecurring => this != oneTime;

  /// Stripe / DB interval for recurring values (`month` | `year`).
  String? get interval => switch (this) {
    DonationFrequency.monthly => 'month',
    DonationFrequency.yearly => 'year',
    DonationFrequency.oneTime => null,
  };

  static DonationFrequency fromInterval(String? interval) => switch (interval) {
    'month' => DonationFrequency.monthly,
    'year' => DonationFrequency.yearly,
    _ => DonationFrequency.oneTime,
  };
}

/// Mirrors `public.subscription_status`.
enum SubscriptionStatus {
  incomplete,
  active,
  pastDue,
  canceled,
  unpaid,
  paused;

  static SubscriptionStatus fromString(String? value) => switch (value) {
    'active' => SubscriptionStatus.active,
    'past_due' => SubscriptionStatus.pastDue,
    'canceled' => SubscriptionStatus.canceled,
    'unpaid' => SubscriptionStatus.unpaid,
    'paused' => SubscriptionStatus.paused,
    _ => SubscriptionStatus.incomplete,
  };

  bool get isLive => this == active || this == pastDue;
}

/// A single line the donor is funding: a project + an amount. The client builds
/// these; the server re-validates every one before charging. Equatable so it
/// can live inside provider-family arguments (CheckoutArgs).
class PaymentItem extends Equatable {
  const PaymentItem({required this.projectId, required this.amount});

  final int projectId;
  final double amount;

  Map<String, dynamic> toJson() => {
    'project_id': projectId,
    'amount': amount,
  };

  @override
  List<Object?> get props => [projectId, amount];
}
