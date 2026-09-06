import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/core/routing/route_paths.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import 'app_router.dart';

abstract class NavigationServices {
	void pop();

	void toSignIn();
	void toRoot();
	void toWelcome();
	void toProfileType();
	void toMosqueOnboarding();
	void toMosqueReview();
	void toMosqueAdmin();
	/// Mosque account: admin shell when approved, review page otherwise.
	void toMosqueAdminOrReview();
	void toPushSettings();

	// Mosques (worshipper side)
	void toMosqueSearch();
	void toMosqueProfile({required int mosqueId, String? tab, int? postId});
	void toMosqueBecomeMember({required int mosqueId});
	void toMosqueCampaign({required int mosqueId, required int campaignId});
	void toMosqueCheckout({
		required int mosqueId,
		required double amount,
		required String frequency,
		int? campaignId,
		int? membershipId,
	});
	void toHome({bool openSignIn = false});
	void navigateToHome();
	void toSettings();
	void toProfile();
	void toProfileStatistics();
	void toAdminDashboard();
	void toAccountInformation();
	void toWebView({required String url, required String title});
	void toFavorites();
	void toOnboarding();

	void toDhikrsList();
	void toAdhkarsList();
	void toAdhkarDetail({required int subcategoryId, int? initialAdhkarId});
	void toDhikr({required int selectedId});

	void toImpactProjectDetail({required int projectId});

	// Payments
	void toCheckout({
		required int projectId,
		required double amount,
		required DonationFrequency frequency,
		bool isZakat = false,
	});
	void toDonationReward({
		required int projectId,
		required double amount,
		required DonationFrequency frequency,
		bool replace = false,
	});
	void toMyDonations({bool replace = false});
	void toZakatCheckout();
	void toZakatReward({bool replace = false});

	void toSurahDetail({required int surahNumber});
	void toAyahReader({required int surahNumber, int initialAyah, bool recordProgress});
	void toDailyAyah();

	void toHadithCollectionDetail({required int collectionId});
	void toHadithReader({required int collectionId, required int initialHadithId, bool recordProgress});

	void toDuaLibrary();
	void toDuaReader({required int initialDuaId, bool recordProgress});
	void toDailyDua();

	void toQuiz();

	void toPrayerTimes();
	void toHijriCalendar();
	void toQiblaFinder();
	void toZakatCalculator();

	void toStreakReward({required int streakDay});
	void toDailyDhikrReward({required int dhikrCompleted, required int ajrEarned});

	void toRemindersSettings();
	void toFavoriteReciterSettings();
	void toLanguageSettings();
}

class NavigationServicesImpl implements NavigationServices {
	final AppRouter router;
	final Ref ref;

	NavigationServicesImpl({
		required this.router,
		required this.ref,
	});

  @override
  void pop() => router.pop();

  @override
  void toSignIn() {
		router.replaceAll([SignInRoute()]);
  }

  @override
  void toRoot() {
		router.replaceAll([RootRoute()]);
  }

  @override
  void toOnboarding() {
		router.replaceAll([OnboardingRoute()]);
  }

  @override
  void toWelcome() {
		router.replaceAll([const WelcomeRoute()]);
  }

  @override
  void toProfileType() {
		router.push(const ProfileTypeRoute());
  }

  @override
  void toMosqueOnboarding() {
		router.replaceAll([const MosqueOnboardingRoute()]);
  }

  @override
  void toMosqueReview() {
		router.replaceAll([const MosqueReviewRoute()]);
  }

  @override
  void toMosqueAdmin() {
		router.replaceAll([const MosqueAdminShellRoute()]);
  }

  @override
  void toMosqueAdminOrReview() {
		final approved = ref.read(myMosqueProvider).isApproved;
		router.replaceAll([approved ? const MosqueAdminShellRoute() : const MosqueReviewRoute()]);
  }

  @override
  void toPushSettings() {
		router.push(const PushSettingsRoute());
  }

  @override
  void toMosqueSearch() {
		router.push(const MosqueSearchRoute());
  }

  @override
  void toMosqueProfile({required int mosqueId, String? tab, int? postId}) {
		router.push(MosqueProfileRoute(mosqueId: mosqueId, tab: tab, postId: postId));
  }

  @override
  void toMosqueBecomeMember({required int mosqueId}) {
		router.push(MosqueBecomeMemberRoute(mosqueId: mosqueId));
  }

  @override
  void toMosqueCampaign({required int mosqueId, required int campaignId}) {
		router.push(MosqueCampaignRoute(mosqueId: mosqueId, campaignId: campaignId));
  }

  @override
  void toMosqueCheckout({
		required int mosqueId,
		required double amount,
		required String frequency,
		int? campaignId,
		int? membershipId,
	}) {
		router.push(MosqueCheckoutRoute(
			mosqueId: mosqueId,
			amount: amount,
			frequency: frequency,
			campaignId: campaignId,
			membershipId: membershipId,
		));
  }

  @override
  void navigateToHome() {
		router.navigate(HomeRouterRoute());
  }

  @override
  void toHome({bool openSignIn = false}) {
		router.replaceAll([HomeRouterRoute(), if (openSignIn) SignInRoute()]);
  }

  @override
  void toSettings() {
		router.pushPath(RoutePaths.settings);
  }

  @override
  void toProfile() {
		router.push(ProfileRoute());
  }

  @override
  void toProfileStatistics() {
		router.push(ProfileStatisticsRoute());
  }

  @override
  void toAdminDashboard() {
		router.push(AdminDashboardRoute());
  }

  @override
  void toAccountInformation() {
		router.push(AccountInformationRoute());
  }

  @override
  void toWebView({required String url, required String title}) {
		router.push(WebViewRoute(url: url, title: title));
  }

  @override
  void toFavorites() {
		router.push(FavoritesRoute());
  }

  @override
  void toDhikrsList() {
		router.push(DhikrsListRoute());
  }

  @override
  void toAdhkarsList() {
		router.push(AdhkarsListRoute());
  }

  @override
  void toAdhkarDetail({required int subcategoryId, int? initialAdhkarId}) {
		router.push(AdhkarDetailRoute(
			subcategoryId: subcategoryId,
			initialAdhkarId: initialAdhkarId,
		));
  }

  @override
  void toDhikr({required int selectedId}) {
		router.push(DhikrRoute(selectedId: selectedId));
  }

  @override
  void toImpactProjectDetail({required int projectId}) {
		router.push(ImpactProjectDetailRoute(projectId: projectId));
  }

  @override
  void toCheckout({
		required int projectId,
		required double amount,
		required DonationFrequency frequency,
		bool isZakat = false,
	}) {
		router.push(CheckoutRoute(
			projectId: projectId,
			amount: amount,
			frequency: frequency.name,
			isZakat: isZakat,
		));
  }

  @override
  void toDonationReward({
		required int projectId,
		required double amount,
		required DonationFrequency frequency,
		bool replace = false,
	}) {
		final route = DonationRewardRoute(
			projectId: projectId,
			amount: amount,
			frequency: frequency.name,
		);
		replace ? router.replace(route) : router.push(route);
  }

  @override
  void toMyDonations({bool replace = false}) {
		replace ? router.replace(MyDonationsRoute()) : router.push(MyDonationsRoute());
  }

  @override
  void toZakatCheckout() {
		router.push(const ZakatCheckoutRoute());
  }

  @override
  void toZakatReward({bool replace = false}) {
		replace
			? router.replace(const ZakatRewardRoute())
			: router.push(const ZakatRewardRoute());
  }

  @override
  void toSurahDetail({required int surahNumber}) {
		router.push(SurahDetailRoute(surahNumber: surahNumber));
  }

  @override
  void toAyahReader({required int surahNumber, int initialAyah = 1, bool recordProgress = true}) {
		router.push(AyahReaderRoute(
			surahNumber: surahNumber,
			initialAyah: initialAyah,
			recordProgress: recordProgress,
		));
  }

  @override
  void toDailyAyah() {
		router.push(DailyAyahRoute());
  }

  @override
  void toHadithCollectionDetail({required int collectionId}) {
		router.push(HadithCollectionDetailRoute(collectionId: collectionId));
  }

  @override
  void toHadithReader({required int collectionId, required int initialHadithId, bool recordProgress = true}) {
		router.push(HadithDetailRoute(
			collectionId: collectionId,
			initialHadithId: initialHadithId,
			recordProgress: recordProgress,
		));
  }

  @override
  void toDuaLibrary() {
		router.push(DuaListRoute());
  }

  @override
  void toDuaReader({required int initialDuaId, bool recordProgress = true}) {
		router.push(DuaDetailRoute(
			initialDuaId: initialDuaId,
			recordProgress: recordProgress,
		));
  }

  @override
  void toDailyDua() {
		router.push(DailyDuaRoute());
  }

  @override
  void toQuiz() {
		router.push(QuizRoute());
  }

  @override
  void toPrayerTimes() {
		router.push(PrayerTimesRoute());
  }

  @override
  void toHijriCalendar() {
		router.push(CalendarRoute());
  }

  @override
  void toQiblaFinder() {
		router.push(QiblaFinderRoute());
  }

  @override
  void toZakatCalculator() {
		router.push(ZakatCalculatorRoute());
  }

  @override
  void toStreakReward({required int streakDay}) {
		router.push(RewardStreakRoute(streakDay: streakDay));
  }

  @override
  void toDailyDhikrReward({required int dhikrCompleted, required int ajrEarned}) {
		router.push(RewardDailyDhikrRoute(
			dhikrCompleted: dhikrCompleted,
			ajrEarned: ajrEarned,
		));
  }

  @override
  void toRemindersSettings() {
		router.push(RemindersRoute());
  }

  @override
  void toFavoriteReciterSettings() {
		router.push(FavoriteReciterRoute());
  }

  @override
  void toLanguageSettings() {
		router.push(LanguageRoute());
  }
}
