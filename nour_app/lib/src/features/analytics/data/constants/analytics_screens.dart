/// Canonical, human-readable **screen names** for `screen_view` events.
///
/// The [AutoRouteObserver] (see `analytics_observer.dart`) maps `auto_route`
/// route names (e.g. `PrayerTimesRoute`) to these stable snake_case labels so
/// the GA4 funnel stays readable and decoupled from class renames.
abstract class AnalyticsScreens {
  AnalyticsScreens._();

  // Shell / tabs
  static const dashboard = 'dashboard';
  static const source = 'source';
  static const impact = 'impact';
  static const tools = 'tools';

  // Auth / onboarding
  static const signIn = 'sign_in';
  static const onboarding = 'onboarding';

  // Tools
  static const prayerTimes = 'prayer_times';
  static const qiblaFinder = 'qibla_finder';
  static const zakatCalculator = 'zakat_calculator';
  static const hijriCalendar = 'hijri_calendar';

  // Quran
  static const surahDetail = 'surah_detail';
  static const ayahReader = 'ayah_reader';
  static const dailyAyah = 'daily_ayah';

  // Dua / Adhkar / Dhikr
  static const duaLibrary = 'dua_library';
  static const duaReader = 'dua_reader';
  static const dailyDua = 'daily_dua';
  static const adhkarsList = 'adhkars_list';
  static const adhkarDetail = 'adhkar_detail';
  static const dhikrsList = 'dhikrs_list';
  static const dhikr = 'dhikr';

  // Hadith
  static const hadithCollection = 'hadith_collection';
  static const hadithReader = 'hadith_reader';

  // Quiz / impact / rewards
  static const quiz = 'quiz';
  static const impactProjectDetail = 'impact_project_detail';
  static const rewardStreak = 'reward_streak';
  static const rewardDailyDhikr = 'reward_daily_dhikr';

  // Profile / settings
  static const profile = 'profile';
  static const profileStatistics = 'profile_statistics';
  static const accountInformation = 'account_information';
  static const favorites = 'favorites';
  static const settings = 'settings';
  static const reminders = 'reminders';
  static const favoriteReciter = 'favorite_reciter';
  static const language = 'language';
  static const webView = 'web_view';

  /// Route-name → screen-name lookup. Keys are `auto_route` route names
  /// (class name minus `Page`/`Screen`, suffixed `Route`).
  static const Map<String, String> byRouteName = {
    'DashboardRoute': dashboard,
    'SourceRoute': source,
    'ImpactRoute': impact,
    'ToolsRoute': tools,
    'SignInRoute': signIn,
    'OnboardingRoute': onboarding,
    'PrayerTimesRoute': prayerTimes,
    'QiblaFinderRoute': qiblaFinder,
    'ZakatCalculatorRoute': zakatCalculator,
    'CalendarRoute': hijriCalendar,
    'SurahDetailRoute': surahDetail,
    'AyahReaderRoute': ayahReader,
    'DailyAyahRoute': dailyAyah,
    'DuaListRoute': duaLibrary,
    'DuaDetailRoute': duaReader,
    'DailyDuaRoute': dailyDua,
    'AdhkarsListRoute': adhkarsList,
    'AdhkarDetailRoute': adhkarDetail,
    'DhikrsListRoute': dhikrsList,
    'DhikrRoute': dhikr,
    'HadithCollectionDetailRoute': hadithCollection,
    'HadithDetailRoute': hadithReader,
    'QuizRoute': quiz,
    'ImpactProjectDetailRoute': impactProjectDetail,
    'RewardStreakRoute': rewardStreak,
    'RewardDailyDhikrRoute': rewardDailyDhikr,
    'ProfileRoute': profile,
    'ProfileStatisticsRoute': profileStatistics,
    'AccountInformationRoute': accountInformation,
    'FavoritesRoute': favorites,
    'SettingsRoute': settings,
    'RemindersRoute': reminders,
    'FavoriteReciterRoute': favoriteReciter,
    'LanguageRoute': language,
    'WebViewRoute': webView,
  };
}
