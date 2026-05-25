// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i31;
import 'package:flutter/material.dart' as _i32;
import 'package:nour/src/features/adhkar/ui/pages/adhkar_detail_page.dart'
    as _i1;
import 'package:nour/src/features/adhkar/ui/pages/adhkars_list_page.dart'
    as _i2;
import 'package:nour/src/features/auth/ui/pages/sign_in_page.dart' as _i24;
import 'package:nour/src/features/auth/ui/pages/sign_up_page.dart' as _i25;
import 'package:nour/src/features/dashboard/ui/pages/dashboard_page.dart'
    as _i7;
import 'package:nour/src/features/dhikr/ui/pages/dhikr_page.dart' as _i9;
import 'package:nour/src/features/dhikr/ui/pages/dhikrs_list_page.dart' as _i10;
import 'package:nour/src/features/dua/ui/pages/daily_dua_page.dart' as _i6;
import 'package:nour/src/features/dua/ui/pages/dua_detail_page.dart' as _i11;
import 'package:nour/src/features/dua/ui/pages/dua_list_page.dart' as _i12;
import 'package:nour/src/features/hadith/ui/pages/hadith_collection_detail_page.dart'
    as _i13;
import 'package:nour/src/features/hadith/ui/pages/hadith_detail_page.dart'
    as _i14;
import 'package:nour/src/features/home/dashboard_router_route.dart' as _i8;
import 'package:nour/src/features/home/home_page.dart' as _i15;
import 'package:nour/src/features/home/home_router_page.dart' as _i16;
import 'package:nour/src/features/home/impact_router_route.dart' as _i18;
import 'package:nour/src/features/home/source_router_page.dart' as _i27;
import 'package:nour/src/features/home/tools_router_route.dart' as _i30;
import 'package:nour/src/features/impact/ui/pages/impact_page.dart' as _i17;
import 'package:nour/src/features/onboarding/ui/pages/onboarding_page.dart'
    as _i19;
import 'package:nour/src/features/profile/ui/pages/profile_page.dart' as _i21;
import 'package:nour/src/features/quran/ui/pages/ayah_reader_page.dart' as _i3;
import 'package:nour/src/features/quran/ui/pages/daily_ayah_page.dart' as _i5;
import 'package:nour/src/features/quran/ui/pages/surah_detail_page.dart'
    as _i28;
import 'package:nour/src/features/root_page.dart' as _i22;
import 'package:nour/src/features/settings/ui/pages/settings_page.dart' as _i23;
import 'package:nour/src/features/source/ui/pages/source_page.dart' as _i26;
import 'package:nour/src/features/tools/ui/pages/calendar_page.dart' as _i4;
import 'package:nour/src/features/tools/ui/pages/prayer_times_page.dart'
    as _i20;
import 'package:nour/src/features/tools/ui/pages/tools_page.dart' as _i29;

/// generated route for
/// [_i1.AdhkarDetailPage]
class AdhkarDetailRoute extends _i31.PageRouteInfo<AdhkarDetailRouteArgs> {
  AdhkarDetailRoute({
    _i32.Key? key,
    required int subcategoryId,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         AdhkarDetailRoute.name,
         args: AdhkarDetailRouteArgs(key: key, subcategoryId: subcategoryId),
         initialChildren: children,
       );

  static const String name = 'AdhkarDetailRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdhkarDetailRouteArgs>();
      return _i1.AdhkarDetailPage(
        key: args.key,
        subcategoryId: args.subcategoryId,
      );
    },
  );
}

class AdhkarDetailRouteArgs {
  const AdhkarDetailRouteArgs({this.key, required this.subcategoryId});

  final _i32.Key? key;

  final int subcategoryId;

  @override
  String toString() {
    return 'AdhkarDetailRouteArgs{key: $key, subcategoryId: $subcategoryId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdhkarDetailRouteArgs) return false;
    return key == other.key && subcategoryId == other.subcategoryId;
  }

  @override
  int get hashCode => key.hashCode ^ subcategoryId.hashCode;
}

/// generated route for
/// [_i2.AdhkarsListPage]
class AdhkarsListRoute extends _i31.PageRouteInfo<void> {
  const AdhkarsListRoute({List<_i31.PageRouteInfo>? children})
    : super(AdhkarsListRoute.name, initialChildren: children);

  static const String name = 'AdhkarsListRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdhkarsListPage();
    },
  );
}

/// generated route for
/// [_i3.AyahReaderPage]
class AyahReaderRoute extends _i31.PageRouteInfo<AyahReaderRouteArgs> {
  AyahReaderRoute({
    _i32.Key? key,
    required int surahNumber,
    int initialAyah = 1,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         AyahReaderRoute.name,
         args: AyahReaderRouteArgs(
           key: key,
           surahNumber: surahNumber,
           initialAyah: initialAyah,
         ),
         initialChildren: children,
       );

  static const String name = 'AyahReaderRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AyahReaderRouteArgs>();
      return _i3.AyahReaderPage(
        key: args.key,
        surahNumber: args.surahNumber,
        initialAyah: args.initialAyah,
      );
    },
  );
}

class AyahReaderRouteArgs {
  const AyahReaderRouteArgs({
    this.key,
    required this.surahNumber,
    this.initialAyah = 1,
  });

  final _i32.Key? key;

  final int surahNumber;

  final int initialAyah;

  @override
  String toString() {
    return 'AyahReaderRouteArgs{key: $key, surahNumber: $surahNumber, initialAyah: $initialAyah}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AyahReaderRouteArgs) return false;
    return key == other.key &&
        surahNumber == other.surahNumber &&
        initialAyah == other.initialAyah;
  }

  @override
  int get hashCode =>
      key.hashCode ^ surahNumber.hashCode ^ initialAyah.hashCode;
}

/// generated route for
/// [_i4.CalendarPage]
class CalendarRoute extends _i31.PageRouteInfo<void> {
  const CalendarRoute({List<_i31.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i4.CalendarPage();
    },
  );
}

/// generated route for
/// [_i5.DailyAyahPage]
class DailyAyahRoute extends _i31.PageRouteInfo<void> {
  const DailyAyahRoute({List<_i31.PageRouteInfo>? children})
    : super(DailyAyahRoute.name, initialChildren: children);

  static const String name = 'DailyAyahRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i5.DailyAyahPage();
    },
  );
}

/// generated route for
/// [_i6.DailyDuaPage]
class DailyDuaRoute extends _i31.PageRouteInfo<void> {
  const DailyDuaRoute({List<_i31.PageRouteInfo>? children})
    : super(DailyDuaRoute.name, initialChildren: children);

  static const String name = 'DailyDuaRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i6.DailyDuaPage();
    },
  );
}

/// generated route for
/// [_i7.DashboardPage]
class DashboardRoute extends _i31.PageRouteInfo<void> {
  const DashboardRoute({List<_i31.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i7.DashboardPage();
    },
  );
}

/// generated route for
/// [_i8.DashboardRouterPage]
class DashboardRouterRoute extends _i31.PageRouteInfo<void> {
  const DashboardRouterRoute({List<_i31.PageRouteInfo>? children})
    : super(DashboardRouterRoute.name, initialChildren: children);

  static const String name = 'DashboardRouterRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i8.DashboardRouterPage();
    },
  );
}

/// generated route for
/// [_i9.DhikrPage]
class DhikrRoute extends _i31.PageRouteInfo<DhikrRouteArgs> {
  DhikrRoute({
    _i32.Key? key,
    int selectedId = 0,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         DhikrRoute.name,
         args: DhikrRouteArgs(key: key, selectedId: selectedId),
         initialChildren: children,
       );

  static const String name = 'DhikrRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DhikrRouteArgs>(
        orElse: () => const DhikrRouteArgs(),
      );
      return _i9.DhikrPage(key: args.key, selectedId: args.selectedId);
    },
  );
}

class DhikrRouteArgs {
  const DhikrRouteArgs({this.key, this.selectedId = 0});

  final _i32.Key? key;

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
/// [_i10.DhikrsListPage]
class DhikrsListRoute extends _i31.PageRouteInfo<void> {
  const DhikrsListRoute({List<_i31.PageRouteInfo>? children})
    : super(DhikrsListRoute.name, initialChildren: children);

  static const String name = 'DhikrsListRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i10.DhikrsListPage();
    },
  );
}

/// generated route for
/// [_i11.DuaDetailPage]
class DuaDetailRoute extends _i31.PageRouteInfo<DuaDetailRouteArgs> {
  DuaDetailRoute({
    _i32.Key? key,
    required int initialDuaId,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         DuaDetailRoute.name,
         args: DuaDetailRouteArgs(key: key, initialDuaId: initialDuaId),
         initialChildren: children,
       );

  static const String name = 'DuaDetailRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DuaDetailRouteArgs>();
      return _i11.DuaDetailPage(key: args.key, initialDuaId: args.initialDuaId);
    },
  );
}

class DuaDetailRouteArgs {
  const DuaDetailRouteArgs({this.key, required this.initialDuaId});

  final _i32.Key? key;

  final int initialDuaId;

  @override
  String toString() {
    return 'DuaDetailRouteArgs{key: $key, initialDuaId: $initialDuaId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DuaDetailRouteArgs) return false;
    return key == other.key && initialDuaId == other.initialDuaId;
  }

  @override
  int get hashCode => key.hashCode ^ initialDuaId.hashCode;
}

/// generated route for
/// [_i12.DuaListPage]
class DuaListRoute extends _i31.PageRouteInfo<void> {
  const DuaListRoute({List<_i31.PageRouteInfo>? children})
    : super(DuaListRoute.name, initialChildren: children);

  static const String name = 'DuaListRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i12.DuaListPage();
    },
  );
}

/// generated route for
/// [_i13.HadithCollectionDetailPage]
class HadithCollectionDetailRoute
    extends _i31.PageRouteInfo<HadithCollectionDetailRouteArgs> {
  HadithCollectionDetailRoute({
    _i32.Key? key,
    required int collectionId,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         HadithCollectionDetailRoute.name,
         args: HadithCollectionDetailRouteArgs(
           key: key,
           collectionId: collectionId,
         ),
         initialChildren: children,
       );

  static const String name = 'HadithCollectionDetailRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HadithCollectionDetailRouteArgs>();
      return _i13.HadithCollectionDetailPage(
        key: args.key,
        collectionId: args.collectionId,
      );
    },
  );
}

class HadithCollectionDetailRouteArgs {
  const HadithCollectionDetailRouteArgs({this.key, required this.collectionId});

  final _i32.Key? key;

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
/// [_i14.HadithDetailPage]
class HadithDetailRoute extends _i31.PageRouteInfo<HadithDetailRouteArgs> {
  HadithDetailRoute({
    _i32.Key? key,
    required int collectionId,
    required int initialHadithId,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         HadithDetailRoute.name,
         args: HadithDetailRouteArgs(
           key: key,
           collectionId: collectionId,
           initialHadithId: initialHadithId,
         ),
         initialChildren: children,
       );

  static const String name = 'HadithDetailRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HadithDetailRouteArgs>();
      return _i14.HadithDetailPage(
        key: args.key,
        collectionId: args.collectionId,
        initialHadithId: args.initialHadithId,
      );
    },
  );
}

class HadithDetailRouteArgs {
  const HadithDetailRouteArgs({
    this.key,
    required this.collectionId,
    required this.initialHadithId,
  });

  final _i32.Key? key;

  final int collectionId;

  final int initialHadithId;

  @override
  String toString() {
    return 'HadithDetailRouteArgs{key: $key, collectionId: $collectionId, initialHadithId: $initialHadithId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HadithDetailRouteArgs) return false;
    return key == other.key &&
        collectionId == other.collectionId &&
        initialHadithId == other.initialHadithId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ collectionId.hashCode ^ initialHadithId.hashCode;
}

/// generated route for
/// [_i15.HomePage]
class HomeRoute extends _i31.PageRouteInfo<void> {
  const HomeRoute({List<_i31.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i15.HomePage();
    },
  );
}

/// generated route for
/// [_i16.HomeRouterPage]
class HomeRouterRoute extends _i31.PageRouteInfo<void> {
  const HomeRouterRoute({List<_i31.PageRouteInfo>? children})
    : super(HomeRouterRoute.name, initialChildren: children);

  static const String name = 'HomeRouterRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i16.HomeRouterPage();
    },
  );
}

/// generated route for
/// [_i17.ImpactPage]
class ImpactRoute extends _i31.PageRouteInfo<void> {
  const ImpactRoute({List<_i31.PageRouteInfo>? children})
    : super(ImpactRoute.name, initialChildren: children);

  static const String name = 'ImpactRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i17.ImpactPage();
    },
  );
}

/// generated route for
/// [_i18.ImpactRouterPage]
class ImpactRouterRoute extends _i31.PageRouteInfo<void> {
  const ImpactRouterRoute({List<_i31.PageRouteInfo>? children})
    : super(ImpactRouterRoute.name, initialChildren: children);

  static const String name = 'ImpactRouterRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i18.ImpactRouterPage();
    },
  );
}

/// generated route for
/// [_i19.OnboardingPage]
class OnboardingRoute extends _i31.PageRouteInfo<void> {
  const OnboardingRoute({List<_i31.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i19.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i20.PrayerTimesPage]
class PrayerTimesRoute extends _i31.PageRouteInfo<void> {
  const PrayerTimesRoute({List<_i31.PageRouteInfo>? children})
    : super(PrayerTimesRoute.name, initialChildren: children);

  static const String name = 'PrayerTimesRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i20.PrayerTimesPage();
    },
  );
}

/// generated route for
/// [_i21.ProfilePage]
class ProfileRoute extends _i31.PageRouteInfo<void> {
  const ProfileRoute({List<_i31.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i21.ProfilePage();
    },
  );
}

/// generated route for
/// [_i22.RootPage]
class RootRoute extends _i31.PageRouteInfo<void> {
  const RootRoute({List<_i31.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i22.RootPage();
    },
  );
}

/// generated route for
/// [_i23.SettingsPage]
class SettingsRoute extends _i31.PageRouteInfo<void> {
  const SettingsRoute({List<_i31.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i23.SettingsPage();
    },
  );
}

/// generated route for
/// [_i24.SignInPage]
class SignInRoute extends _i31.PageRouteInfo<void> {
  const SignInRoute({List<_i31.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i24.SignInPage();
    },
  );
}

/// generated route for
/// [_i25.SignUpPage]
class SignUpRoute extends _i31.PageRouteInfo<void> {
  const SignUpRoute({List<_i31.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i25.SignUpPage();
    },
  );
}

/// generated route for
/// [_i26.SourcePage]
class SourceRoute extends _i31.PageRouteInfo<void> {
  const SourceRoute({List<_i31.PageRouteInfo>? children})
    : super(SourceRoute.name, initialChildren: children);

  static const String name = 'SourceRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i26.SourcePage();
    },
  );
}

/// generated route for
/// [_i27.SourceRouterPage]
class SourceRouterRoute extends _i31.PageRouteInfo<void> {
  const SourceRouterRoute({List<_i31.PageRouteInfo>? children})
    : super(SourceRouterRoute.name, initialChildren: children);

  static const String name = 'SourceRouterRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i27.SourceRouterPage();
    },
  );
}

/// generated route for
/// [_i28.SurahDetailPage]
class SurahDetailRoute extends _i31.PageRouteInfo<SurahDetailRouteArgs> {
  SurahDetailRoute({
    _i32.Key? key,
    required int surahNumber,
    List<_i31.PageRouteInfo>? children,
  }) : super(
         SurahDetailRoute.name,
         args: SurahDetailRouteArgs(key: key, surahNumber: surahNumber),
         initialChildren: children,
       );

  static const String name = 'SurahDetailRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SurahDetailRouteArgs>();
      return _i28.SurahDetailPage(key: args.key, surahNumber: args.surahNumber);
    },
  );
}

class SurahDetailRouteArgs {
  const SurahDetailRouteArgs({this.key, required this.surahNumber});

  final _i32.Key? key;

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
/// [_i29.ToolsPage]
class ToolsRoute extends _i31.PageRouteInfo<void> {
  const ToolsRoute({List<_i31.PageRouteInfo>? children})
    : super(ToolsRoute.name, initialChildren: children);

  static const String name = 'ToolsRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i29.ToolsPage();
    },
  );
}

/// generated route for
/// [_i30.ToolsRouterPage]
class ToolsRouterRoute extends _i31.PageRouteInfo<void> {
  const ToolsRouterRoute({List<_i31.PageRouteInfo>? children})
    : super(ToolsRouterRoute.name, initialChildren: children);

  static const String name = 'ToolsRouterRoute';

  static _i31.PageInfo page = _i31.PageInfo(
    name,
    builder: (data) {
      return const _i30.ToolsRouterPage();
    },
  );
}
