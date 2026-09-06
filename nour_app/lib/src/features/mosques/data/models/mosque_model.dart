import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'mosque_enums.dart';
import 'mosque_imam_model.dart';

/// Row of `public.mosques` (+ optional embedded `mosque_imams(*)`).
class MosqueModel extends Equatable {
  final int id;
  final String name;
  final String? legalName;
  final MosqueLegalStatus? legalStatus;
  final String? rna;
  final String? siren;
  final String countryCode;
  final String defaultLanguage;
  final MosqueStatus status;
  final String? reviewNote;
  final String? slug;
  final String? logoUrl;
  final List<String> coverImages;
  final String? description;
  final String? addressLine;
  final String? city;
  final String? postalCode;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? email;
  final String? website;
  final Map<String, String> socials;
  final int? capacityTotal;
  final int? capacityMen;
  final int? capacityWomen;
  final int? foundedYear;
  final List<MosqueService> services;
  final List<String> khutbahLanguages;
  final String timezone;
  final String? openingStatus;
  final bool donationsEnabled;
  final bool canIssueTaxReceipts;
  final int followersCount;
  final int membersCount;
  final int viewsCount;
  final List<MosqueImamModel> imams;
  final DateTime? createdAt;

  const MosqueModel({
    required this.id,
    required this.name,
    this.legalName,
    this.legalStatus,
    this.rna,
    this.siren,
    this.countryCode = 'FR',
    this.defaultLanguage = 'fr',
    this.status = MosqueStatus.pendingReview,
    this.reviewNote,
    this.slug,
    this.logoUrl,
    this.coverImages = const [],
    this.description,
    this.addressLine,
    this.city,
    this.postalCode,
    this.lat,
    this.lng,
    this.phone,
    this.email,
    this.website,
    this.socials = const {},
    this.capacityTotal,
    this.capacityMen,
    this.capacityWomen,
    this.foundedYear,
    this.services = const [],
    this.khutbahLanguages = const [],
    this.timezone = 'Europe/Paris',
    this.openingStatus,
    this.donationsEnabled = false,
    this.canIssueTaxReceipts = false,
    this.followersCount = 0,
    this.membersCount = 0,
    this.viewsCount = 0,
    this.imams = const [],
    this.createdAt,
  });

  String get fullAddress {
    final parts = [
      addressLine,
      [postalCode, city].where((e) => e != null && e.isNotEmpty).join(' '),
    ].where((e) => e != null && e.isNotEmpty);
    return parts.join(', ');
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
  }

  bool get hasLocation => lat != null && lng != null;

  String get deepLink => 'nour://mosque/$id';

  /// Parses PostGIS geography returned either as GeoJSON (`{type:Point,
  /// coordinates:[lng,lat]}`) or as the `lat`/`lng` columns of an RPC.
  static (double?, double?) _latLng(Json json) {
    if (json['lat'] != null && json['lng'] != null) {
      return ((json['lat'] as num).toDouble(), (json['lng'] as num).toDouble());
    }
    final loc = json['location'];
    if (loc is Map && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
      final c = loc['coordinates'] as List;
      return ((c[1] as num).toDouble(), (c[0] as num).toDouble());
    }
    return (null, null);
  }

  factory MosqueModel.fromJson(Json json) {
    final (lat, lng) = _latLng(json);
    return MosqueModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      legalName: json['legal_name'] as String?,
      legalStatus: json['legal_status'] == null ? null : MosqueLegalStatus.fromDb(json['legal_status'] as String?),
      rna: json['rna'] as String?,
      siren: json['siren'] as String?,
      countryCode: json['country_code'] as String? ?? 'FR',
      defaultLanguage: json['default_language'] as String? ?? 'fr',
      status: MosqueStatus.fromDb(json['status'] as String?),
      reviewNote: json['review_note'] as String?,
      slug: json['slug'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverImages: (json['cover_images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      description: json['description'] as String?,
      addressLine: json['address_line'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      lat: lat,
      lng: lng,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      socials: (json['socials'] as Map?)?.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')) ?? const {},
      capacityTotal: json['capacity_total'] as int?,
      capacityMen: json['capacity_men'] as int?,
      capacityWomen: json['capacity_women'] as int?,
      foundedYear: json['founded_year'] as int?,
      services: MosqueService.listFromDb(json['services']),
      khutbahLanguages: (json['khutbah_languages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      timezone: json['timezone'] as String? ?? 'Europe/Paris',
      openingStatus: json['opening_status'] as String?,
      donationsEnabled: json['donations_enabled'] as bool? ?? false,
      canIssueTaxReceipts: json['can_issue_tax_receipts'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      membersCount: json['members_count'] as int? ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      imams: (json['mosque_imams'] as List?)
              ?.map((e) => MosqueImamModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  MosqueModel copyWith({
    String? name,
    String? logoUrl,
    List<String>? coverImages,
    String? description,
    String? addressLine,
    String? city,
    String? postalCode,
    double? lat,
    double? lng,
    String? phone,
    String? email,
    String? website,
    Map<String, String>? socials,
    int? capacityTotal,
    int? capacityMen,
    int? capacityWomen,
    int? foundedYear,
    List<MosqueService>? services,
    List<String>? khutbahLanguages,
    String? openingStatus,
    MosqueStatus? status,
    int? followersCount,
    int? membersCount,
    List<MosqueImamModel>? imams,
    bool? donationsEnabled,
    bool? canIssueTaxReceipts,
  }) {
    return MosqueModel(
      id: id,
      name: name ?? this.name,
      legalName: legalName,
      legalStatus: legalStatus,
      rna: rna,
      siren: siren,
      countryCode: countryCode,
      defaultLanguage: defaultLanguage,
      status: status ?? this.status,
      reviewNote: reviewNote,
      slug: slug,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImages: coverImages ?? this.coverImages,
      description: description ?? this.description,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      socials: socials ?? this.socials,
      capacityTotal: capacityTotal ?? this.capacityTotal,
      capacityMen: capacityMen ?? this.capacityMen,
      capacityWomen: capacityWomen ?? this.capacityWomen,
      foundedYear: foundedYear ?? this.foundedYear,
      services: services ?? this.services,
      khutbahLanguages: khutbahLanguages ?? this.khutbahLanguages,
      timezone: timezone,
      openingStatus: openingStatus ?? this.openingStatus,
      donationsEnabled: donationsEnabled ?? this.donationsEnabled,
      canIssueTaxReceipts: canIssueTaxReceipts ?? this.canIssueTaxReceipts,
      followersCount: followersCount ?? this.followersCount,
      membersCount: membersCount ?? this.membersCount,
      viewsCount: viewsCount,
      imams: imams ?? this.imams,
      createdAt: createdAt,
    );
  }

  /// Columns a mosque admin is allowed to update (guard trigger rejects the rest).
  Json toProfileUpdateJson() => {
        'name': name,
        'logo_url': logoUrl,
        'cover_images': coverImages,
        'description': description,
        'address_line': addressLine,
        'city': city,
        'postal_code': postalCode,
        if (hasLocation) 'location': 'POINT($lng $lat)',
        'phone': phone,
        'email': email,
        'website': website,
        'socials': socials,
        'capacity_total': capacityTotal,
        'capacity_men': capacityMen,
        'capacity_women': capacityWomen,
        'founded_year': foundedYear,
        'services': services.map((e) => e.dbValue).toList(),
        'khutbah_languages': khutbahLanguages,
        'opening_status': openingStatus,
        'can_issue_tax_receipts': canIssueTaxReceipts,
      };

  @override
  List<Object?> get props => [
        id, name, legalName, legalStatus, rna, siren, countryCode, defaultLanguage, status, reviewNote, slug,
        logoUrl, coverImages, description, addressLine, city, postalCode, lat, lng, phone, email, website, socials,
        capacityTotal, capacityMen, capacityWomen, foundedYear, services, khutbahLanguages, timezone, openingStatus,
        donationsEnabled, canIssueTaxReceipts, followersCount, membersCount, viewsCount, imams, createdAt,
      ];
}
