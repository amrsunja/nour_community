part of 'server_exception.dart';

/// Stable, language-agnostic identifiers for API/datasource error messages.
///
/// Datasources throw these instead of hardcoded strings; the actual localized
/// text is resolved at the presentation seam in [ServerFailure.toMessage].
enum ApiErrorKey {
  // Auth
  authAnonymousFailed,
  authStartFailed,
  authCheckEmailFailed,
  authCodeVerificationFailed,
  authSignInCancelled,
  authMissingGoogleToken,
  authGoogleFailed,
  authMissingAppleToken,
  authAppleFailed,
  userNotAuthenticated,

  // Profile
  profileAvatarUploadFailed,
  profileAvatarDeleteFailed,
  profileInvalid,
  profileLoadFailed,
  profileUpdatePracticeTimeFailed,
  profileUpdateLevelFailed,
  profileUpdateNameFailed,
  profileUpdateGenderFailed,
  profileUpdateOnboardingScreenFailed,
  profileCompleteOnboardingFailed,

  // Reward
  rewardStreakLoadFailed,
  rewardClaimFailed,

  // Quiz
  quizUnexpectedGetResponse,
  quizLoadFailed,
  quizUnexpectedSubmitResponse,
  quizSubmitFailed,

  // Favorites
  favoritesAyahsLoadFailed,
  favoritesAdhkarsLoadFailed,
  favoritesDuasLoadFailed,
  favoritesHadithsLoadFailed,
  favoritesProjectsLoadFailed,

  // Dua
  duaLoadFailed,
  duaProgressLoadFailed,
  duaProgressSaveFailed,
  duaAjrAwardFailed,
  duaLikedLoadFailed,
  duaLikeFailed,
  duaUnlikeFailed,

  // Statistics
  statisticsLoadFailed,

  // Adhkar
  adhkarCategoriesLoadFailed,
  adhkarSubcategoriesLoadFailed,
  adhkarsLoadFailed,

  // Dhikr
  dhikrsLoadFailed,
  dhikrProgressLoadFailed,
  dhikrAjrLoadFailed,
  dhikrProgressSaveFailed,

  // Hadith
  hadithCollectionsLoadFailed,
  hadithsLoadFailed,
  hadithProgressLoadFailed,
  hadithProgressSaveFailed,
  hadithLikedLoadFailed,
  hadithLikeFailed,
  hadithUnlikeFailed,

  // Impact
  impactCategoriesLoadFailed,
  impactProjectsLoadFailed,
  impactProjectLoadFailed,
  impactAddFavoriteFailed,
  impactRemoveFavoriteFailed,

  // Quran
  quranProgressLoadFailed,
  quranProgressSaveFailed,
  quranLikedAyahsLoadFailed,
  quranAyahAjrAwardFailed,
  quranLikeAyahFailed,
  quranTransliterationLoadFailed,
  quranTafsirLoadFailed,
  quranUnlikeAyahFailed,
}
