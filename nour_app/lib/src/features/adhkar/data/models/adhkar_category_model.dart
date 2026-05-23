import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AdhkarCategoryModel extends Equatable {
  final int id;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final int position;

  const AdhkarCategoryModel({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.position,
  });

  factory AdhkarCategoryModel.fromJson(Json json) => AdhkarCategoryModel(
    id: json['id'],
    titleEn: json['title_en'] ?? '',
    titleFr: json['title_fr'] ?? '',
    titleAr: json['title_ar'] ?? '',
    position: json['position'] ?? 0,
  );

  /// Localized section title resolved from the profile language code.
  String title(String langCode) => switch (langCode) {
    'fr' => titleFr,
    'ar' => titleAr,
    _ => titleEn,
  };

  @override
  List<Object?> get props => [id, titleEn, titleFr, titleAr, position];
}
