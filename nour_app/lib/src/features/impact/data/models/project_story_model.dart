import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A "story from the field" attached to an impact project (mirrors
/// `public.project_stories`). [createdAt] drives the newest-first timeline order.
class ProjectStoryModel extends Equatable {
  final int id;
  final int impactProjectId;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final List<String> images;
  final DateTime createdAt;

  const ProjectStoryModel({
    required this.id,
    required this.impactProjectId,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.images,
    required this.createdAt,
  });

  factory ProjectStoryModel.fromJson(Json json) => ProjectStoryModel(
    id: json['id'],
    impactProjectId: json['impact_project_id'],
    titleEn: json['title_en'] ?? '',
    titleFr: json['title_fr'] ?? '',
    titleAr: json['title_ar'] ?? '',
    descriptionEn: json['description_en'] ?? '',
    descriptionFr: json['description_fr'] ?? '',
    descriptionAr: json['description_ar'] ?? '',
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
    _ => titleEn,
  };

  String description(String langCode) => switch (langCode) {
    'fr' => descriptionFr,
    'ar' => descriptionAr,
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
    descriptionEn,
    descriptionFr,
    descriptionAr,
    images,
    createdAt,
  ];
}
