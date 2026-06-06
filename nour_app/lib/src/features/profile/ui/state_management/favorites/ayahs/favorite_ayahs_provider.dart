import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../../../../quran/data/quran_repo.dart';
import '../../../../data/favorites_repo.dart';
import '../../../../data/models/favorite_ayah_item.dart';
import 'favorite_ayahs_state.dart';

/// App-lifetime provider (NOT autoDispose): the fetched favourites survive tab
/// switches and page closes, so the request fires only once per app launch.
final favoriteAyahsProvider =
    StateNotifierProvider<FavoriteAyahsPresenter, FavoriteAyahsState>((ref) {
  return FavoriteAyahsPresenter(
    repo: ref.read(favoritesRepoProvider),
    quranRepo: ref.read(quranRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class FavoriteAyahsPresenter extends Presenter<FavoriteAyahsState> {
  final FavoritesRepo repo;
  final QuranRepo quranRepo;
  final AppEvents appEvents;

  FavoriteAyahsPresenter({
    required this.repo,
    required this.quranRepo,
    required this.appEvents,
  }) : super(const FavoriteAyahsState());

  /// Loads favourites the first time the tab is opened. No-ops once data has
  /// been loaded (or is loading) for the current [langCode] — call [refresh] to
  /// force a reload. Re-fetches when the app language changed so the cached
  /// translations follow the app language.
  Future<void> init(String langCode) async {
    if (state.isLoading) return;
    if (state.loaded && state.loadedLangCode == langCode) return;
    await _load(langCode: langCode);
  }

  /// Pull-to-refresh: always re-fetches, keeping the current list on screen
  /// until the new one arrives.
  Future<void> refresh(String langCode) =>
      _load(langCode: langCode, silent: true);

  Future<void> _load({required String langCode, bool silent = false}) async {
    state = state.copyWith(isLoading: !silent, hasError: false);

    final res = await repo.getFavoriteAyahs();
    res.when(
      (refs) {
        final items = [
          for (final ref in refs)
            FavoriteAyahItem(
              surahNumber: ref.surahNumber,
              ayahNumber: ref.ayahNumber,
              surahNameEn: quranRepo.getSurah(ref.surahNumber).nameEnglish,
              surahNameAr: quranRepo.getSurah(ref.surahNumber).nameArabic,
              translation: quranRepo
                  .getAyah(ref.surahNumber, ref.ayahNumber, langCode: langCode)
                  .translation,
            ),
        ];
        state = state.copyWith(
          items: items,
          loaded: true,
          isLoading: false,
          loadedLangCode: langCode,
        );
      },
      (error) {
        state = state.copyWith(isLoading: false, hasError: !silent);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }
}
