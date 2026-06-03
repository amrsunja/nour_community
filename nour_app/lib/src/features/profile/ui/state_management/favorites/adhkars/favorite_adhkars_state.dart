import 'package:equatable/equatable.dart';

import '../../../../../adhkar/data/models/adhkar_model.dart';

/// See [FavoriteAyahsState] for the [loaded] / refresh convention.
class FavoriteAdhkarsState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final List<AdhkarModel> items;

  const FavoriteAdhkarsState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  FavoriteAdhkarsState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    List<AdhkarModel>? items,
  }) =>
      FavoriteAdhkarsState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        loaded: loaded ?? this.loaded,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [isLoading, hasError, loaded, items];
}
