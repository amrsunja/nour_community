import 'package:equatable/equatable.dart';

import '../../../../data/models/favorite_hadith_item.dart';

/// See [FavoriteAyahsState] for the [loaded] / refresh convention.
class FavoriteHadithsState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final List<FavoriteHadithItem> items;

  const FavoriteHadithsState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  FavoriteHadithsState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    List<FavoriteHadithItem>? items,
  }) =>
      FavoriteHadithsState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        loaded: loaded ?? this.loaded,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [isLoading, hasError, loaded, items];
}
