import 'package:equatable/equatable.dart';
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
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final int position;
  final bool isActive;
  final int totalHadiths;

  const HadithCollectionModel({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    this.descriptionEn = '',
    this.descriptionFr = '',
    this.descriptionAr = '',
    this.position = 0,
    this.isActive = true,
    this.totalHadiths = 0,
  });

  factory HadithCollectionModel.fromJson(Json json) => HadithCollectionModel(
        id: json['id'] as int,
        titleEn: json['title_en'] ?? '',
        titleFr: json['title_fr'] ?? '',
        titleAr: json['title_ar'] ?? '',
        descriptionEn: json['description_en'] ?? '',
        descriptionFr: json['description_fr'] ?? '',
        descriptionAr: json['description_ar'] ?? '',
        position: json['position'] ?? 0,
        isActive: json['is_active'] ?? true,
        totalHadiths: json['total_hadiths'] ?? 0,
      );

  /// Localized title used as the card heading.
  String title(String langCode) => switch (langCode) {
        'fr' => titleFr,
        'ar' => titleAr,
        _ => titleEn,
      };

  /// Localized subtitle (e.g. "Imam An-Nawawi | The essential 40").
  String description(String langCode) => switch (langCode) {
        'fr' => descriptionFr,
        'ar' => descriptionAr,
        _ => descriptionEn,
      };

  HadithCollectionModel copyWith({int? totalHadiths}) => HadithCollectionModel(
        id: id,
        titleEn: titleEn,
        titleFr: titleFr,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionFr: descriptionFr,
        descriptionAr: descriptionAr,
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
        descriptionEn,
        descriptionFr,
        descriptionAr,
        position,
        isActive,
        totalHadiths,
      ];
}
