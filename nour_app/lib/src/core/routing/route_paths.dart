abstract class RoutePaths {
  static const root = '/';

  // Auth
  static const signIn= 'sign-in';
  static const welcome = 'welcome';
  static const profileType = 'profile-type';

  // Mosque accounts (§3)
  static const mosqueOnboarding = 'mosque-onboarding';
  static const mosqueReview = 'mosque-review';
  static const mosqueAdmin = 'mosque-admin';
  static const mosqueAdminDashboard = 'dashboard';
  static const mosqueAdminCommunity = 'community';
  static const mosqueAdminMosque = 'mosque';
  static const mosqueAdminPost = 'mosque-admin/post';
  /// `mosque-admin/post/event` — `:type` is a MosquePostType db value.
  static String mosqueAdminPostForm({String? type}) => 'mosque-admin/post/${type ?? ':type'}';
  static const mosqueAdminEditProfile = 'mosque-admin/edit-profile';
  static const mosqueAdminNotifications = 'mosque-admin/notifications';
  static const mosqueAdminProfile = 'mosque-admin/profile';
  static const mosqueAdminSettings = 'mosque-admin/settings';
  static const mosqueAdminPushSettings = 'mosque-admin/push-settings';
  static const mosqueAdminReminders = 'mosque-admin/reminders';
  static const mosqueAdminLanguage = 'mosque-admin/language';
  static const mosqueAdminAccount = 'mosque-admin/account';
  static const mosqueAdminWebView = 'mosque-admin/web-view';
  // P3 — donations
  static const mosqueAdminSadaqaSettings = 'mosque-admin/donations/settings';
  static const mosqueAdminStripe = 'mosque-admin/donations/stripe';
  static const mosqueAdminCampaignForm = 'mosque-admin/donations/campaign-form';
  static String mosqueAdminCampaign({int? campaignId}) => 'mosque-admin/donations/campaign/${campaignId ?? ':campaignId'}';
  static const mosqueAdminDonors = 'mosque-admin/donations/donors';
  static const mosqueAdminReceipts = 'mosque-admin/donations/receipts';

  // Mosques — worshipper side
  static const mosqueSearch = 'mosques/search';
  /// `mosque/12?tab=news&postId=` — `:id` is the mosque id.
  static String mosqueProfile({int? id}) => 'mosque/${id ?? ':id'}';
  static String mosqueMember({int? id}) => 'mosque/${id ?? ':id'}/member';
  static String mosqueCampaign({int? id, int? campaignId}) =>
      'mosque/${id ?? ':id'}/campaign/${campaignId ?? ':campaignId'}';
  static String mosqueCheckout({int? id}) => 'mosque/${id ?? ':id'}/checkout';
  static const myMosqueReceipts = 'mosque-receipts';
  static const pushSettings = 'push-settings';
  //static const signUp= 'sign-up';
  static const onboarding = 'onboarding';

  // Main
  static const home = '';

  static const dashboard = 'dashboard';
  static const source = 'source';
  static const impact = 'impact';
  static const tools = 'tools';
  static const settings = 'settings';
  static const profile = 'profile';
  static const profileStatistics = 'profile-statistics';
  static const adminDashboard = 'admin-dashboard';
  static const accountInformation = 'account-information';
  static const webView = 'web-view';
  static const favorites = 'favorites';
  static const reminders = 'reminders';
  static const favoriteReciter = 'favorite-reciter';
  static const language = 'language';

  // Dhikr
  static const dhikrsList = 'dhikrs';
  static const dhikr = 'dhikr';

  // Adhkar
  static const adhkarsList = 'adhkars-list';

  /// `adhkar/87` — `:id` is the subcategory id.
  /// Optional `?adhkarId=` query param jumps to a specific adhkar.
  static String adhkarDetail({int? id}) => 'adhkar/${id ?? ':id'}';

  // Impact

  /// `project/12` — `:id` is the impact project id.
  static String impactProjectDetail({int? id}) => 'project/${id ?? ':id'}';

  // Payments (donation flow)

  /// `checkout/12?amount=&frequency=&zakat=` — `:projectId` is the project id.
  static String checkout({int? projectId}) =>
      'checkout/${projectId ?? ':projectId'}';

  /// `donation-reward/12?amount=&frequency=` — shown after a confirmed payment.
  static String donationReward({int? projectId}) =>
      'donation-reward/${projectId ?? ':projectId'}';

  /// Profile → history + recurring donations.
  static const myDonations = 'my-donations';

  /// Zakat calculator → multi-project zakat payment.
  static const zakatCheckout = 'zakat-checkout';
  static const zakatReward = 'zakat-reward';

  // Quran

  /// `surah/2` — `:surahId` is the surah number.
  static String surahDetail({int? surahId}) => 'surah/${surahId ?? ':surahId'}';

  /// `surah/2/ayah/255` — exact ayah in the immersive reader.
  static String ayahReader({int? surahId, int? ayahId}) =>
      'surah/${surahId ?? ':surahId'}/ayah/${ayahId ?? ':ayahId'}';

  static const dailyAyah = 'daily-ayah';

  // Hadith

  /// `hadith-collection/3` — `:id` is the collection id.
  static String hadithCollectionDetail({int? id}) =>
      'hadith-collection/${id ?? ':id'}';

  /// `hadith/3/123` — collection id + hadith id (the reader needs both).
  static String hadithReader({int? collectionId, int? hadithId}) =>
      'hadith/${collectionId ?? ':collectionId'}/${hadithId ?? ':hadithId'}';

  // Dua
  static const duaLibrary = 'dua-library';

  /// `dua/45` — `:id` is the dua id.
  static String duaReader({int? id}) => 'dua/${id ?? ':id'}';

  static const dailyDua = 'daily-dua';

  // Quiz
  static const quiz = 'quiz';

  // Tools
  static const prayerTimes = 'prayer-times';
  static const hijriCalendar = 'hijri-calendar';
  static const qiblaFinder = 'qibla-finder';
  static const zakatCalculator = 'zakat-calculator';

  // Rewards (full-screen celebratory pages over the navbar)
  static const rewardStreak = 'reward-streak';
  static const rewardDailyDhikr = 'reward-daily-dhikr';


  // Root dialog
	static const String chooseLanguage = 'choose-language';
}
