import 'package:nour/src/features/payments/data/models/tx_enums.dart';

/// Input to record a manual disbursement (payout) to a partner. The proof image
/// (if any) is uploaded separately to the `payout-proofs` bucket first, and its
/// object path is passed here as [proofPath].
class RecordPayoutParams {
  const RecordPayoutParams({
    required this.organizationId,
    required this.impactProjectId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.reference,
    this.proofPath,
    this.note,
    this.executedAt,
  });

  final int organizationId;
  final int? impactProjectId;
  final TxType type;
  final double amount;
  final String currency;
  final PayoutMethod method;
  final PayoutStatus status;
  final String? reference;
  final String? proofPath;
  final String? note;
  final DateTime? executedAt;

  Map<String, dynamic> toInsert(String createdBy) => {
    'organization_id': organizationId,
    'impact_project_id': impactProjectId,
    'type': type.value,
    'amount': amount,
    'currency': currency,
    'method': method.value,
    'status': status.value,
    if (reference != null && reference!.isNotEmpty) 'reference': reference,
    if (proofPath != null && proofPath!.isNotEmpty) 'proof_url': proofPath,
    if (note != null && note!.isNotEmpty) 'note': note,
    if (executedAt != null) 'executed_at': executedAt!.toUtc().toIso8601String(),
    'created_by': createdBy,
  };
}
