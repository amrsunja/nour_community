import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Verified partner running an impact project (mirrors
/// `public.partner_organizations`).
class PartnerOrganizationModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String? avatarUrl;
  final bool isVerified;

  const PartnerOrganizationModel({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    this.avatarUrl,
    required this.isVerified,
  });

  factory PartnerOrganizationModel.fromJson(Json json) =>
      PartnerOrganizationModel(
        id: json['id'],
        nameEn: json['name_en'] ?? '',
        nameFr: json['name_fr'] ?? '',
        nameAr: json['name_ar'] ?? '',
        avatarUrl: json['avatar_url'],
        isVerified: json['is_verified'] ?? false,
      );

  String name(String langCode) => switch (langCode) {
    'fr' => nameFr,
    'ar' => nameAr,
    _ => nameEn,
  };

  @override
  List<Object?> get props => [id, nameEn, nameFr, nameAr, avatarUrl, isVerified];
}
