import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
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
  final String? titleDe;
  final String? titleNl;
  final String? titleTr;
  final String? titleId;
  final String? titleUr;
  final String? titleBn;
  final String? titleMs;
  final String? titleRu;
  final String subtitleEn;
  final String subtitleFr;
  final String subtitleAr;
  final String? subtitleDe;
  final String? subtitleNl;
  final String? subtitleTr;
  final String? subtitleId;
  final String? subtitleUr;
  final String? subtitleBn;
  final String? subtitleMs;
  final String? subtitleRu;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String? descriptionDe;
  final String? descriptionNl;
  final String? descriptionTr;
  final String? descriptionId;
  final String? descriptionUr;
  final String? descriptionBn;
  final String? descriptionMs;
  final String? descriptionRu;
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
    this.titleDe,
    this.titleNl,
    this.titleTr,
    this.titleId,
    this.titleUr,
    this.titleBn,
    this.titleMs,
    this.titleRu,
    required this.subtitleEn,
    required this.subtitleFr,
    required this.subtitleAr,
    this.subtitleDe,
    this.subtitleNl,
    this.subtitleTr,
    this.subtitleId,
    this.subtitleUr,
    this.subtitleBn,
    this.subtitleMs,
    this.subtitleRu,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    this.descriptionDe,
    this.descriptionNl,
    this.descriptionTr,
    this.descriptionId,
    this.descriptionUr,
    this.descriptionBn,
    this.descriptionMs,
    this.descriptionRu,
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
      titleDe: json['title_de'],
      titleNl: json['title_nl'],
      titleTr: json['title_tr'],
      titleId: json['title_id'],
      titleUr: json['title_ur'],
      titleBn: json['title_bn'],
      titleMs: json['title_ms'],
      titleRu: json['title_ru'],
      subtitleEn: json['subtitle_en'] ?? '',
      subtitleFr: json['subtitle_fr'] ?? '',
      subtitleAr: json['subtitle_ar'] ?? '',
      subtitleDe: json['subtitle_de'],
      subtitleNl: json['subtitle_nl'],
      subtitleTr: json['subtitle_tr'],
      subtitleId: json['subtitle_id'],
      subtitleUr: json['subtitle_ur'],
      subtitleBn: json['subtitle_bn'],
      subtitleMs: json['subtitle_ms'],
      subtitleRu: json['subtitle_ru'],
      descriptionEn: json['description_en'] ?? '',
      descriptionFr: json['description_fr'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionDe: json['description_de'],
      descriptionNl: json['description_nl'],
      descriptionTr: json['description_tr'],
      descriptionId: json['description_id'],
      descriptionUr: json['description_ur'],
      descriptionBn: json['description_bn'],
      descriptionMs: json['description_ms'],
      descriptionRu: json['description_ru'],
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
    'de' => titleDe.orLoc(titleEn),
    'nl' => titleNl.orLoc(titleEn),
    'tr' => titleTr.orLoc(titleEn),
    'id' => titleId.orLoc(titleEn),
    'ur' => titleUr.orLoc(titleEn),
    'bn' => titleBn.orLoc(titleEn),
    'ms' => titleMs.orLoc(titleEn),
    'ru' => titleRu.orLoc(titleEn),
    _ => titleEn,
  };

  String subtitle(String langCode) => switch (langCode) {
    'fr' => subtitleFr,
    'ar' => subtitleAr,
    'de' => subtitleDe.orLoc(subtitleEn),
    'nl' => subtitleNl.orLoc(subtitleEn),
    'tr' => subtitleTr.orLoc(subtitleEn),
    'id' => subtitleId.orLoc(subtitleEn),
    'ur' => subtitleUr.orLoc(subtitleEn),
    'bn' => subtitleBn.orLoc(subtitleEn),
    'ms' => subtitleMs.orLoc(subtitleEn),
    'ru' => subtitleRu.orLoc(subtitleEn),
    _ => subtitleEn,
  };

  String description(String langCode) => switch (langCode) {
    'fr' => descriptionFr,
    'ar' => descriptionAr,
    'de' => descriptionDe.orLoc(descriptionEn),
    'nl' => descriptionNl.orLoc(descriptionEn),
    'tr' => descriptionTr.orLoc(descriptionEn),
    'id' => descriptionId.orLoc(descriptionEn),
    'ur' => descriptionUr.orLoc(descriptionEn),
    'bn' => descriptionBn.orLoc(descriptionEn),
    'ms' => descriptionMs.orLoc(descriptionEn),
    'ru' => descriptionRu.orLoc(descriptionEn),
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
    titleDe,
    titleNl,
    titleTr,
    titleId,
    titleUr,
    titleBn,
    titleMs,
    titleRu,
    subtitleEn,
    subtitleFr,
    subtitleAr,
    subtitleDe,
    subtitleNl,
    subtitleTr,
    subtitleId,
    subtitleUr,
    subtitleBn,
    subtitleMs,
    subtitleRu,
    descriptionEn,
    descriptionFr,
    descriptionAr,
    descriptionDe,
    descriptionNl,
    descriptionTr,
    descriptionId,
    descriptionUr,
    descriptionBn,
    descriptionMs,
    descriptionRu,
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
