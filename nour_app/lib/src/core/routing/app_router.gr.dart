// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i44;
import 'package:flutter/material.dart' as _i45;
import 'package:nour/src/features/adhkar/ui/pages/adhkar_detail_page.dart'
    as _i2;
import 'package:nour/src/features/adhkar/ui/pages/adhkars_list_page.dart'
    as _i3;
import 'package:nour/src/features/auth/ui/pages/sign_in_page.dart' as _i35;
import 'package:nour/src/features/auth/ui/pages/sign_up_page.dart' as _i36;
import 'package:nour/src/features/dashboard/ui/pages/dashboard_page.dart'
    as _i8;
import 'package:nour/src/features/dhikr/ui/pages/dhikr_page.dart' as _i10;
import 'package:nour/src/features/dhikr/ui/pages/dhikrs_list_page.dart' as _i11;
import 'package:nour/src/features/dua/ui/pages/daily_dua_page.dart' as _i7;
import 'package:nour/src/features/dua/ui/pages/dua_detail_page.dart' as _i12;
import 'package:nour/src/features/dua/ui/pages/dua_list_page.dart' as _i13;
import 'package:nour/src/features/hadith/ui/pages/hadith_collection_detail_page.dart'
    as _i16;
import 'package:nour/src/features/hadith/ui/pages/hadith_detail_page.dart'
    as _i17;
import 'package:nour/src/features/home/dashboard_router_route.dart' as _i9;
import 'package:nour/src/features/home/home_page.dart' as _i18;
import 'package:nour/src/features/home/home_router_page.dart' as _i19;
import 'package:nour/src/features/home/impact_router_route.dart' as _i22;
import 'package:nour/src/features/home/source_router_page.dart' as _i38;
import 'package:nour/src/features/home/tools_router_route.dart' as _i41;
import 'package:nour/src/features/impact/ui/pages/impact_page.dart' as _i20;
import 'package:nour/src/features/impact/ui/pages/impact_project_detail_page.dart'
    as _i21;
import 'package:nour/src/features/onboarding/ui/pages/onboarding_page.dart'
    as _i24;
import 'package:nour/src/features/profile/ui/pages/account_information_page.dart'
    as _i1;
import 'package:nour/src/features/profile/ui/pages/favorites_page.dart' as _i15;
import 'package:nour/src/features/profile/ui/pages/profile_page.dart' as _i26;
import 'package:nour/src/features/profile/ui/pages/profile_statistics_page.dart'
    as _i27;
import 'package:nour/src/features/profile/ui/pages/reward_daily_dhikr_page.dart'
    as _i31;
import 'package:nour/src/features/profile/ui/pages/reward_streak_page.dart'
    as _i32;
import 'package:nour/src/features/quiz/ui/pages/quiz_page.dart' as _i29;
import 'package:nour/src/features/quran/ui/pages/ayah_reader_page.dart' as _i4;
import 'package:nour/src/features/quran/ui/pages/daily_ayah_page.dart' as _i6;
import 'package:nour/src/features/quran/ui/pages/surah_detail_page.dart'
    as _i39;
import 'package:nour/src/features/root_page.dart' as _i33;
import 'package:nour/src/features/settings/ui/pages/favorite_reciter_page.dart'
    as _i14;
import 'package:nour/src/features/settings/ui/pages/language_page.dart' as _i23;
import 'package:nour/src/features/settings/ui/pages/reminders_page.dart'
    as _i30;
import 'package:nour/src/features/settings/ui/pages/settings_page.dart' as _i34;
import 'package:nour/src/features/source/ui/pages/source_page.dart' as _i37;
import 'package:nour/src/features/tools/ui/pages/calendar_page.dart' as _i5;
import 'package:nour/src/features/tools/ui/pages/prayer_times_page.dart'
    as _i25;
import 'package:nour/src/features/tools/ui/pages/qibla_finder_page.dart'
    as _i28;
import 'package:nour/src/features/tools/ui/pages/tools_page.dart' as _i40;
import 'package:nour/src/features/tools/ui/pages/zakat_calculator_page.dart'
    as _i43;
import 'package:nour/src/features/webview/ui/pages/web_view_page.dart' as _i42;

/// generated route for
/// [_i1.AccountInformationPage]
class AccountInformationRoute extends _i44.PageRouteInfo<void> {
  const AccountInformationRoute({List<_i44.PageRouteInfo>? children})
    : super(AccountInformationRoute.name, initialChildren: children);

  static const String name = 'AccountInformationRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountInformationPage();
    },
  );
}

/// generated route for
/// [_i2.AdhkarDetailPage]
class AdhkarDetailRoute extends _i44.PageRouteInfo<AdhkarDetailRouteArgs> {
  AdhkarDetailRoute({
    _i45.Key? key,
    required int subcategoryId,
    int? initialAdhkarId,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         AdhkarDetailRoute.name,
         args: AdhkarDetailRouteArgs(
           key: key,
           subcategoryId: subcategoryId,
           initialAdhkarId: initialAdhkarId,
         ),
         initialChildren: children,
       );

  static const String name = 'AdhkarDetailRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdhkarDetailRouteArgs>();
      return _i2.AdhkarDetailPage(
        key: args.key,
        subcategoryId: args.subcategoryId,
        initialAdhkarId: args.initialAdhkarId,
      );
    },
  );
}

class AdhkarDetailRouteArgs {
  const AdhkarDetailRouteArgs({
    this.key,
    required this.subcategoryId,
    this.initialAdhkarId,
  });

  final _i45.Key? key;

  final int subcategoryId;

  final int? initialAdhkarId;

  @override
  String toString() {
    return 'AdhkarDetailRouteArgs{key: $key, subcategoryId: $subcategoryId, initialAdhkarId: $initialAdhkarId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdhkarDetailRouteArgs) return false;
    return key == other.key &&
        subcategoryId == other.subcategoryId &&
        initialAdhkarId == other.initialAdhkarId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ subcategoryId.hashCode ^ initialAdhkarId.hashCode;
}

/// generated route for
/// [_i3.AdhkarsListPage]
class AdhkarsListRoute extends _i44.PageRouteInfo<void> {
  const AdhkarsListRoute({List<_i44.PageRouteInfo>? children})
    : super(AdhkarsListRoute.name, initialChildren: children);

  static const String name = 'AdhkarsListRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdhkarsListPage();
    },
  );
}

/// generated route for
/// [_i4.AyahReaderPage]
class AyahReaderRoute extends _i44.PageRouteInfo<AyahReaderRouteArgs> {
  AyahReaderRoute({
    _i45.Key? key,
    required int surahNumber,
    int initialAyah = 1,
    bool recordProgress = true,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         AyahReaderRoute.name,
         args: AyahReaderRouteArgs(
           key: key,
           surahNumber: surahNumber,
           initialAyah: initialAyah,
           recordProgress: recordProgress,
         ),
         initialChildren: children,
       );

  static const String name = 'AyahReaderRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AyahReaderRouteArgs>();
      return _i4.AyahReaderPage(
        key: args.key,
        surahNumber: args.surahNumber,
        initialAyah: args.initialAyah,
        recordProgress: args.recordProgress,
      );
    },
  );
}

class AyahReaderRouteArgs {
  const AyahReaderRouteArgs({
    this.key,
    required this.surahNumber,
    this.initialAyah = 1,
    this.recordProgress = true,
  });

  final _i45.Key? key;

  final int surahNumber;

  final int initialAyah;

  final bool recordProgress;

  @override
  String toString() {
    return 'AyahReaderRouteArgs{key: $key, surahNumber: $surahNumber, initialAyah: $initialAyah, recordProgress: $recordProgress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AyahReaderRouteArgs) return false;
    return key == other.key &&
        surahNumber == other.surahNumber &&
        initialAyah == other.initialAyah &&
        recordProgress == other.recordProgress;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      surahNumber.hashCode ^
      initialAyah.hashCode ^
      recordProgress.hashCode;
}

/// generated route for
/// [_i5.CalendarPage]
class CalendarRoute extends _i44.PageRouteInfo<void> {
  const CalendarRoute({List<_i44.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i5.CalendarPage();
    },
  );
}

/// generated route for
/// [_i6.DailyAyahPage]
class DailyAyahRoute extends _i44.PageRouteInfo<void> {
  const DailyAyahRoute({List<_i44.PageRouteInfo>? children})
    : super(DailyAyahRoute.name, initialChildren: children);

  static const String name = 'DailyAyahRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i6.DailyAyahPage();
    },
  );
}

/// generated route for
/// [_i7.DailyDuaPage]
class DailyDuaRoute extends _i44.PageRouteInfo<void> {
  const DailyDuaRoute({List<_i44.PageRouteInfo>? children})
    : super(DailyDuaRoute.name, initialChildren: children);

  static const String name = 'DailyDuaRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i7.DailyDuaPage();
    },
  );
}

/// generated route for
/// [_i8.DashboardPage]
class DashboardRoute extends _i44.PageRouteInfo<void> {
  const DashboardRoute({List<_i44.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i8.DashboardPage();
    },
  );
}

/// generated route for
/// [_i9.DashboardRouterPage]
class DashboardRouterRoute extends _i44.PageRouteInfo<void> {
  const DashboardRouterRoute({List<_i44.PageRouteInfo>? children})
    : super(DashboardRouterRoute.name, initialChildren: children);

  static const String name = 'DashboardRouterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i9.DashboardRouterPage();
    },
  );
}

/// generated route for
/// [_i10.DhikrPage]
class DhikrRoute extends _i44.PageRouteInfo<DhikrRouteArgs> {
  DhikrRoute({
    _i45.Key? key,
    int selectedId = 0,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         DhikrRoute.name,
         args: DhikrRouteArgs(key: key, selectedId: selectedId),
         initialChildren: children,
       );

  static const String name = 'DhikrRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DhikrRouteArgs>(
        orElse: () => const DhikrRouteArgs(),
      );
      return _i10.DhikrPage(key: args.key, selectedId: args.selectedId);
    },
  );
}

class DhikrRouteArgs {
  const DhikrRouteArgs({this.key, this.selectedId = 0});

  final _i45.Key? key;

  final int selectedId;

  @override
  String toString() {
    return 'DhikrRouteArgs{key: $key, selectedId: $selectedId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DhikrRouteArgs) return false;
    return key == other.key && selectedId == other.selectedId;
  }

  @override
  int get hashCode => key.hashCode ^ selectedId.hashCode;
}

/// generated route for
/// [_i11.DhikrsListPage]
class DhikrsListRoute extends _i44.PageRouteInfo<void> {
  const DhikrsListRoute({List<_i44.PageRouteInfo>? children})
    : super(DhikrsListRoute.name, initialChildren: children);

  static const String name = 'DhikrsListRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i11.DhikrsListPage();
    },
  );
}

/// generated route for
/// [_i12.DuaDetailPage]
class DuaDetailRoute extends _i44.PageRouteInfo<DuaDetailRouteArgs> {
  DuaDetailRoute({
    _i45.Key? key,
    required int initialDuaId,
    bool recordProgress = true,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         DuaDetailRoute.name,
         args: DuaDetailRouteArgs(
           key: key,
           initialDuaId: initialDuaId,
           recordProgress: recordProgress,
         ),
         initialChildren: children,
       );

  static const String name = 'DuaDetailRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DuaDetailRouteArgs>();
      return _i12.DuaDetailPage(
        key: args.key,
        initialDuaId: args.initialDuaId,
        recordProgress: args.recordProgress,
      );
    },
  );
}

class DuaDetailRouteArgs {
  const DuaDetailRouteArgs({
    this.key,
    required this.initialDuaId,
    this.recordProgress = true,
  });

  final _i45.Key? key;

  final int initialDuaId;

  final bool recordProgress;

  @override
  String toString() {
    return 'DuaDetailRouteArgs{key: $key, initialDuaId: $initialDuaId, recordProgress: $recordProgress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DuaDetailRouteArgs) return false;
    return key == other.key &&
        initialDuaId == other.initialDuaId &&
        recordProgress == other.recordProgress;
  }

  @override
  int get hashCode =>
      key.hashCode ^ initialDuaId.hashCode ^ recordProgress.hashCode;
}

/// generated route for
/// [_i13.DuaListPage]
class DuaListRoute extends _i44.PageRouteInfo<void> {
  const DuaListRoute({List<_i44.PageRouteInfo>? children})
    : super(DuaListRoute.name, initialChildren: children);

  static const String name = 'DuaListRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i13.DuaListPage();
    },
  );
}

/// generated route for
/// [_i14.FavoriteReciterPage]
class FavoriteReciterRoute extends _i44.PageRouteInfo<void> {
  const FavoriteReciterRoute({List<_i44.PageRouteInfo>? children})
    : super(FavoriteReciterRoute.name, initialChildren: children);

  static const String name = 'FavoriteReciterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i14.FavoriteReciterPage();
    },
  );
}

/// generated route for
/// [_i15.FavoritesPage]
class FavoritesRoute extends _i44.PageRouteInfo<void> {
  const FavoritesRoute({List<_i44.PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i15.FavoritesPage();
    },
  );
}

/// generated route for
/// [_i16.HadithCollectionDetailPage]
class HadithCollectionDetailRoute
    extends _i44.PageRouteInfo<HadithCollectionDetailRouteArgs> {
  HadithCollectionDetailRoute({
    _i45.Key? key,
    required int collectionId,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         HadithCollectionDetailRoute.name,
         args: HadithCollectionDetailRouteArgs(
           key: key,
           collectionId: collectionId,
         ),
         initialChildren: children,
       );

  static const String name = 'HadithCollectionDetailRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HadithCollectionDetailRouteArgs>();
      return _i16.HadithCollectionDetailPage(
        key: args.key,
        collectionId: args.collectionId,
      );
    },
  );
}

class HadithCollectionDetailRouteArgs {
  const HadithCollectionDetailRouteArgs({this.key, required this.collectionId});

  final _i45.Key? key;

  final int collectionId;

  @override
  String toString() {
    return 'HadithCollectionDetailRouteArgs{key: $key, collectionId: $collectionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HadithCollectionDetailRouteArgs) return false;
    return key == other.key && collectionId == other.collectionId;
  }

  @override
  int get hashCode => key.hashCode ^ collectionId.hashCode;
}

/// generated route for
/// [_i17.HadithDetailPage]
class HadithDetailRoute extends _i44.PageRouteInfo<HadithDetailRouteArgs> {
  HadithDetailRoute({
    _i45.Key? key,
    required int collectionId,
    required int initialHadithId,
    bool recordProgress = true,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         HadithDetailRoute.name,
         args: HadithDetailRouteArgs(
           key: key,
           collectionId: collectionId,
           initialHadithId: initialHadithId,
           recordProgress: recordProgress,
         ),
         initialChildren: children,
       );

  static const String name = 'HadithDetailRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HadithDetailRouteArgs>();
      return _i17.HadithDetailPage(
        key: args.key,
        collectionId: args.collectionId,
        initialHadithId: args.initialHadithId,
        recordProgress: args.recordProgress,
      );
    },
  );
}

class HadithDetailRouteArgs {
  const HadithDetailRouteArgs({
    this.key,
    required this.collectionId,
    required this.initialHadithId,
    this.recordProgress = true,
  });

  final _i45.Key? key;

  final int collectionId;

  final int initialHadithId;

  final bool recordProgress;

  @override
  String toString() {
    return 'HadithDetailRouteArgs{key: $key, collectionId: $collectionId, initialHadithId: $initialHadithId, recordProgress: $recordProgress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HadithDetailRouteArgs) return false;
    return key == other.key &&
        collectionId == other.collectionId &&
        initialHadithId == other.initialHadithId &&
        recordProgress == other.recordProgress;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      collectionId.hashCode ^
      initialHadithId.hashCode ^
      recordProgress.hashCode;
}

/// generated route for
/// [_i18.HomePage]
class HomeRoute extends _i44.PageRouteInfo<void> {
  const HomeRoute({List<_i44.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i18.HomePage();
    },
  );
}

/// generated route for
/// [_i19.HomeRouterPage]
class HomeRouterRoute extends _i44.PageRouteInfo<void> {
  const HomeRouterRoute({List<_i44.PageRouteInfo>? children})
    : super(HomeRouterRoute.name, initialChildren: children);

  static const String name = 'HomeRouterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i19.HomeRouterPage();
    },
  );
}

/// generated route for
/// [_i20.ImpactPage]
class ImpactRoute extends _i44.PageRouteInfo<void> {
  const ImpactRoute({List<_i44.PageRouteInfo>? children})
    : super(ImpactRoute.name, initialChildren: children);

  static const String name = 'ImpactRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i20.ImpactPage();
    },
  );
}

/// generated route for
/// [_i21.ImpactProjectDetailPage]
class ImpactProjectDetailRoute
    extends _i44.PageRouteInfo<ImpactProjectDetailRouteArgs> {
  ImpactProjectDetailRoute({
    _i45.Key? key,
    required int projectId,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         ImpactProjectDetailRoute.name,
         args: ImpactProjectDetailRouteArgs(key: key, projectId: projectId),
         initialChildren: children,
       );

  static const String name = 'ImpactProjectDetailRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ImpactProjectDetailRouteArgs>();
      return _i21.ImpactProjectDetailPage(
        key: args.key,
        projectId: args.projectId,
      );
    },
  );
}

class ImpactProjectDetailRouteArgs {
  const ImpactProjectDetailRouteArgs({this.key, required this.projectId});

  final _i45.Key? key;

  final int projectId;

  @override
  String toString() {
    return 'ImpactProjectDetailRouteArgs{key: $key, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImpactProjectDetailRouteArgs) return false;
    return key == other.key && projectId == other.projectId;
  }

  @override
  int get hashCode => key.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [_i22.ImpactRouterPage]
class ImpactRouterRoute extends _i44.PageRouteInfo<void> {
  const ImpactRouterRoute({List<_i44.PageRouteInfo>? children})
    : super(ImpactRouterRoute.name, initialChildren: children);

  static const String name = 'ImpactRouterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i22.ImpactRouterPage();
    },
  );
}

/// generated route for
/// [_i23.LanguagePage]
class LanguageRoute extends _i44.PageRouteInfo<void> {
  const LanguageRoute({List<_i44.PageRouteInfo>? children})
    : super(LanguageRoute.name, initialChildren: children);

  static const String name = 'LanguageRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i23.LanguagePage();
    },
  );
}

/// generated route for
/// [_i24.OnboardingPage]
class OnboardingRoute extends _i44.PageRouteInfo<void> {
  const OnboardingRoute({List<_i44.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i24.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i25.PrayerTimesPage]
class PrayerTimesRoute extends _i44.PageRouteInfo<void> {
  const PrayerTimesRoute({List<_i44.PageRouteInfo>? children})
    : super(PrayerTimesRoute.name, initialChildren: children);

  static const String name = 'PrayerTimesRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i25.PrayerTimesPage();
    },
  );
}

/// generated route for
/// [_i26.ProfilePage]
class ProfileRoute extends _i44.PageRouteInfo<void> {
  const ProfileRoute({List<_i44.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i26.ProfilePage();
    },
  );
}

/// generated route for
/// [_i27.ProfileStatisticsPage]
class ProfileStatisticsRoute extends _i44.PageRouteInfo<void> {
  const ProfileStatisticsRoute({List<_i44.PageRouteInfo>? children})
    : super(ProfileStatisticsRoute.name, initialChildren: children);

  static const String name = 'ProfileStatisticsRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i27.ProfileStatisticsPage();
    },
  );
}

/// generated route for
/// [_i28.QiblaFinderPage]
class QiblaFinderRoute extends _i44.PageRouteInfo<void> {
  const QiblaFinderRoute({List<_i44.PageRouteInfo>? children})
    : super(QiblaFinderRoute.name, initialChildren: children);

  static const String name = 'QiblaFinderRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i28.QiblaFinderPage();
    },
  );
}

/// generated route for
/// [_i29.QuizPage]
class QuizRoute extends _i44.PageRouteInfo<void> {
  const QuizRoute({List<_i44.PageRouteInfo>? children})
    : super(QuizRoute.name, initialChildren: children);

  static const String name = 'QuizRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i29.QuizPage();
    },
  );
}

/// generated route for
/// [_i30.RemindersPage]
class RemindersRoute extends _i44.PageRouteInfo<void> {
  const RemindersRoute({List<_i44.PageRouteInfo>? children})
    : super(RemindersRoute.name, initialChildren: children);

  static const String name = 'RemindersRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i30.RemindersPage();
    },
  );
}

/// generated route for
/// [_i31.RewardDailyDhikrPage]
class RewardDailyDhikrRoute
    extends _i44.PageRouteInfo<RewardDailyDhikrRouteArgs> {
  RewardDailyDhikrRoute({
    _i45.Key? key,
    int dhikrCompleted = 0,
    int ajrEarned = 0,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         RewardDailyDhikrRoute.name,
         args: RewardDailyDhikrRouteArgs(
           key: key,
           dhikrCompleted: dhikrCompleted,
           ajrEarned: ajrEarned,
         ),
         initialChildren: children,
       );

  static const String name = 'RewardDailyDhikrRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RewardDailyDhikrRouteArgs>(
        orElse: () => const RewardDailyDhikrRouteArgs(),
      );
      return _i31.RewardDailyDhikrPage(
        key: args.key,
        dhikrCompleted: args.dhikrCompleted,
        ajrEarned: args.ajrEarned,
      );
    },
  );
}

class RewardDailyDhikrRouteArgs {
  const RewardDailyDhikrRouteArgs({
    this.key,
    this.dhikrCompleted = 0,
    this.ajrEarned = 0,
  });

  final _i45.Key? key;

  final int dhikrCompleted;

  final int ajrEarned;

  @override
  String toString() {
    return 'RewardDailyDhikrRouteArgs{key: $key, dhikrCompleted: $dhikrCompleted, ajrEarned: $ajrEarned}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RewardDailyDhikrRouteArgs) return false;
    return key == other.key &&
        dhikrCompleted == other.dhikrCompleted &&
        ajrEarned == other.ajrEarned;
  }

  @override
  int get hashCode =>
      key.hashCode ^ dhikrCompleted.hashCode ^ ajrEarned.hashCode;
}

/// generated route for
/// [_i32.RewardStreakPage]
class RewardStreakRoute extends _i44.PageRouteInfo<RewardStreakRouteArgs> {
  RewardStreakRoute({
    _i45.Key? key,
    int streakDay = 1,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         RewardStreakRoute.name,
         args: RewardStreakRouteArgs(key: key, streakDay: streakDay),
         initialChildren: children,
       );

  static const String name = 'RewardStreakRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RewardStreakRouteArgs>(
        orElse: () => const RewardStreakRouteArgs(),
      );
      return _i32.RewardStreakPage(key: args.key, streakDay: args.streakDay);
    },
  );
}

class RewardStreakRouteArgs {
  const RewardStreakRouteArgs({this.key, this.streakDay = 1});

  final _i45.Key? key;

  final int streakDay;

  @override
  String toString() {
    return 'RewardStreakRouteArgs{key: $key, streakDay: $streakDay}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RewardStreakRouteArgs) return false;
    return key == other.key && streakDay == other.streakDay;
  }

  @override
  int get hashCode => key.hashCode ^ streakDay.hashCode;
}

/// generated route for
/// [_i33.RootPage]
class RootRoute extends _i44.PageRouteInfo<void> {
  const RootRoute({List<_i44.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i33.RootPage();
    },
  );
}

/// generated route for
/// [_i34.SettingsPage]
class SettingsRoute extends _i44.PageRouteInfo<void> {
  const SettingsRoute({List<_i44.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i34.SettingsPage();
    },
  );
}

/// generated route for
/// [_i35.SignInPage]
class SignInRoute extends _i44.PageRouteInfo<void> {
  const SignInRoute({List<_i44.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i35.SignInPage();
    },
  );
}

/// generated route for
/// [_i36.SignUpPage]
class SignUpRoute extends _i44.PageRouteInfo<void> {
  const SignUpRoute({List<_i44.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i36.SignUpPage();
    },
  );
}

/// generated route for
/// [_i37.SourcePage]
class SourceRoute extends _i44.PageRouteInfo<void> {
  const SourceRoute({List<_i44.PageRouteInfo>? children})
    : super(SourceRoute.name, initialChildren: children);

  static const String name = 'SourceRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i37.SourcePage();
    },
  );
}

/// generated route for
/// [_i38.SourceRouterPage]
class SourceRouterRoute extends _i44.PageRouteInfo<void> {
  const SourceRouterRoute({List<_i44.PageRouteInfo>? children})
    : super(SourceRouterRoute.name, initialChildren: children);

  static const String name = 'SourceRouterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i38.SourceRouterPage();
    },
  );
}

/// generated route for
/// [_i39.SurahDetailPage]
class SurahDetailRoute extends _i44.PageRouteInfo<SurahDetailRouteArgs> {
  SurahDetailRoute({
    _i45.Key? key,
    required int surahNumber,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         SurahDetailRoute.name,
         args: SurahDetailRouteArgs(key: key, surahNumber: surahNumber),
         initialChildren: children,
       );

  static const String name = 'SurahDetailRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SurahDetailRouteArgs>();
      return _i39.SurahDetailPage(key: args.key, surahNumber: args.surahNumber);
    },
  );
}

class SurahDetailRouteArgs {
  const SurahDetailRouteArgs({this.key, required this.surahNumber});

  final _i45.Key? key;

  final int surahNumber;

  @override
  String toString() {
    return 'SurahDetailRouteArgs{key: $key, surahNumber: $surahNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SurahDetailRouteArgs) return false;
    return key == other.key && surahNumber == other.surahNumber;
  }

  @override
  int get hashCode => key.hashCode ^ surahNumber.hashCode;
}

/// generated route for
/// [_i40.ToolsPage]
class ToolsRoute extends _i44.PageRouteInfo<void> {
  const ToolsRoute({List<_i44.PageRouteInfo>? children})
    : super(ToolsRoute.name, initialChildren: children);

  static const String name = 'ToolsRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i40.ToolsPage();
    },
  );
}

/// generated route for
/// [_i41.ToolsRouterPage]
class ToolsRouterRoute extends _i44.PageRouteInfo<void> {
  const ToolsRouterRoute({List<_i44.PageRouteInfo>? children})
    : super(ToolsRouterRoute.name, initialChildren: children);

  static const String name = 'ToolsRouterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i41.ToolsRouterPage();
    },
  );
}

/// generated route for
/// [_i42.WebViewPage]
class WebViewRoute extends _i44.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i45.Key? key,
    required String url,
    required String title,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i42.WebViewPage(key: args.key, url: args.url, title: args.title);
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, required this.title});

  final _i45.Key? key;

  final String url;

  final String title;

  @override
  String toString() {
    return 'WebViewRouteArgs{key: $key, url: $url, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WebViewRouteArgs) return false;
    return key == other.key && url == other.url && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ url.hashCode ^ title.hashCode;
}

/// generated route for
/// [_i43.ZakatCalculatorPage]
class ZakatCalculatorRoute extends _i44.PageRouteInfo<void> {
  const ZakatCalculatorRoute({List<_i44.PageRouteInfo>? children})
    : super(ZakatCalculatorRoute.name, initialChildren: children);

  static const String name = 'ZakatCalculatorRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i43.ZakatCalculatorPage();
    },
  );
}
