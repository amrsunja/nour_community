import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';

/// Row of `fn_admin_donation_verifications` (Nour admin moderation).
class DonationVerificationRequestModel extends Equatable {
  final int mosqueId;
  final String mosqueName;
  final String countryCode;
  final MosqueDonationVerificationStatus status;
  final String benevityCharityId;
  final String legalName;
  final String? certificateUrl;
  final String? notes;
  final DateTime submittedAt;
  final String? reviewNote;
  final String? ownerEmail;
  final String? ownerName;
  final bool chargesEnabled;

  const DonationVerificationRequestModel({
    required this.mosqueId,
    required this.mosqueName,
    this.countryCode = 'FR',
    required this.status,
    required this.benevityCharityId,
    required this.legalName,
    this.certificateUrl,
    this.notes,
    required this.submittedAt,
    this.reviewNote,
    this.ownerEmail,
    this.ownerName,
    this.chargesEnabled = false,
  });

  /// Null unless it parses as a web link: the value is typed by the mosque.
  Uri? get certificateUri {
    final uri = Uri.tryParse(certificateUrl ?? '');
    return uri != null && (uri.isScheme('http') || uri.isScheme('https')) ? uri : null;
  }

  factory DonationVerificationRequestModel.fromJson(Json json) => DonationVerificationRequestModel(
        mosqueId: json['mosque_id'] as int,
        mosqueName: json['mosque_name'] as String? ?? '',
        countryCode: json['country_code'] as String? ?? 'FR',
        status: MosqueDonationVerificationStatus.fromString(json['status'] as String?),
        benevityCharityId: json['benevity_charity_id'] as String? ?? '',
        legalName: json['legal_name'] as String? ?? '',
        certificateUrl: json['certificate_url'] as String?,
        notes: json['notes'] as String?,
        submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? '') ?? DateTime.now(),
        reviewNote: json['review_note'] as String?,
        ownerEmail: json['owner_email'] as String?,
        ownerName: json['owner_name'] as String?,
        chargesEnabled: json['charges_enabled'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        mosqueId, mosqueName, countryCode, status, benevityCharityId, legalName, certificateUrl, notes,
        submittedAt, reviewNote, ownerEmail, ownerName, chargesEnabled,
      ];
}
