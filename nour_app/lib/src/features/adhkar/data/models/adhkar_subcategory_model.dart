import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class AdhkarSubcategoryModel extends Equatable {
  final int id;
  final int categoryId;
  final String titleEn;
  final String titleFr;
  final String titleAr;
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
      position: json['position'] ?? 0,
      imgUrl: json['img_url'],
      recommendedStartMinute: json['recommended_start_minute'],
      recommendedEndMinute: json['recommended_end_minute'],
      adhkarsCount: parseCount(json['adhkars']),
    );
  }

  /// Localized title resolved from the profile language code.
  String title(String langCode) => switch (langCode) {
    'fr' => titleFr,
    'ar' => titleAr,
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
    position,
    imgUrl,
    recommendedStartMinute,
    recommendedEndMinute,
    adhkarsCount,
  ];
}
