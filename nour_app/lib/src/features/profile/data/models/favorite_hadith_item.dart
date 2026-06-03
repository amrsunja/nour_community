import 'package:equatable/equatable.dart';
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
  });

  final HadithModel hadith;
  final String collectionTitleEn;
  final String collectionTitleFr;
  final String collectionTitleAr;

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
    );
  }

  String collectionTitle(String langCode) => switch (langCode) {
        'fr' => collectionTitleFr,
        'ar' => collectionTitleAr,
        _ => collectionTitleEn,
      };

  @override
  List<Object?> get props => [
        hadith,
        collectionTitleEn,
        collectionTitleFr,
        collectionTitleAr,
      ];
}
