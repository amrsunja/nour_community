abstract class RoutePaths {
  static const root = '/';

  // Auth
  static const signIn= 'sign-in';
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
