import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Per-user reading position inside a single collection. Mirrors
/// `public.hadith_progress` (one row per user per collection, seeded by DB
/// triggers). The client only ever writes `current_hadith_id`.
///
/// [currentPosition] is derived (the 1-based order of [currentHadithId] within
/// the collection) so the source-tab card can show "x/total" without loading
/// every hadith. It is 0 when nothing has been read yet.
class HadithProgressModel extends Equatable {
  final int collectionId;
  final int? currentHadithId;
  final int currentPosition;
  final DateTime? updatedAt;

  const HadithProgressModel({
    required this.collectionId,
    this.currentHadithId,
    this.currentPosition = 0,
    this.updatedAt,
  });

  factory HadithProgressModel.fromJson(Json json) => HadithProgressModel(
        collectionId: json['hadith_collection_id'] as int,
        currentHadithId: json['current_hadith_id'] as int?,
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      );

  bool get hasProgress => currentHadithId != null && currentPosition > 0;

  HadithProgressModel copyWith({
    int? currentHadithId,
    int? currentPosition,
  }) =>
      HadithProgressModel(
        collectionId: collectionId,
        currentHadithId: currentHadithId ?? this.currentHadithId,
        currentPosition: currentPosition ?? this.currentPosition,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props =>
      [collectionId, currentHadithId, currentPosition, updatedAt];
}
