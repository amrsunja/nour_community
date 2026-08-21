import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// One line of "Your donation provides" (mirrors `public.impact_project_tiers`):
/// a concrete outcome for a given amount, e.g. "Daily food parcel — 10€".
class ImpactProjectTierModel extends Equatable {
  final int id;
  final int impactProjectId;
  final double amount;
  final int position;
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
  final String? subtitleEn;
  final String? subtitleFr;
  final String? subtitleAr;
  final String? subtitleDe;
  final String? subtitleNl;
  final String? subtitleTr;
  final String? subtitleId;
  final String? subtitleUr;
  final String? subtitleBn;
  final String? subtitleMs;
  final String? subtitleRu;

  const ImpactProjectTierModel({
    required this.id,
    required this.impactProjectId,
    required this.amount,
    required this.position,
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
    this.subtitleEn,
    this.subtitleFr,
    this.subtitleAr,
    this.subtitleDe,
    this.subtitleNl,
    this.subtitleTr,
    this.subtitleId,
    this.subtitleUr,
    this.subtitleBn,
    this.subtitleMs,
    this.subtitleRu,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  factory ImpactProjectTierModel.fromJson(Json json) => ImpactProjectTierModel(
    id: json['id'] as int,
    impactProjectId: json['impact_project_id'] as int,
    amount: _toDouble(json['amount']),
    position: json['position'] as int? ?? 0,
    titleEn: json['title_en'] as String? ?? '',
    titleFr: json['title_fr'] as String? ?? '',
    titleAr: json['title_ar'] as String? ?? '',
    titleDe: json['title_de'],
    titleNl: json['title_nl'],
    titleTr: json['title_tr'],
    titleId: json['title_id'],
    titleUr: json['title_ur'],
    titleBn: json['title_bn'],
    titleMs: json['title_ms'],
    titleRu: json['title_ru'],
    subtitleEn: json['subtitle_en'],
    subtitleFr: json['subtitle_fr'],
    subtitleAr: json['subtitle_ar'],
    subtitleDe: json['subtitle_de'],
    subtitleNl: json['subtitle_nl'],
    subtitleTr: json['subtitle_tr'],
    subtitleId: json['subtitle_id'],
    subtitleUr: json['subtitle_ur'],
    subtitleBn: json['subtitle_bn'],
    subtitleMs: json['subtitle_ms'],
    subtitleRu: json['subtitle_ru'],
  );

  String title(String langCode) => switch (langCode) {
    'fr' => titleFr.orLoc(titleEn),
    'ar' => titleAr.orLoc(titleEn),
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
    'fr' => subtitleFr.orLoc(subtitleEn ?? ''),
    'ar' => subtitleAr.orLoc(subtitleEn ?? ''),
    'de' => subtitleDe.orLoc(subtitleEn ?? ''),
    'nl' => subtitleNl.orLoc(subtitleEn ?? ''),
    'tr' => subtitleTr.orLoc(subtitleEn ?? ''),
    'id' => subtitleId.orLoc(subtitleEn ?? ''),
    'ur' => subtitleUr.orLoc(subtitleEn ?? ''),
    'bn' => subtitleBn.orLoc(subtitleEn ?? ''),
    'ms' => subtitleMs.orLoc(subtitleEn ?? ''),
    'ru' => subtitleRu.orLoc(subtitleEn ?? ''),
    _ => subtitleEn ?? '',
  };

  @override
  List<Object?> get props => [id, impactProjectId, amount, position, titleEn, titleFr, titleAr];
}
