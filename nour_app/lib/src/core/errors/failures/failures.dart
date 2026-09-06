import 'package:flutter/widgets.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../locale/l10n.dart';
import '../../utils/typedefs.dart';
import '../exceptions/cache/cache_exception.dart';
import '../exceptions/database/database_exception.dart';
import '../exceptions/server/server_exception.dart';

abstract class Failure {
  static Future<SuccessOrError<T>> exceptionsCatcher<T>(
    Future<T> Function() onSuccess,
  ) async {
    try {
      return Result.success(await onSuccess());
    } on CacheException catch (e) {
      return Result.error(CacheFailure(exception: e));
    } on DatabaseException catch (e) {
      return Result.error(DatabaseFailure(exception: e));
    } on ServerException catch (e) {
      return Result.error(ServerFailure(exception: e));
    } catch (e) {
      debugPrint(e.toString());
      return Result.error(UnknownFailure(exception: e));
    }
  }

  String toMessage(AppLocale locale);
}

class ServerFailure extends Failure {
  final ServerException exception;
  ServerFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) {
    if (exception.apiError?.message != null) {
      return exception.apiError!.message;
    }
    if (exception.messageKey != null) {
      return _localizedKey(exception.messageKey!, locale);
    }
    if (exception.message != null) {
      return exception.message!;
    }
    return locale.error_server_failure;
  }

  String _localizedKey(ApiErrorKey key, AppLocale l) {
    switch (key) {
      // Auth
      case ApiErrorKey.authAnonymousFailed:
        return l.error_api_auth_anonymous_failed;
      case ApiErrorKey.authStartFailed:
        return l.error_api_auth_start_failed;
      case ApiErrorKey.authCheckEmailFailed:
        return l.error_api_auth_check_email_failed;
      case ApiErrorKey.authCodeVerificationFailed:
        return l.error_api_auth_code_verification_failed;
      case ApiErrorKey.authSignInCancelled:
        return l.error_api_auth_sign_in_cancelled;
      case ApiErrorKey.authMissingGoogleToken:
        return l.error_api_auth_missing_google_token;
      case ApiErrorKey.authGoogleFailed:
        return l.error_api_auth_google_failed;
      case ApiErrorKey.authMissingAppleToken:
        return l.error_api_auth_missing_apple_token;
      case ApiErrorKey.authAppleFailed:
        return l.error_api_auth_apple_failed;
      case ApiErrorKey.authDeleteFailed:
        return l.error_api_auth_delete_failed;
      case ApiErrorKey.userNotAuthenticated:
        return l.error_api_user_not_authenticated;
      // Profile
      case ApiErrorKey.profileAvatarUploadFailed:
        return l.error_api_profile_avatar_upload_failed;
      case ApiErrorKey.profileAvatarDeleteFailed:
        return l.error_api_profile_avatar_delete_failed;
      case ApiErrorKey.profileInvalid:
        return l.error_api_profile_invalid;
      case ApiErrorKey.profileLoadFailed:
        return l.error_api_profile_load_failed;
      case ApiErrorKey.profileUpdatePracticeTimeFailed:
        return l.error_api_profile_update_practice_time_failed;
      case ApiErrorKey.profileUpdateLevelFailed:
        return l.error_api_profile_update_level_failed;
      case ApiErrorKey.profileUpdateNameFailed:
        return l.error_api_profile_update_name_failed;
      case ApiErrorKey.profileUpdateGenderFailed:
        return l.error_api_profile_update_gender_failed;
      case ApiErrorKey.profileUpdateOnboardingScreenFailed:
        return l.error_api_profile_update_onboarding_screen_failed;
      case ApiErrorKey.profileCompleteOnboardingFailed:
        return l.error_api_profile_complete_onboarding_failed;
      // Reward
      case ApiErrorKey.rewardStreakLoadFailed:
        return l.error_api_reward_streak_load_failed;
      case ApiErrorKey.rewardClaimFailed:
        return l.error_api_reward_claim_failed;
      // Quiz
      case ApiErrorKey.quizUnexpectedGetResponse:
        return l.error_api_quiz_unexpected_get_response;
      case ApiErrorKey.quizLoadFailed:
        return l.error_api_quiz_load_failed;
      case ApiErrorKey.quizUnexpectedSubmitResponse:
        return l.error_api_quiz_unexpected_submit_response;
      case ApiErrorKey.quizSubmitFailed:
        return l.error_api_quiz_submit_failed;
      // Favorites
      case ApiErrorKey.favoritesAyahsLoadFailed:
        return l.error_api_favorites_ayahs_load_failed;
      case ApiErrorKey.favoritesAdhkarsLoadFailed:
        return l.error_api_favorites_adhkars_load_failed;
      case ApiErrorKey.favoritesDuasLoadFailed:
        return l.error_api_favorites_duas_load_failed;
      case ApiErrorKey.favoritesHadithsLoadFailed:
        return l.error_api_favorites_hadiths_load_failed;
      case ApiErrorKey.favoritesProjectsLoadFailed:
        return l.error_api_favorites_projects_load_failed;
      // Dua
      case ApiErrorKey.duaLoadFailed:
        return l.error_api_dua_load_failed;
      case ApiErrorKey.duaProgressLoadFailed:
        return l.error_api_dua_progress_load_failed;
      case ApiErrorKey.duaProgressSaveFailed:
        return l.error_api_dua_progress_save_failed;
      case ApiErrorKey.duaAjrAwardFailed:
        return l.error_api_dua_ajr_award_failed;
      case ApiErrorKey.duaLikedLoadFailed:
        return l.error_api_dua_liked_load_failed;
      case ApiErrorKey.duaLikeFailed:
        return l.error_api_dua_like_failed;
      case ApiErrorKey.duaUnlikeFailed:
        return l.error_api_dua_unlike_failed;
      // Statistics
      case ApiErrorKey.statisticsLoadFailed:
        return l.error_api_statistics_load_failed;
      // Adhkar
      case ApiErrorKey.adhkarCategoriesLoadFailed:
        return l.error_api_adhkar_categories_load_failed;
      case ApiErrorKey.adhkarSubcategoriesLoadFailed:
        return l.error_api_adhkar_subcategories_load_failed;
      case ApiErrorKey.adhkarsLoadFailed:
        return l.error_api_adhkars_load_failed;
      // Dhikr
      case ApiErrorKey.dhikrsLoadFailed:
        return l.error_api_dhikrs_load_failed;
      case ApiErrorKey.dhikrProgressLoadFailed:
        return l.error_api_dhikr_progress_load_failed;
      case ApiErrorKey.dhikrAjrLoadFailed:
        return l.error_api_dhikr_ajr_load_failed;
      case ApiErrorKey.dhikrProgressSaveFailed:
        return l.error_api_dhikr_progress_save_failed;
      // Hadith
      case ApiErrorKey.hadithCollectionsLoadFailed:
        return l.error_api_hadith_collections_load_failed;
      case ApiErrorKey.hadithsLoadFailed:
        return l.error_api_hadiths_load_failed;
      case ApiErrorKey.hadithProgressLoadFailed:
        return l.error_api_hadith_progress_load_failed;
      case ApiErrorKey.hadithProgressSaveFailed:
        return l.error_api_hadith_progress_save_failed;
      case ApiErrorKey.hadithLikedLoadFailed:
        return l.error_api_hadith_liked_load_failed;
      case ApiErrorKey.hadithLikeFailed:
        return l.error_api_hadith_like_failed;
      case ApiErrorKey.hadithUnlikeFailed:
        return l.error_api_hadith_unlike_failed;
      // Impact
      case ApiErrorKey.impactCategoriesLoadFailed:
        return l.error_api_impact_categories_load_failed;
      case ApiErrorKey.impactProjectsLoadFailed:
        return l.error_api_impact_projects_load_failed;
      case ApiErrorKey.impactProjectLoadFailed:
        return l.error_api_impact_project_load_failed;
      case ApiErrorKey.impactAddFavoriteFailed:
        return l.error_api_impact_add_favorite_failed;
      case ApiErrorKey.impactRemoveFavoriteFailed:
        return l.error_api_impact_remove_favorite_failed;
      // Quran
      case ApiErrorKey.quranProgressLoadFailed:
        return l.error_api_quran_progress_load_failed;
      case ApiErrorKey.quranProgressSaveFailed:
        return l.error_api_quran_progress_save_failed;
      case ApiErrorKey.quranLikedAyahsLoadFailed:
        return l.error_api_quran_liked_ayahs_load_failed;
      case ApiErrorKey.quranAyahAjrAwardFailed:
        return l.error_api_quran_ayah_ajr_award_failed;
      case ApiErrorKey.quranLikeAyahFailed:
        return l.error_api_quran_like_ayah_failed;
      case ApiErrorKey.quranTransliterationLoadFailed:
        return l.error_api_quran_transliteration_load_failed;
      case ApiErrorKey.quranTafsirLoadFailed:
        return l.error_api_quran_tafsir_load_failed;
      case ApiErrorKey.quranUnlikeAyahFailed:
        return l.error_api_quran_unlike_ayah_failed;
      // Payments
      case ApiErrorKey.paymentIntentFailed:
        return l.error_api_payment_intent_failed;
      case ApiErrorKey.paymentSheetFailed:
        return l.error_api_payment_sheet_failed;
      case ApiErrorKey.paymentCancelled:
        return l.error_api_payment_cancelled;
      case ApiErrorKey.paymentHistoryLoadFailed:
        return l.error_api_payment_history_load_failed;
      case ApiErrorKey.paymentProjectTransactionsLoadFailed:
        return l.error_api_payment_project_transactions_load_failed;
      case ApiErrorKey.paymentAmountTooSmall:
        return l.error_api_payment_amount_too_small;
      case ApiErrorKey.paymentAmountTooLarge:
        return l.error_api_payment_amount_too_large;
      case ApiErrorKey.paymentProjectInactive:
        return l.error_api_payment_project_inactive;
      case ApiErrorKey.paymentNotZakatEligible:
        return l.error_api_payment_not_zakat_eligible;
      case ApiErrorKey.paymentSubscriptionFailed:
        return l.error_api_payment_subscription_failed;
      case ApiErrorKey.paymentSubscriptionsLoadFailed:
        return l.error_api_payment_subscriptions_load_failed;
      case ApiErrorKey.paymentSubscriptionCancelFailed:
        return l.error_api_payment_subscription_cancel_failed;
      case ApiErrorKey.paymentConfirmationTimeout:
        return l.error_api_payment_confirmation_timeout;
      // Admin
      case ApiErrorKey.adminAnalyticsLoadFailed:
        return l.error_api_admin_analytics_load_failed;
      case ApiErrorKey.adminPayoutsLoadFailed:
        return l.error_api_admin_payouts_load_failed;
      case ApiErrorKey.adminPayoutCreateFailed:
        return l.error_api_admin_payout_create_failed;
      case ApiErrorKey.adminPayoutUpdateFailed:
        return l.error_api_admin_payout_update_failed;
      case ApiErrorKey.adminPayoutDeleteFailed:
        return l.error_api_admin_payout_delete_failed;
      case ApiErrorKey.adminPayoutProofUploadFailed:
        return l.error_api_admin_payout_proof_upload_failed;
      case ApiErrorKey.adminTransactionsLoadFailed:
        return l.error_api_admin_transactions_load_failed;

      // Mosques
      case ApiErrorKey.mosqueLoadFailed:
        return l.error_api_mosque_load_failed;
      case ApiErrorKey.mosqueSaveFailed:
        return l.error_api_mosque_save_failed;
      case ApiErrorKey.mosqueSearchFailed:
        return l.error_api_mosque_search_failed;
      case ApiErrorKey.mosqueRegisterFailed:
        return l.error_api_mosque_register_failed;
      case ApiErrorKey.mosqueRegisterIsWorshipper:
        return l.error_api_mosque_register_is_worshipper;
      case ApiErrorKey.mosqueRegisterAnonymous:
        return l.error_api_mosque_register_anonymous;
      case ApiErrorKey.mosqueRegisterInvalidSiren:
        return l.error_api_mosque_register_invalid_siren;
      case ApiErrorKey.mosqueRegisterInvalidRna:
        return l.error_api_mosque_register_invalid_rna;
      case ApiErrorKey.mosqueRegisterDuplicate:
        return l.error_api_mosque_register_duplicate;
      case ApiErrorKey.mosquePostLimitReached:
        return l.error_api_mosque_post_limit_reached;
      case ApiErrorKey.mosqueBroadcastQuotaExceeded:
        return l.error_api_mosque_broadcast_quota_exceeded;
      case ApiErrorKey.mosqueNotApproved:
        return l.error_api_mosque_not_approved;
      case ApiErrorKey.pushRegisterFailed:
        return l.error_api_push_register_failed;
      case ApiErrorKey.mosqueCampaignLimitReached:
        return l.error_api_mosque_campaign_limit_reached;
      case ApiErrorKey.mosqueCampaignClosed:
        return l.error_api_mosque_campaign_closed;
      case ApiErrorKey.mosqueDonationsDisabled:
        return l.error_api_mosque_donations_disabled;
      case ApiErrorKey.mosqueReceiptsNotAllowed:
        return l.error_api_mosque_receipts_not_allowed;
      case ApiErrorKey.mosqueReceiptNoDonations:
        return l.error_api_mosque_receipt_no_donations;
      case ApiErrorKey.mosqueReceiptFailed:
        return l.error_api_mosque_receipt_failed;
      case ApiErrorKey.mosqueStripeFailed:
        return l.error_api_mosque_stripe_failed;
    }
  }
}

class CacheFailure extends Failure {
  final CacheException exception;
  CacheFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) {
    return 'CacheFailure: - ${exception.message}';
  }
}

class DatabaseFailure extends Failure {
  final DatabaseException exception;
  DatabaseFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) {
    //return 'DatabaseFailure: ${exception.data} - ${exception.message}';
    debugPrint('DatabaseFailure: ${exception.data} - ${exception.message}');
    return locale.error_db_failure;
  }
}

class UnknownFailure extends Failure {
  final Object? exception;
  UnknownFailure({this.exception});

  @override
  String toMessage(AppLocale locale) {
    return locale.error_unknown;
  }
}
