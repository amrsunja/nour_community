import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'tx_enums.dart';
import 'transaction_item_model.dart';

/// One row of `public.transactions` (a Stripe PaymentIntent). [items] is only
/// populated when the query embeds `transaction_items`.
class TransactionModel extends Equatable {
  final int id;
  final String userId;
  final TxType type;
  final TxStatus status;
  final String currency;
  final double amountTotal;
  final double feeCovered;
  final double amountCharged;
  final double? netReceived;
  final String? stripePiId;
  final String? failureReason;
  final DateTime createdAt;
  final List<TransactionItemModel> items;

  /// Recurring invoices carry a `subscription_id`.
  bool get isRecurring => subscriptionId != null;

  // ── V2 ──
  final bool isAnonymous;
  final PaymentMethodKind? paymentMethod;
  final int? subscriptionId;
  final double amountRefunded;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.currency,
    required this.amountTotal,
    required this.feeCovered,
    required this.amountCharged,
    required this.netReceived,
    required this.stripePiId,
    required this.failureReason,
    required this.createdAt,
    this.items = const [],
    this.isAnonymous = false,
    this.paymentMethod,
    this.subscriptionId,
    this.amountRefunded = 0,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  factory TransactionModel.fromJson(Json json) {
    final rawItems = json['transaction_items'];
    return TransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      type: TxType.fromString(json['type'] as String),
      status: TxStatus.fromString(json['status'] as String),
      currency: json['currency'] as String? ?? 'EUR',
      amountTotal: _toDouble(json['amount_total']),
      feeCovered: _toDouble(json['fee_covered']),
      amountCharged: _toDouble(json['amount_charged']),
      netReceived: json['net_received'] == null
          ? null
          : _toDouble(json['net_received']),
      stripePiId: json['stripe_pi_id'] as String?,
      failureReason: json['failure_reason'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      items: [
        if (rawItems is List)
          for (final it in rawItems)
            if (it is Map<String, dynamic>)
              TransactionItemModel.fromJson(it),
      ],
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      paymentMethod: json['payment_method'] == null
          ? null
          : PaymentMethodKind.fromString(json['payment_method'] as String?),
      subscriptionId: json['subscription_id'] as int?,
      amountRefunded: _toDouble(json['amount_refunded']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    status,
    currency,
    amountTotal,
    feeCovered,
    amountCharged,
    netReceived,
    stripePiId,
    failureReason,
    createdAt,
    items,
    isAnonymous,
    paymentMethod,
    subscriptionId,
    amountRefunded,
  ];
}
