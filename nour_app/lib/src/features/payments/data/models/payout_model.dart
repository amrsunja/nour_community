import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'tx_enums.dart';

/// One row of `public.payouts` — a manual reversal (owner -> partner). Used by
/// both the admin ledger and the public project transparency section (where
/// only `confirmed` rows are visible via RLS).
class PayoutModel extends Equatable {
  final int id;
  final int organizationId;
  final int? impactProjectId;
  final TxType type;
  final double amount;
  final String currency;
  final PayoutMethod method;
  final PayoutStatus status;
  final String? reference;
  final String? proofPath; // object path in the payout-proofs bucket
  final String? note;
  final DateTime? executedAt;
  final DateTime createdAt;

  const PayoutModel({
    required this.id,
    required this.organizationId,
    required this.impactProjectId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.reference,
    required this.proofPath,
    required this.note,
    required this.executedAt,
    required this.createdAt,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  factory PayoutModel.fromJson(Json json) => PayoutModel(
    id: json['id'] as int,
    organizationId: json['organization_id'] as int,
    impactProjectId: json['impact_project_id'] as int?,
    type: TxType.fromString(json['type'] as String),
    amount: _toDouble(json['amount']),
    currency: json['currency'] as String? ?? 'EUR',
    method: PayoutMethod.fromString(json['method'] as String),
    status: PayoutStatus.fromString(json['status'] as String),
    reference: json['reference'] as String?,
    proofPath: json['proof_url'] as String?,
    note: json['note'] as String?,
    executedAt: DateTime.tryParse(json['executed_at'] ?? ''),
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
  );

  bool get hasProof => proofPath != null && proofPath!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    organizationId,
    impactProjectId,
    type,
    amount,
    currency,
    method,
    status,
    reference,
    proofPath,
    note,
    executedAt,
    createdAt,
  ];
}
