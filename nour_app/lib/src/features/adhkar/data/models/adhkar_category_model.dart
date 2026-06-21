import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AdhkarCategoryModel extends Equatable {
  final int id;
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
  final int position;

  const AdhkarCategoryModel({
    required this.id,
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
    required this.position,
  });

  factory AdhkarCategoryModel.fromJson(Json json) => AdhkarCategoryModel(
    id: json['id'],
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
    position: json['position'] ?? 0,
  );

  /// Localized section title resolved from the app language code (local settings).
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

  @override
  List<Object?> get props => [
    id,
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
    position,
  ];
}
