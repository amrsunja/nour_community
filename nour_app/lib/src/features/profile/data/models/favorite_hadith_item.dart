import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/extensions/localized_string_extensions.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import '../../../hadith/data/models/hadith_model.dart';

/// A favourited hadith plus the title of the collection it belongs to.
///
/// The Favourites card renders "Collection Title, hadith title" so we carry the
/// collection's localized titles alongside the [hadith]. Built from the nested
/// `favorite_hadiths → hadiths → hadith_collections` select.
class FavoriteHadithItem extends Equatable {
  const FavoriteHadithItem({
    required this.hadith,
    required this.collectionTitleEn,
    required this.collectionTitleFr,
    required this.collectionTitleAr,
    this.collectionTitleDe,
    this.collectionTitleNl,
    this.collectionTitleTr,
    this.collectionTitleId,
    this.collectionTitleUr,
    this.collectionTitleBn,
    this.collectionTitleMs,
  });

  final HadithModel hadith;
  final String collectionTitleEn;
  final String collectionTitleFr;
  final String collectionTitleAr;
  final String? collectionTitleDe;
  final String? collectionTitleNl;
  final String? collectionTitleTr;
  final String? collectionTitleId;
  final String? collectionTitleUr;
  final String? collectionTitleBn;
  final String? collectionTitleMs;

  /// Builds the item from a `favorite_hadiths` row whose `hadiths` join also
  /// embeds the parent `hadith_collections` row.
  factory FavoriteHadithItem.fromRow(Json row) {
    final hadithJson = (row['hadiths'] as Json);
    final collection = (hadithJson['hadith_collections'] as Json?) ?? const {};
    return FavoriteHadithItem(
      hadith: HadithModel.fromJson(hadithJson),
      collectionTitleEn: collection['title_en'] ?? '',
      collectionTitleFr: collection['title_fr'] ?? '',
      collectionTitleAr: collection['title_ar'] ?? '',
      collectionTitleDe: collection['title_de'],
      collectionTitleNl: collection['title_nl'],
      collectionTitleTr: collection['title_tr'],
      collectionTitleId: collection['title_id'],
      collectionTitleUr: collection['title_ur'],
      collectionTitleBn: collection['title_bn'],
      collectionTitleMs: collection['title_ms'],
    );
  }

  String collectionTitle(String langCode) => switch (langCode) {
        'fr' => collectionTitleFr,
        'ar' => collectionTitleAr,
        'de' => collectionTitleDe.orLoc(collectionTitleEn),
        'nl' => collectionTitleNl.orLoc(collectionTitleEn),
        'tr' => collectionTitleTr.orLoc(collectionTitleEn),
        'id' => collectionTitleId.orLoc(collectionTitleEn),
        'ur' => collectionTitleUr.orLoc(collectionTitleEn),
        'bn' => collectionTitleBn.orLoc(collectionTitleEn),
        'ms' => collectionTitleMs.orLoc(collectionTitleEn),
        _ => collectionTitleEn,
      };

  @override
  List<Object?> get props => [
        hadith,
        collectionTitleEn,
        collectionTitleFr,
        collectionTitleAr,
        collectionTitleDe,
        collectionTitleNl,
        collectionTitleTr,
        collectionTitleId,
        collectionTitleUr,
        collectionTitleBn,
        collectionTitleMs,
      ];
}
