import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// One line of `public.transaction_items` — a per-project slice of a
/// transaction's `amount_total`.
class TransactionItemModel extends Equatable {
  final int id;
  final int transactionId;
  final int impactProjectId;
  final double amount;

  const TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.impactProjectId,
    required this.amount,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  factory TransactionItemModel.fromJson(Json json) => TransactionItemModel(
    id: json['id'] as int,
    transactionId: json['transaction_id'] as int,
    impactProjectId: json['impact_project_id'] as int,
    amount: _toDouble(json['amount']),
  );

  @override
  List<Object?> get props => [id, transactionId, impactProjectId, amount];
}
