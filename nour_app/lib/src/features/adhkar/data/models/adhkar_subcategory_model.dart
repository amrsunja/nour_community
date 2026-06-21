import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AdhkarSubcategoryModel extends Equatable {
  final int id;
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
  final int position;

  /// Object path inside the public `app_images` storage bucket
  /// (e.g. `adhkar/morning.png`). Null when no illustration is set.
  final String? imgUrl;

  /// Recommended reading window as minutes-of-day [start, end). When
  /// [recommendedStartMinute] > [recommendedEndMinute] the window wraps past
  /// midnight. Both null => no time recommendation.
  final int? recommendedStartMinute;
  final int? recommendedEndMinute;

  /// Number of adhkars in this subcategory (badge count). Derived from the
  /// `adhkars(count)` aggregate on fetch.
  final int adhkarsCount;

  const AdhkarSubcategoryModel({
    required this.id,
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
    required this.position,
    this.imgUrl,
    this.recommendedStartMinute,
    this.recommendedEndMinute,
    this.adhkarsCount = 0,
  });

  factory AdhkarSubcategoryModel.fromJson(Json json) {
    // supabase `adhkars(count)` returns [{count: n}] (or {count: n}).
    int parseCount(dynamic raw) {
      if (raw is List && raw.isNotEmpty) return raw.first['count'] ?? 0;
      if (raw is Map) return raw['count'] ?? 0;
      return 0;
    }

    return AdhkarSubcategoryModel(
      id: json['id'],
      categoryId: json['adhkar_category_id'],
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
      imgUrl: json['img_url'],
      recommendedStartMinute: json['recommended_start_minute'],
      recommendedEndMinute: json['recommended_end_minute'],
      adhkarsCount: parseCount(json['adhkars']),
    );
  }

  /// Localized title resolved from the app language code (local settings).
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

  bool get hasRecommendedWindow =>
      recommendedStartMinute != null && recommendedEndMinute != null;

  /// Whether [nowMinute] (0..1439, local wall-clock minutes-of-day) falls
  /// inside the recommended window. Handles windows that wrap past midnight.
  bool isRecommendedAt(int nowMinute) {
    final start = recommendedStartMinute;
    final end = recommendedEndMinute;
    if (start == null || end == null) return false;

    if (start <= end) {
      return nowMinute >= start && nowMinute < end;
    }
    // Wrapping window (e.g. 21:00 -> 03:00).
    return nowMinute >= start || nowMinute < end;
  }

  @override
  List<Object?> get props => [
    id,
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
    position,
    imgUrl,
    recommendedStartMinute,
    recommendedEndMinute,
    adhkarsCount,
  ];
}
