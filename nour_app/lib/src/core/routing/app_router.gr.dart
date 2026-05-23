// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:flutter/material.dart' as _i23;
import 'package:nour/src/features/adhkar/ui/pages/adhkar_detail_page.dart'
    as _i1;
import 'package:nour/src/features/adhkar/ui/pages/adhkars_list_page.dart'
    as _i2;
import 'package:nour/src/features/auth/ui/pages/sign_in_page.dart' as _i15;
import 'package:nour/src/features/auth/ui/pages/sign_up_page.dart' as _i16;
import 'package:nour/src/features/dashboard/ui/pages/dashboard_page.dart'
    as _i4;
import 'package:nour/src/features/dhikr/ui/pages/dhikr_page.dart' as _i6;
import 'package:nour/src/features/dhikr/ui/pages/dhikrs_list_page.dart' as _i7;
import 'package:nour/src/features/home/dashboard_router_route.dart' as _i5;
import 'package:nour/src/features/home/home_page.dart' as _i8;
import 'package:nour/src/features/home/home_router_page.dart' as _i9;
import 'package:nour/src/features/home/impact_router_route.dart' as _i11;
import 'package:nour/src/features/home/source_router_page.dart' as _i18;
import 'package:nour/src/features/home/tools_router_route.dart' as _i21;
import 'package:nour/src/features/impact/ui/pages/impact_page.dart' as _i10;
import 'package:nour/src/features/onboarding/ui/pages/onboarding_page.dart'
    as _i12;
import 'package:nour/src/features/quran/ui/pages/ayah_reader_page.dart' as _i3;
import 'package:nour/src/features/quran/ui/pages/surah_detail_page.dart'
    as _i19;
import 'package:nour/src/features/root_page.dart' as _i13;
import 'package:nour/src/features/settings/ui/pages/settings_page.dart' as _i14;
import 'package:nour/src/features/source/ui/pages/source_page.dart' as _i17;
import 'package:nour/src/features/tools/ui/pages/tools_page.dart' as _i20;

/// generated route for
/// [_i1.AdhkarDetailPage]
class AdhkarDetailRoute extends _i22.PageRouteInfo<AdhkarDetailRouteArgs> {
  AdhkarDetailRoute({
    _i23.Key? key,
    required int subcategoryId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         AdhkarDetailRoute.name,
         args: AdhkarDetailRouteArgs(key: key, subcategoryId: subcategoryId),
         initialChildren: children,
       );

  static const String name = 'AdhkarDetailRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

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
class AdhkarsListRoute extends _i22.PageRouteInfo<void> {
  const AdhkarsListRoute({List<_i22.PageRouteInfo>? children})
    : super(AdhkarsListRoute.name, initialChildren: children);

  static const String name = 'AdhkarsListRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdhkarsListPage();
    },
  );
}

/// generated route for
/// [_i3.AyahReaderPage]
class AyahReaderRoute extends _i22.PageRouteInfo<AyahReaderRouteArgs> {
  AyahReaderRoute({
    _i23.Key? key,
    required int surahNumber,
    int initialAyah = 1,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

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
/// [_i4.DashboardPage]
class DashboardRoute extends _i22.PageRouteInfo<void> {
  const DashboardRoute({List<_i22.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i4.DashboardPage();
    },
  );
}

/// generated route for
/// [_i5.DashboardRouterPage]
class DashboardRouterRoute extends _i22.PageRouteInfo<void> {
  const DashboardRouterRoute({List<_i22.PageRouteInfo>? children})
    : super(DashboardRouterRoute.name, initialChildren: children);

  static const String name = 'DashboardRouterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i5.DashboardRouterPage();
    },
  );
}

/// generated route for
/// [_i6.DhikrPage]
class DhikrRoute extends _i22.PageRouteInfo<DhikrRouteArgs> {
  DhikrRoute({
    _i23.Key? key,
    int selectedId = 0,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         DhikrRoute.name,
         args: DhikrRouteArgs(key: key, selectedId: selectedId),
         initialChildren: children,
       );

  static const String name = 'DhikrRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DhikrRouteArgs>(
        orElse: () => const DhikrRouteArgs(),
      );
      return _i6.DhikrPage(key: args.key, selectedId: args.selectedId);
    },
  );
}

class DhikrRouteArgs {
  const DhikrRouteArgs({this.key, this.selectedId = 0});

  final _i23.Key? key;

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
/// [_i7.DhikrsListPage]
class DhikrsListRoute extends _i22.PageRouteInfo<void> {
  const DhikrsListRoute({List<_i22.PageRouteInfo>? children})
    : super(DhikrsListRoute.name, initialChildren: children);

  static const String name = 'DhikrsListRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i7.DhikrsListPage();
    },
  );
}

/// generated route for
/// [_i8.HomePage]
class HomeRoute extends _i22.PageRouteInfo<void> {
  const HomeRoute({List<_i22.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i8.HomePage();
    },
  );
}

/// generated route for
/// [_i9.HomeRouterPage]
class HomeRouterRoute extends _i22.PageRouteInfo<void> {
  const HomeRouterRoute({List<_i22.PageRouteInfo>? children})
    : super(HomeRouterRoute.name, initialChildren: children);

  static const String name = 'HomeRouterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i9.HomeRouterPage();
    },
  );
}

/// generated route for
/// [_i10.ImpactPage]
class ImpactRoute extends _i22.PageRouteInfo<void> {
  const ImpactRoute({List<_i22.PageRouteInfo>? children})
    : super(ImpactRoute.name, initialChildren: children);

  static const String name = 'ImpactRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.ImpactPage();
    },
  );
}

/// generated route for
/// [_i11.ImpactRouterPage]
class ImpactRouterRoute extends _i22.PageRouteInfo<void> {
  const ImpactRouterRoute({List<_i22.PageRouteInfo>? children})
    : super(ImpactRouterRoute.name, initialChildren: children);

  static const String name = 'ImpactRouterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.ImpactRouterPage();
    },
  );
}

/// generated route for
/// [_i12.OnboardingPage]
class OnboardingRoute extends _i22.PageRouteInfo<void> {
  const OnboardingRoute({List<_i22.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i12.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i13.RootPage]
class RootRoute extends _i22.PageRouteInfo<void> {
  const RootRoute({List<_i22.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i13.RootPage();
    },
  );
}

/// generated route for
/// [_i14.SettingsPage]
class SettingsRoute extends _i22.PageRouteInfo<void> {
  const SettingsRoute({List<_i22.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i14.SettingsPage();
    },
  );
}

/// generated route for
/// [_i15.SignInPage]
class SignInRoute extends _i22.PageRouteInfo<void> {
  const SignInRoute({List<_i22.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i15.SignInPage();
    },
  );
}

/// generated route for
/// [_i16.SignUpPage]
class SignUpRoute extends _i22.PageRouteInfo<void> {
  const SignUpRoute({List<_i22.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i16.SignUpPage();
    },
  );
}

/// generated route for
/// [_i17.SourcePage]
class SourceRoute extends _i22.PageRouteInfo<void> {
  const SourceRoute({List<_i22.PageRouteInfo>? children})
    : super(SourceRoute.name, initialChildren: children);

  static const String name = 'SourceRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i17.SourcePage();
    },
  );
}

/// generated route for
/// [_i18.SourceRouterPage]
class SourceRouterRoute extends _i22.PageRouteInfo<void> {
  const SourceRouterRoute({List<_i22.PageRouteInfo>? children})
    : super(SourceRouterRoute.name, initialChildren: children);

  static const String name = 'SourceRouterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i18.SourceRouterPage();
    },
  );
}

/// generated route for
/// [_i19.SurahDetailPage]
class SurahDetailRoute extends _i22.PageRouteInfo<SurahDetailRouteArgs> {
  SurahDetailRoute({
    _i23.Key? key,
    required int surahNumber,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         SurahDetailRoute.name,
         args: SurahDetailRouteArgs(key: key, surahNumber: surahNumber),
         initialChildren: children,
       );

  static const String name = 'SurahDetailRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SurahDetailRouteArgs>();
      return _i19.SurahDetailPage(key: args.key, surahNumber: args.surahNumber);
    },
  );
}

class SurahDetailRouteArgs {
  const SurahDetailRouteArgs({this.key, required this.surahNumber});

  final _i23.Key? key;

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
/// [_i20.ToolsPage]
class ToolsRoute extends _i22.PageRouteInfo<void> {
  const ToolsRoute({List<_i22.PageRouteInfo>? children})
    : super(ToolsRoute.name, initialChildren: children);

  static const String name = 'ToolsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.ToolsPage();
    },
  );
}

/// generated route for
/// [_i21.ToolsRouterPage]
class ToolsRouterRoute extends _i22.PageRouteInfo<void> {
  const ToolsRouterRoute({List<_i22.PageRouteInfo>? children})
    : super(ToolsRouterRoute.name, initialChildren: children);

  static const String name = 'ToolsRouterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i21.ToolsRouterPage();
    },
  );
}
