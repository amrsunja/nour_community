// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i18;
import 'package:flutter/material.dart' as _i19;
import 'package:nour/src/features/auth/ui/pages/sign_in_page.dart' as _i12;
import 'package:nour/src/features/auth/ui/pages/sign_up_page.dart' as _i13;
import 'package:nour/src/features/dashboard/ui/pages/dashboard_page.dart'
    as _i1;
import 'package:nour/src/features/dhikr/ui/pages/dhikr_page.dart' as _i3;
import 'package:nour/src/features/dhikr/ui/pages/dhikrs_list_page.dart' as _i4;
import 'package:nour/src/features/home/dashboard_router_route.dart' as _i2;
import 'package:nour/src/features/home/home_page.dart' as _i5;
import 'package:nour/src/features/home/home_router_page.dart' as _i6;
import 'package:nour/src/features/home/impact_router_route.dart' as _i8;
import 'package:nour/src/features/home/source_router_page.dart' as _i15;
import 'package:nour/src/features/home/tools_router_route.dart' as _i17;
import 'package:nour/src/features/impact/ui/pages/impact_page.dart' as _i7;
import 'package:nour/src/features/onboarding/ui/pages/onboarding_page.dart'
    as _i9;
import 'package:nour/src/features/root_page.dart' as _i10;
import 'package:nour/src/features/settings/ui/pages/settings_page.dart' as _i11;
import 'package:nour/src/features/source/ui/pages/source_page.dart' as _i14;
import 'package:nour/src/features/tools/ui/pages/tools_page.dart' as _i16;

/// generated route for
/// [_i1.DashboardPage]
class DashboardRoute extends _i18.PageRouteInfo<void> {
  const DashboardRoute({List<_i18.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i1.DashboardPage();
    },
  );
}

/// generated route for
/// [_i2.DashboardRouterPage]
class DashboardRouterRoute extends _i18.PageRouteInfo<void> {
  const DashboardRouterRoute({List<_i18.PageRouteInfo>? children})
    : super(DashboardRouterRoute.name, initialChildren: children);

  static const String name = 'DashboardRouterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i2.DashboardRouterPage();
    },
  );
}

/// generated route for
/// [_i3.DhikrPage]
class DhikrRoute extends _i18.PageRouteInfo<DhikrRouteArgs> {
  DhikrRoute({
    _i19.Key? key,
    int selectedId = 0,
    List<_i18.PageRouteInfo>? children,
  }) : super(
         DhikrRoute.name,
         args: DhikrRouteArgs(key: key, selectedId: selectedId),
         initialChildren: children,
       );

  static const String name = 'DhikrRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DhikrRouteArgs>(
        orElse: () => const DhikrRouteArgs(),
      );
      return _i3.DhikrPage(key: args.key, selectedId: args.selectedId);
    },
  );
}

class DhikrRouteArgs {
  const DhikrRouteArgs({this.key, this.selectedId = 0});

  final _i19.Key? key;

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
/// [_i4.DhikrsListPage]
class DhikrsListRoute extends _i18.PageRouteInfo<void> {
  const DhikrsListRoute({List<_i18.PageRouteInfo>? children})
    : super(DhikrsListRoute.name, initialChildren: children);

  static const String name = 'DhikrsListRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i4.DhikrsListPage();
    },
  );
}

/// generated route for
/// [_i5.HomePage]
class HomeRoute extends _i18.PageRouteInfo<void> {
  const HomeRoute({List<_i18.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomePage();
    },
  );
}

/// generated route for
/// [_i6.HomeRouterPage]
class HomeRouterRoute extends _i18.PageRouteInfo<void> {
  const HomeRouterRoute({List<_i18.PageRouteInfo>? children})
    : super(HomeRouterRoute.name, initialChildren: children);

  static const String name = 'HomeRouterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomeRouterPage();
    },
  );
}

/// generated route for
/// [_i7.ImpactPage]
class ImpactRoute extends _i18.PageRouteInfo<void> {
  const ImpactRoute({List<_i18.PageRouteInfo>? children})
    : super(ImpactRoute.name, initialChildren: children);

  static const String name = 'ImpactRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i7.ImpactPage();
    },
  );
}

/// generated route for
/// [_i8.ImpactRouterPage]
class ImpactRouterRoute extends _i18.PageRouteInfo<void> {
  const ImpactRouterRoute({List<_i18.PageRouteInfo>? children})
    : super(ImpactRouterRoute.name, initialChildren: children);

  static const String name = 'ImpactRouterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i8.ImpactRouterPage();
    },
  );
}

/// generated route for
/// [_i9.OnboardingPage]
class OnboardingRoute extends _i18.PageRouteInfo<void> {
  const OnboardingRoute({List<_i18.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i9.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i10.RootPage]
class RootRoute extends _i18.PageRouteInfo<void> {
  const RootRoute({List<_i18.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i10.RootPage();
    },
  );
}

/// generated route for
/// [_i11.SettingsPage]
class SettingsRoute extends _i18.PageRouteInfo<void> {
  const SettingsRoute({List<_i18.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i11.SettingsPage();
    },
  );
}

/// generated route for
/// [_i12.SignInPage]
class SignInRoute extends _i18.PageRouteInfo<void> {
  const SignInRoute({List<_i18.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i12.SignInPage();
    },
  );
}

/// generated route for
/// [_i13.SignUpPage]
class SignUpRoute extends _i18.PageRouteInfo<void> {
  const SignUpRoute({List<_i18.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i13.SignUpPage();
    },
  );
}

/// generated route for
/// [_i14.SourcePage]
class SourceRoute extends _i18.PageRouteInfo<void> {
  const SourceRoute({List<_i18.PageRouteInfo>? children})
    : super(SourceRoute.name, initialChildren: children);

  static const String name = 'SourceRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i14.SourcePage();
    },
  );
}

/// generated route for
/// [_i15.SourceRouterPage]
class SourceRouterRoute extends _i18.PageRouteInfo<void> {
  const SourceRouterRoute({List<_i18.PageRouteInfo>? children})
    : super(SourceRouterRoute.name, initialChildren: children);

  static const String name = 'SourceRouterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i15.SourceRouterPage();
    },
  );
}

/// generated route for
/// [_i16.ToolsPage]
class ToolsRoute extends _i18.PageRouteInfo<void> {
  const ToolsRoute({List<_i18.PageRouteInfo>? children})
    : super(ToolsRoute.name, initialChildren: children);

  static const String name = 'ToolsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i16.ToolsPage();
    },
  );
}

/// generated route for
/// [_i17.ToolsRouterPage]
class ToolsRouterRoute extends _i18.PageRouteInfo<void> {
  const ToolsRouterRoute({List<_i18.PageRouteInfo>? children})
    : super(ToolsRouterRoute.name, initialChildren: children);

  static const String name = 'ToolsRouterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i17.ToolsRouterPage();
    },
  );
}
