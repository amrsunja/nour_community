import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Verified partner running an impact project (mirrors
/// `public.partner_organizations`).
class PartnerOrganizationModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String? nameDe;
  final String? nameNl;
  final String? nameTr;
  final String? nameId;
  final String? nameUr;
  final String? nameBn;
  final String? nameMs;
  final String? avatarUrl;
  final bool isVerified;

  const PartnerOrganizationModel({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    this.nameDe,
    this.nameNl,
    this.nameTr,
    this.nameId,
    this.nameUr,
    this.nameBn,
    this.nameMs,
    this.avatarUrl,
    required this.isVerified,
  });

  factory PartnerOrganizationModel.fromJson(Json json) =>
      PartnerOrganizationModel(
        id: json['id'],
        nameEn: json['name_en'] ?? '',
        nameFr: json['name_fr'] ?? '',
        nameAr: json['name_ar'] ?? '',
        nameDe: json['name_de'],
        nameNl: json['name_nl'],
        nameTr: json['name_tr'],
        nameId: json['name_id'],
        nameUr: json['name_ur'],
        nameBn: json['name_bn'],
        nameMs: json['name_ms'],
        avatarUrl: json['avatar_url'],
        isVerified: json['is_verified'] ?? false,
      );

  String name(String langCode) => switch (langCode) {
    'fr' => nameFr,
    'ar' => nameAr,
    'de' => nameDe.orLoc(nameEn),
    'nl' => nameNl.orLoc(nameEn),
    'tr' => nameTr.orLoc(nameEn),
    'id' => nameId.orLoc(nameEn),
    'ur' => nameUr.orLoc(nameEn),
    'bn' => nameBn.orLoc(nameEn),
    'ms' => nameMs.orLoc(nameEn),
    _ => nameEn,
  };

  @override
  List<Object?> get props => [
    id,
    nameEn,
    nameFr,
    nameAr,
    nameDe,
    nameNl,
    nameTr,
    nameId,
    nameUr,
    nameBn,
    nameMs,
    avatarUrl,
    isVerified,
  ];
}
