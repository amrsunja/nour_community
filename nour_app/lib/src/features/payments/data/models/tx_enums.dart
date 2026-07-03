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

/// A single line the donor is funding: a project + an amount. The client builds
/// these; the server re-validates every one before charging.
class PaymentItem {
  const PaymentItem({required this.projectId, required this.amount});

  final int projectId;
  final double amount;

  Map<String, dynamic> toJson() => {
    'project_id': projectId,
    'amount': amount,
  };
}
