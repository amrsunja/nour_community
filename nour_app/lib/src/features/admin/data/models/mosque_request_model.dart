import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';

/// Row of `fn_admin_mosque_requests` (Nour admin moderation).
class MosqueRequestModel extends Equatable {
  final int id;
  final String name;
  final String? legalName;
  final MosqueLegalStatus? legalStatus;
  final String? rna;
  final String? siren;
  final String countryCode;
  final MosqueStatus status;
  final String? reviewNote;
  final DateTime createdAt;
  final String? ownerId;
  final String? ownerEmail;
  final String? ownerName;
  final bool duplicateSiren;

  const MosqueRequestModel({
    required this.id,
    required this.name,
    this.legalName,
    this.legalStatus,
    this.rna,
    this.siren,
    this.countryCode = 'FR',
    required this.status,
    this.reviewNote,
    required this.createdAt,
    this.ownerId,
    this.ownerEmail,
    this.ownerName,
    this.duplicateSiren = false,
  });

  factory MosqueRequestModel.fromJson(Json json) => MosqueRequestModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        legalName: json['legal_name'] as String?,
        legalStatus: json['legal_status'] == null ? null : MosqueLegalStatus.fromDb(json['legal_status'] as String?),
        rna: json['rna'] as String?,
        siren: json['siren'] as String?,
        countryCode: json['country_code'] as String? ?? 'FR',
        status: MosqueStatus.fromDb(json['status'] as String?),
        reviewNote: json['review_note'] as String?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        ownerId: json['owner_id'] as String?,
        ownerEmail: json['owner_email'] as String?,
        ownerName: json['owner_name'] as String?,
        duplicateSiren: json['duplicate_siren'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, legalName, legalStatus, rna, siren, countryCode, status, reviewNote, createdAt, ownerId, ownerEmail, ownerName, duplicateSiren];
}
