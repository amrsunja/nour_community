import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

/// One row of `fn_admin_project_analytics()` — donation aggregates for a single
/// (project, type) pair. Zakat and Donation are reported on separate rows.
class ProjectAnalyticsModel extends Equatable {
  final int projectId;
  final int organizationId;
  final TxType type;
  final int donorsCount;
  final double totalDonated;
  final double paidOut;
  final double outstanding;

  const ProjectAnalyticsModel({
    required this.projectId,
    required this.organizationId,
    required this.type,
    required this.donorsCount,
    required this.totalDonated,
    required this.paidOut,
    required this.outstanding,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);

  factory ProjectAnalyticsModel.fromJson(Json json) => ProjectAnalyticsModel(
    projectId: _toInt(json['project_id']),
    organizationId: _toInt(json['organization_id']),
    type: TxType.fromString(json['type'] as String),
    donorsCount: _toInt(json['donors_count']),
    totalDonated: _toDouble(json['total_donated']),
    paidOut: _toDouble(json['paid_out']),
    outstanding: _toDouble(json['outstanding']),
  );

  @override
  List<Object?> get props => [
    projectId,
    organizationId,
    type,
    donorsCount,
    totalDonated,
    paidOut,
    outstanding,
  ];
}
