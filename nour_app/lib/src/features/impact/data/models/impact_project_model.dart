import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'partner_organization_model.dart';
import 'project_category_model.dart';
import 'project_story_model.dart';

/// An impact project (mirrors `public.impact_projects`).
///
/// [organization], [category] and [stories] are only populated by the detail
/// query (embedded selects); list queries leave them null / empty.
class ImpactProjectModel extends Equatable {
  final int id;
  final int organizationId;
  final int categoryId;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final String subtitleEn;
  final String subtitleFr;
  final String subtitleAr;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String? coverImageUrl;
  final double requiredAmount;
  final double collectedAmount;
  final String currency;
  final int donorsCount;
  final bool eligibleForZakat;
  final int position;

  final PartnerOrganizationModel? organization;
  final ProjectCategoryModel? category;
  final List<ProjectStoryModel> stories;

  const ImpactProjectModel({
    required this.id,
    required this.organizationId,
    required this.categoryId,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleFr,
    required this.subtitleAr,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.coverImageUrl,
    required this.requiredAmount,
    required this.collectedAmount,
    required this.currency,
    required this.donorsCount,
    required this.eligibleForZakat,
    required this.position,
    this.organization,
    this.category,
    this.stories = const [],
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  factory ImpactProjectModel.fromJson(Json json) {
    final org = json['partner_organizations'];
    final cat = json['project_categories'];
    final stories = json['project_stories'];

    return ImpactProjectModel(
      id: json['id'],
      organizationId: json['organization_id'],
      categoryId: json['project_category_id'],
      titleEn: json['title_en'] ?? '',
      titleFr: json['title_fr'] ?? '',
      titleAr: json['title_ar'] ?? '',
      subtitleEn: json['subtitle_en'] ?? '',
      subtitleFr: json['subtitle_fr'] ?? '',
      subtitleAr: json['subtitle_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionFr: json['description_fr'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      coverImageUrl: json['cover_image_url'],
      requiredAmount: _toDouble(json['required_amount']),
      collectedAmount: _toDouble(json['collected_amount']),
      currency: json['currency'] ?? 'EUR',
      donorsCount: json['donors_count'] ?? 0,
      eligibleForZakat: json['eligible_for_zakat'] ?? false,
      position: json['position'] ?? 0,
      organization: org is Map<String, dynamic>
          ? PartnerOrganizationModel.fromJson(org)
          : null,
      category: cat is Map<String, dynamic>
          ? ProjectCategoryModel.fromJson(cat)
          : null,
      stories: [
        if (stories is List)
          for (final s in stories)
            if (s is Map<String, dynamic>) ProjectStoryModel.fromJson(s),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  String title(String langCode) => switch (langCode) {
    'fr' => titleFr,
    'ar' => titleAr,
    _ => titleEn,
  };

  String subtitle(String langCode) => switch (langCode) {
    'fr' => subtitleFr,
    'ar' => subtitleAr,
    _ => subtitleEn,
  };

  String description(String langCode) => switch (langCode) {
    'fr' => descriptionFr,
    'ar' => descriptionAr,
    _ => descriptionEn,
  };

  /// Funding progress in `[0, 1]`.
  double get progress => requiredAmount <= 0
      ? 0
      : (collectedAmount / requiredAmount).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
    id,
    organizationId,
    categoryId,
    titleEn,
    titleFr,
    titleAr,
    subtitleEn,
    subtitleFr,
    subtitleAr,
    descriptionEn,
    descriptionFr,
    descriptionAr,
    coverImageUrl,
    requiredAmount,
    collectedAmount,
    currency,
    donorsCount,
    eligibleForZakat,
    position,
    organization,
    category,
    stories,
  ];
}
