import 'package:equatable/equatable.dart';

import '../../../../data/models/favorite_ayah_item.dart';

/// Hand-written immutable state (no freezed codegen) — same convention as the
/// quran / hadith features.
///
/// [loaded] flips to true after the first successful fetch so the view's
/// `init()` is a no-op for the rest of the app session (the provider is kept
/// alive app-wide). A pull-to-refresh goes through `refresh()` instead, which
/// bypasses that guard.
class FavoriteAyahsState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final List<FavoriteAyahItem> items;

  const FavoriteAyahsState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  FavoriteAyahsState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    List<FavoriteAyahItem>? items,
  }) =>
      FavoriteAyahsState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        loaded: loaded ?? this.loaded,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [isLoading, hasError, loaded, items];
}
