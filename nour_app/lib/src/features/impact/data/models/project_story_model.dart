import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A "story from the field" attached to an impact project (mirrors
/// `public.project_stories`). [createdAt] drives the newest-first timeline order.
class ProjectStoryModel extends Equatable {
  final int id;
  final int impactProjectId;
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
  final List<String> images;
  final DateTime createdAt;

  const ProjectStoryModel({
    required this.id,
    required this.impactProjectId,
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
    required this.images,
    required this.createdAt,
  });

  factory ProjectStoryModel.fromJson(Json json) => ProjectStoryModel(
    id: json['id'],
    impactProjectId: json['impact_project_id'],
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
    images: [
      for (final e in (json['images'] as List? ?? const []))
        if (e is String && e.isNotEmpty) e,
    ],
    createdAt:
        DateTime.tryParse(json['created_at'] ?? '')?.toLocal() ?? DateTime.now(),
  );

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
    _ => titleEn,
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
    _ => descriptionEn,
  };

  String? get coverImage => images.isNotEmpty ? images.first : null;

  @override
  List<Object?> get props => [
    id,
    impactProjectId,
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
    images,
    createdAt,
  ];
}
