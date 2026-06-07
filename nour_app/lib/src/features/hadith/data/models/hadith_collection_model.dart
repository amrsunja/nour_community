import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A hadith collection (an author's book), e.g. "40 Hadith Nawawi" or
/// "Sahih al-Bukhari". Mirrors `public.hadith_collections`.
///
/// [totalHadiths] is not a column — it's the count of active hadiths in the
/// collection, filled by the datasource so the source-tab card can render the
/// "x/total" progress line.
class HadithCollectionModel extends Equatable {
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
  final int position;
  final bool isActive;
  final int totalHadiths;

  const HadithCollectionModel({
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
    this.descriptionEn = '',
    this.descriptionFr = '',
    this.descriptionAr = '',
    this.descriptionDe,
    this.descriptionNl,
    this.descriptionTr,
    this.descriptionId,
    this.descriptionUr,
    this.descriptionBn,
    this.descriptionMs,
    this.position = 0,
    this.isActive = true,
    this.totalHadiths = 0,
  });

  factory HadithCollectionModel.fromJson(Json json) => HadithCollectionModel(
        id: json['id'] as int,
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
        position: json['position'] ?? 0,
        isActive: json['is_active'] ?? true,
        totalHadiths: json['total_hadiths'] ?? 0,
      );

  /// Localized title used as the card heading.
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

  /// Localized subtitle (e.g. "Imam An-Nawawi | The essential 40").
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

  HadithCollectionModel copyWith({int? totalHadiths}) => HadithCollectionModel(
        id: id,
        titleEn: titleEn,
        titleFr: titleFr,
        titleAr: titleAr,
        titleDe: titleDe,
        titleNl: titleNl,
        titleTr: titleTr,
        titleId: titleId,
        titleUr: titleUr,
        titleBn: titleBn,
        titleMs: titleMs,
        descriptionEn: descriptionEn,
        descriptionFr: descriptionFr,
        descriptionAr: descriptionAr,
        descriptionDe: descriptionDe,
        descriptionNl: descriptionNl,
        descriptionTr: descriptionTr,
        descriptionId: descriptionId,
        descriptionUr: descriptionUr,
        descriptionBn: descriptionBn,
        descriptionMs: descriptionMs,
        position: position,
        isActive: isActive,
        totalHadiths: totalHadiths ?? this.totalHadiths,
      );

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
        position,
        isActive,
        totalHadiths,
      ];
}
