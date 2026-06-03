import 'package:equatable/equatable.dart';

import '../../../../../dua/data/models/dua_model.dart';

/// See [FavoriteAyahsState] for the [loaded] / refresh convention.
class FavoriteDuasState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final List<DuaModel> items;

  const FavoriteDuasState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  FavoriteDuasState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    List<DuaModel>? items,
  }) =>
      FavoriteDuasState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        loaded: loaded ?? this.loaded,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [isLoading, hasError, loaded, items];
}
