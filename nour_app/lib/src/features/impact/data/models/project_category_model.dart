import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A single impact-project category (mirrors `public.project_categories`).
/// The synthetic [ProjectCategoryModel.all] entry is added client-side as the
/// first "All" filter tab and is never persisted.
class ProjectCategoryModel extends Equatable {
  final int id;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final int position;

  const ProjectCategoryModel({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.position,
  });

  /// Sentinel id for the synthetic "All" tab (no DB row).
  static const int allId = -1;

  factory ProjectCategoryModel.fromJson(Json json) => ProjectCategoryModel(
    id: json['id'],
    titleEn: json['title_en'] ?? '',
    titleFr: json['title_fr'] ?? '',
    titleAr: json['title_ar'] ?? '',
    position: json['position'] ?? 0,
  );

  bool get isAll => id == allId;

  String title(String langCode) => switch (langCode) {
    'fr' => titleFr,
    'ar' => titleAr,
    _ => titleEn,
  };

  @override
  List<Object?> get props => [id, titleEn, titleFr, titleAr, position];
}
