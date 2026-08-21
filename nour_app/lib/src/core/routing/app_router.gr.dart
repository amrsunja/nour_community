// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i48;
import 'package:flutter/material.dart' as _i49;
import 'package:nour/src/features/adhkar/ui/pages/adhkar_detail_page.dart'
    as _i2;
import 'package:nour/src/features/adhkar/ui/pages/adhkars_list_page.dart'
    as _i3;
import 'package:nour/src/features/admin/ui/pages/admin_dashboard_page.dart'
    as _i4;
import 'package:nour/src/features/auth/ui/pages/sign_in_page.dart' as _i39;
import 'package:nour/src/features/auth/ui/pages/sign_up_page.dart' as _i40;
import 'package:nour/src/features/dashboard/ui/pages/dashboard_page.dart'
    as _i10;
import 'package:nour/src/features/dhikr/ui/pages/dhikr_page.dart' as _i12;
import 'package:nour/src/features/dhikr/ui/pages/dhikrs_list_page.dart' as _i13;
import 'package:nour/src/features/dua/ui/pages/daily_dua_page.dart' as _i9;
import 'package:nour/src/features/dua/ui/pages/dua_detail_page.dart' as _i15;
import 'package:nour/src/features/dua/ui/pages/dua_list_page.dart' as _i16;
import 'package:nour/src/features/hadith/ui/pages/hadith_collection_detail_page.dart'
    as _i19;
import 'package:nour/src/features/hadith/ui/pages/hadith_detail_page.dart'
    as _i20;
import 'package:nour/src/features/home/dashboard_router_route.dart' as _i11;
import 'package:nour/src/features/home/home_page.dart' as _i21;
import 'package:nour/src/features/home/home_router_page.dart' as _i22;
import 'package:nour/src/features/home/impact_router_route.dart' as _i25;
import 'package:nour/src/features/home/source_router_page.dart' as _i42;
import 'package:nour/src/features/home/tools_router_route.dart' as _i45;
import 'package:nour/src/features/impact/ui/pages/impact_page.dart' as _i23;
import 'package:nour/src/features/impact/ui/pages/impact_project_detail_page.dart'
    as _i24;
import 'package:nour/src/features/onboarding/ui/pages/onboarding_page.dart'
    as _i28;
import 'package:nour/src/features/payments/ui/pages/checkout_page.dart' as _i7;
import 'package:nour/src/features/payments/ui/pages/donation_reward_page.dart'
    as _i14;
import 'package:nour/src/features/payments/ui/pages/my_donations_page.dart'
    as _i27;
import 'package:nour/src/features/profile/ui/pages/account_information_page.dart'
    as _i1;
import 'package:nour/src/features/profile/ui/pages/favorites_page.dart' as _i18;
import 'package:nour/src/features/profile/ui/pages/profile_page.dart' as _i30;
import 'package:nour/src/features/profile/ui/pages/profile_statistics_page.dart'
    as _i31;
import 'package:nour/src/features/profile/ui/pages/reward_daily_dhikr_page.dart'
    as _i35;
import 'package:nour/src/features/profile/ui/pages/reward_streak_page.dart'
    as _i36;
import 'package:nour/src/features/quiz/ui/pages/quiz_page.dart' as _i33;
import 'package:nour/src/features/quran/ui/pages/ayah_reader_page.dart' as _i5;
import 'package:nour/src/features/quran/ui/pages/daily_ayah_page.dart' as _i8;
import 'package:nour/src/features/quran/ui/pages/surah_detail_page.dart'
    as _i43;
import 'package:nour/src/features/root_page.dart' as _i37;
import 'package:nour/src/features/settings/ui/pages/favorite_reciter_page.dart'
    as _i17;
import 'package:nour/src/features/settings/ui/pages/language_page.dart' as _i26;
import 'package:nour/src/features/settings/ui/pages/reminders_page.dart'
    as _i34;
import 'package:nour/src/features/settings/ui/pages/settings_page.dart' as _i38;
import 'package:nour/src/features/source/ui/pages/source_page.dart' as _i41;
import 'package:nour/src/features/tools/ui/pages/calendar_page.dart' as _i6;
import 'package:nour/src/features/tools/ui/pages/prayer_times_page.dart'
    as _i29;
import 'package:nour/src/features/tools/ui/pages/qibla_finder_page.dart'
    as _i32;
import 'package:nour/src/features/tools/ui/pages/tools_page.dart' as _i44;
import 'package:nour/src/features/tools/ui/pages/zakat_calculator_page.dart'
    as _i47;
import 'package:nour/src/features/webview/ui/pages/web_view_page.dart' as _i46;

/// generated route for
/// [_i1.AccountInformationPage]
class AccountInformationRoute extends _i48.PageRouteInfo<void> {
  const AccountInformationRoute({List<_i48.PageRouteInfo>? children})
    : super(AccountInformationRoute.name, initialChildren: children);

  static const String name = 'AccountInformationRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountInformationPage();
    },
  );
}

/// generated route for
/// [_i2.AdhkarDetailPage]
class AdhkarDetailRoute extends _i48.PageRouteInfo<AdhkarDetailRouteArgs> {
  AdhkarDetailRoute({
    _i49.Key? key,
    required int subcategoryId,
    int? initialAdhkarId,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         AdhkarDetailRoute.name,
         args: AdhkarDetailRouteArgs(
           key: key,
           subcategoryId: subcategoryId,
           initialAdhkarId: initialAdhkarId,
         ),
         rawPathParams: {'id': subcategoryId},
         rawQueryParams: {'adhkarId': initialAdhkarId},
         initialChildren: children,
       );

  static const String name = 'AdhkarDetailRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<AdhkarDetailRouteArgs>(
        orElse: () => AdhkarDetailRouteArgs(
          subcategoryId: pathParams.getInt('id'),
          initialAdhkarId: queryParams.optInt('adhkarId'),
        ),
      );
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

  final _i49.Key? key;

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
class AdhkarsListRoute extends _i48.PageRouteInfo<void> {
  const AdhkarsListRoute({List<_i48.PageRouteInfo>? children})
    : super(AdhkarsListRoute.name, initialChildren: children);

  static const String name = 'AdhkarsListRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdhkarsListPage();
    },
  );
}

/// generated route for
/// [_i4.AdminDashboardPage]
class AdminDashboardRoute extends _i48.PageRouteInfo<void> {
  const AdminDashboardRoute({List<_i48.PageRouteInfo>? children})
    : super(AdminDashboardRoute.name, initialChildren: children);

  static const String name = 'AdminDashboardRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i4.AdminDashboardPage();
    },
  );
}

/// generated route for
/// [_i5.AyahReaderPage]
class AyahReaderRoute extends _i48.PageRouteInfo<AyahReaderRouteArgs> {
  AyahReaderRoute({
    _i49.Key? key,
    required int surahNumber,
    int initialAyah = 1,
    bool recordProgress = true,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         AyahReaderRoute.name,
         args: AyahReaderRouteArgs(
           key: key,
           surahNumber: surahNumber,
           initialAyah: initialAyah,
           recordProgress: recordProgress,
         ),
         rawPathParams: {'surahId': surahNumber, 'ayahId': initialAyah},
         rawQueryParams: {'recordProgress': recordProgress},
         initialChildren: children,
       );

  static const String name = 'AyahReaderRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<AyahReaderRouteArgs>(
        orElse: () => AyahReaderRouteArgs(
          surahNumber: pathParams.getInt('surahId'),
          initialAyah: pathParams.getInt('ayahId', 1),
          recordProgress: queryParams.getBool('recordProgress', true),
        ),
      );
      return _i5.AyahReaderPage(
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

  final _i49.Key? key;

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
/// [_i6.CalendarPage]
class CalendarRoute extends _i48.PageRouteInfo<void> {
  const CalendarRoute({List<_i48.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i6.CalendarPage();
    },
  );
}

/// generated route for
/// [_i7.CheckoutPage]
class CheckoutRoute extends _i48.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i49.Key? key,
    required int projectId,
    double amount = 10,
    String frequency = 'oneTime',
    bool isZakat = false,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         CheckoutRoute.name,
         args: CheckoutRouteArgs(
           key: key,
           projectId: projectId,
           amount: amount,
           frequency: frequency,
           isZakat: isZakat,
         ),
         rawPathParams: {'projectId': projectId},
         rawQueryParams: {
           'amount': amount,
           'frequency': frequency,
           'zakat': isZakat,
         },
         initialChildren: children,
       );

  static const String name = 'CheckoutRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<CheckoutRouteArgs>(
        orElse: () => CheckoutRouteArgs(
          projectId: pathParams.getInt('projectId'),
          amount: queryParams.getDouble('amount', 10),
          frequency: queryParams.getString('frequency', 'oneTime'),
          isZakat: queryParams.getBool('zakat', false),
        ),
      );
      return _i7.CheckoutPage(
        key: args.key,
        projectId: args.projectId,
        amount: args.amount,
        frequency: args.frequency,
        isZakat: args.isZakat,
      );
    },
  );
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.projectId,
    this.amount = 10,
    this.frequency = 'oneTime',
    this.isZakat = false,
  });

  final _i49.Key? key;

  final int projectId;

  final double amount;

  final String frequency;

  final bool isZakat;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, projectId: $projectId, amount: $amount, frequency: $frequency, isZakat: $isZakat}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckoutRouteArgs) return false;
    return key == other.key &&
        projectId == other.projectId &&
        amount == other.amount &&
        frequency == other.frequency &&
        isZakat == other.isZakat;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      projectId.hashCode ^
      amount.hashCode ^
      frequency.hashCode ^
      isZakat.hashCode;
}

/// generated route for
/// [_i8.DailyAyahPage]
class DailyAyahRoute extends _i48.PageRouteInfo<void> {
  const DailyAyahRoute({List<_i48.PageRouteInfo>? children})
    : super(DailyAyahRoute.name, initialChildren: children);

  static const String name = 'DailyAyahRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i8.DailyAyahPage();
    },
  );
}

/// generated route for
/// [_i9.DailyDuaPage]
class DailyDuaRoute extends _i48.PageRouteInfo<void> {
  const DailyDuaRoute({List<_i48.PageRouteInfo>? children})
    : super(DailyDuaRoute.name, initialChildren: children);

  static const String name = 'DailyDuaRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i9.DailyDuaPage();
    },
  );
}

/// generated route for
/// [_i10.DashboardPage]
class DashboardRoute extends _i48.PageRouteInfo<void> {
  const DashboardRoute({List<_i48.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i10.DashboardPage();
    },
  );
}

/// generated route for
/// [_i11.DashboardRouterPage]
class DashboardRouterRoute extends _i48.PageRouteInfo<void> {
  const DashboardRouterRoute({List<_i48.PageRouteInfo>? children})
    : super(DashboardRouterRoute.name, initialChildren: children);

  static const String name = 'DashboardRouterRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i11.DashboardRouterPage();
    },
  );
}

/// generated route for
/// [_i12.DhikrPage]
class DhikrRoute extends _i48.PageRouteInfo<DhikrRouteArgs> {
  DhikrRoute({
    _i49.Key? key,
    int selectedId = 0,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         DhikrRoute.name,
         args: DhikrRouteArgs(key: key, selectedId: selectedId),
         rawQueryParams: {'id': selectedId},
         initialChildren: children,
       );

  static const String name = 'DhikrRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<DhikrRouteArgs>(
        orElse: () => DhikrRouteArgs(selectedId: queryParams.getInt('id', 0)),
      );
      return _i12.DhikrPage(key: args.key, selectedId: args.selectedId);
    },
  );
}

class DhikrRouteArgs {
  const DhikrRouteArgs({this.key, this.selectedId = 0});

  final _i49.Key? key;

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
/// [_i13.DhikrsListPage]
class DhikrsListRoute extends _i48.PageRouteInfo<void> {
  const DhikrsListRoute({List<_i48.PageRouteInfo>? children})
    : super(DhikrsListRoute.name, initialChildren: children);

  static const String name = 'DhikrsListRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i13.DhikrsListPage();
    },
  );
}

/// generated route for
/// [_i14.DonationRewardPage]
class DonationRewardRoute extends _i48.PageRouteInfo<DonationRewardRouteArgs> {
  DonationRewardRoute({
    _i49.Key? key,
    required int projectId,
    double amount = 0,
    String frequency = 'oneTime',
    List<_i48.PageRouteInfo>? children,
  }) : super(
         DonationRewardRoute.name,
         args: DonationRewardRouteArgs(
           key: key,
           projectId: projectId,
           amount: amount,
           frequency: frequency,
         ),
         rawPathParams: {'projectId': projectId},
         rawQueryParams: {'amount': amount, 'frequency': frequency},
         initialChildren: children,
       );

  static const String name = 'DonationRewardRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<DonationRewardRouteArgs>(
        orElse: () => DonationRewardRouteArgs(
          projectId: pathParams.getInt('projectId'),
          amount: queryParams.getDouble('amount', 0),
          frequency: queryParams.getString('frequency', 'oneTime'),
        ),
      );
      return _i14.DonationRewardPage(
        key: args.key,
        projectId: args.projectId,
        amount: args.amount,
        frequency: args.frequency,
      );
    },
  );
}

class DonationRewardRouteArgs {
  const DonationRewardRouteArgs({
    this.key,
    required this.projectId,
    this.amount = 0,
    this.frequency = 'oneTime',
  });

  final _i49.Key? key;

  final int projectId;

  final double amount;

  final String frequency;

  @override
  String toString() {
    return 'DonationRewardRouteArgs{key: $key, projectId: $projectId, amount: $amount, frequency: $frequency}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DonationRewardRouteArgs) return false;
    return key == other.key &&
        projectId == other.projectId &&
        amount == other.amount &&
        frequency == other.frequency;
  }

  @override
  int get hashCode =>
      key.hashCode ^ projectId.hashCode ^ amount.hashCode ^ frequency.hashCode;
}

/// generated route for
/// [_i15.DuaDetailPage]
class DuaDetailRoute extends _i48.PageRouteInfo<DuaDetailRouteArgs> {
  DuaDetailRoute({
    _i49.Key? key,
    required int initialDuaId,
    bool recordProgress = true,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         DuaDetailRoute.name,
         args: DuaDetailRouteArgs(
           key: key,
           initialDuaId: initialDuaId,
           recordProgress: recordProgress,
         ),
         rawPathParams: {'id': initialDuaId},
         rawQueryParams: {'recordProgress': recordProgress},
         initialChildren: children,
       );

  static const String name = 'DuaDetailRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<DuaDetailRouteArgs>(
        orElse: () => DuaDetailRouteArgs(
          initialDuaId: pathParams.getInt('id'),
          recordProgress: queryParams.getBool('recordProgress', true),
        ),
      );
      return _i15.DuaDetailPage(
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

  final _i49.Key? key;

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
/// [_i16.DuaListPage]
class DuaListRoute extends _i48.PageRouteInfo<void> {
  const DuaListRoute({List<_i48.PageRouteInfo>? children})
    : super(DuaListRoute.name, initialChildren: children);

  static const String name = 'DuaListRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i16.DuaListPage();
    },
  );
}

/// generated route for
/// [_i17.FavoriteReciterPage]
class FavoriteReciterRoute extends _i48.PageRouteInfo<void> {
  const FavoriteReciterRoute({List<_i48.PageRouteInfo>? children})
    : super(FavoriteReciterRoute.name, initialChildren: children);

  static const String name = 'FavoriteReciterRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i17.FavoriteReciterPage();
    },
  );
}

/// generated route for
/// [_i18.FavoritesPage]
class FavoritesRoute extends _i48.PageRouteInfo<void> {
  const FavoritesRoute({List<_i48.PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i18.FavoritesPage();
    },
  );
}

/// generated route for
/// [_i19.HadithCollectionDetailPage]
class HadithCollectionDetailRoute
    extends _i48.PageRouteInfo<HadithCollectionDetailRouteArgs> {
  HadithCollectionDetailRoute({
    _i49.Key? key,
    required int collectionId,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         HadithCollectionDetailRoute.name,
         args: HadithCollectionDetailRouteArgs(
           key: key,
           collectionId: collectionId,
         ),
         rawPathParams: {'id': collectionId},
         initialChildren: children,
       );

  static const String name = 'HadithCollectionDetailRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<HadithCollectionDetailRouteArgs>(
        orElse: () => HadithCollectionDetailRouteArgs(
          collectionId: pathParams.getInt('id'),
        ),
      );
      return _i19.HadithCollectionDetailPage(
        key: args.key,
        collectionId: args.collectionId,
      );
    },
  );
}

class HadithCollectionDetailRouteArgs {
  const HadithCollectionDetailRouteArgs({this.key, required this.collectionId});

  final _i49.Key? key;

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
/// [_i20.HadithDetailPage]
class HadithDetailRoute extends _i48.PageRouteInfo<HadithDetailRouteArgs> {
  HadithDetailRoute({
    _i49.Key? key,
    required int collectionId,
    required int initialHadithId,
    bool recordProgress = true,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         HadithDetailRoute.name,
         args: HadithDetailRouteArgs(
           key: key,
           collectionId: collectionId,
           initialHadithId: initialHadithId,
           recordProgress: recordProgress,
         ),
         rawPathParams: {
           'collectionId': collectionId,
           'hadithId': initialHadithId,
         },
         rawQueryParams: {'recordProgress': recordProgress},
         initialChildren: children,
       );

  static const String name = 'HadithDetailRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<HadithDetailRouteArgs>(
        orElse: () => HadithDetailRouteArgs(
          collectionId: pathParams.getInt('collectionId'),
          initialHadithId: pathParams.getInt('hadithId'),
          recordProgress: queryParams.getBool('recordProgress', true),
        ),
      );
      return _i20.HadithDetailPage(
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

  final _i49.Key? key;

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
/// [_i21.HomePage]
class HomeRoute extends _i48.PageRouteInfo<void> {
  const HomeRoute({List<_i48.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i21.HomePage();
    },
  );
}

/// generated route for
/// [_i22.HomeRouterPage]
class HomeRouterRoute extends _i48.PageRouteInfo<void> {
  const HomeRouterRoute({List<_i48.PageRouteInfo>? children})
    : super(HomeRouterRoute.name, initialChildren: children);

  static const String name = 'HomeRouterRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i22.HomeRouterPage();
    },
  );
}

/// generated route for
/// [_i23.ImpactPage]
class ImpactRoute extends _i48.PageRouteInfo<void> {
  const ImpactRoute({List<_i48.PageRouteInfo>? children})
    : super(ImpactRoute.name, initialChildren: children);

  static const String name = 'ImpactRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i23.ImpactPage();
    },
  );
}

/// generated route for
/// [_i24.ImpactProjectDetailPage]
class ImpactProjectDetailRoute
    extends _i48.PageRouteInfo<ImpactProjectDetailRouteArgs> {
  ImpactProjectDetailRoute({
    _i49.Key? key,
    required int projectId,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         ImpactProjectDetailRoute.name,
         args: ImpactProjectDetailRouteArgs(key: key, projectId: projectId),
         rawPathParams: {'id': projectId},
         initialChildren: children,
       );

  static const String name = 'ImpactProjectDetailRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ImpactProjectDetailRouteArgs>(
        orElse: () =>
            ImpactProjectDetailRouteArgs(projectId: pathParams.getInt('id')),
      );
      return _i24.ImpactProjectDetailPage(
        key: args.key,
        projectId: args.projectId,
      );
    },
  );
}

class ImpactProjectDetailRouteArgs {
  const ImpactProjectDetailRouteArgs({this.key, required this.projectId});

  final _i49.Key? key;

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
/// [_i25.ImpactRouterPage]
class ImpactRouterRoute extends _i48.PageRouteInfo<void> {
  const ImpactRouterRoute({List<_i48.PageRouteInfo>? children})
    : super(ImpactRouterRoute.name, initialChildren: children);

  static const String name = 'ImpactRouterRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i25.ImpactRouterPage();
    },
  );
}

/// generated route for
/// [_i26.LanguagePage]
class LanguageRoute extends _i48.PageRouteInfo<void> {
  const LanguageRoute({List<_i48.PageRouteInfo>? children})
    : super(LanguageRoute.name, initialChildren: children);

  static const String name = 'LanguageRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i26.LanguagePage();
    },
  );
}

/// generated route for
/// [_i27.MyDonationsPage]
class MyDonationsRoute extends _i48.PageRouteInfo<void> {
  const MyDonationsRoute({List<_i48.PageRouteInfo>? children})
    : super(MyDonationsRoute.name, initialChildren: children);

  static const String name = 'MyDonationsRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i27.MyDonationsPage();
    },
  );
}

/// generated route for
/// [_i28.OnboardingPage]
class OnboardingRoute extends _i48.PageRouteInfo<void> {
  const OnboardingRoute({List<_i48.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i28.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i29.PrayerTimesPage]
class PrayerTimesRoute extends _i48.PageRouteInfo<void> {
  const PrayerTimesRoute({List<_i48.PageRouteInfo>? children})
    : super(PrayerTimesRoute.name, initialChildren: children);

  static const String name = 'PrayerTimesRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i29.PrayerTimesPage();
    },
  );
}

/// generated route for
/// [_i30.ProfilePage]
class ProfileRoute extends _i48.PageRouteInfo<void> {
  const ProfileRoute({List<_i48.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i30.ProfilePage();
    },
  );
}

/// generated route for
/// [_i31.ProfileStatisticsPage]
class ProfileStatisticsRoute extends _i48.PageRouteInfo<void> {
  const ProfileStatisticsRoute({List<_i48.PageRouteInfo>? children})
    : super(ProfileStatisticsRoute.name, initialChildren: children);

  static const String name = 'ProfileStatisticsRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i31.ProfileStatisticsPage();
    },
  );
}

/// generated route for
/// [_i32.QiblaFinderPage]
class QiblaFinderRoute extends _i48.PageRouteInfo<void> {
  const QiblaFinderRoute({List<_i48.PageRouteInfo>? children})
    : super(QiblaFinderRoute.name, initialChildren: children);

  static const String name = 'QiblaFinderRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i32.QiblaFinderPage();
    },
  );
}

/// generated route for
/// [_i33.QuizPage]
class QuizRoute extends _i48.PageRouteInfo<void> {
  const QuizRoute({List<_i48.PageRouteInfo>? children})
    : super(QuizRoute.name, initialChildren: children);

  static const String name = 'QuizRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i33.QuizPage();
    },
  );
}

/// generated route for
/// [_i34.RemindersPage]
class RemindersRoute extends _i48.PageRouteInfo<void> {
  const RemindersRoute({List<_i48.PageRouteInfo>? children})
    : super(RemindersRoute.name, initialChildren: children);

  static const String name = 'RemindersRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i34.RemindersPage();
    },
  );
}

/// generated route for
/// [_i35.RewardDailyDhikrPage]
class RewardDailyDhikrRoute
    extends _i48.PageRouteInfo<RewardDailyDhikrRouteArgs> {
  RewardDailyDhikrRoute({
    _i49.Key? key,
    int dhikrCompleted = 0,
    int ajrEarned = 0,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         RewardDailyDhikrRoute.name,
         args: RewardDailyDhikrRouteArgs(
           key: key,
           dhikrCompleted: dhikrCompleted,
           ajrEarned: ajrEarned,
         ),
         rawQueryParams: {
           'dhikrCompleted': dhikrCompleted,
           'ajrEarned': ajrEarned,
         },
         initialChildren: children,
       );

  static const String name = 'RewardDailyDhikrRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<RewardDailyDhikrRouteArgs>(
        orElse: () => RewardDailyDhikrRouteArgs(
          dhikrCompleted: queryParams.getInt('dhikrCompleted', 0),
          ajrEarned: queryParams.getInt('ajrEarned', 0),
        ),
      );
      return _i35.RewardDailyDhikrPage(
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

  final _i49.Key? key;

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
/// [_i36.RewardStreakPage]
class RewardStreakRoute extends _i48.PageRouteInfo<RewardStreakRouteArgs> {
  RewardStreakRoute({
    _i49.Key? key,
    int streakDay = 1,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         RewardStreakRoute.name,
         args: RewardStreakRouteArgs(key: key, streakDay: streakDay),
         rawQueryParams: {'streakDay': streakDay},
         initialChildren: children,
       );

  static const String name = 'RewardStreakRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<RewardStreakRouteArgs>(
        orElse: () => RewardStreakRouteArgs(
          streakDay: queryParams.getInt('streakDay', 1),
        ),
      );
      return _i36.RewardStreakPage(key: args.key, streakDay: args.streakDay);
    },
  );
}

class RewardStreakRouteArgs {
  const RewardStreakRouteArgs({this.key, this.streakDay = 1});

  final _i49.Key? key;

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
/// [_i37.RootPage]
class RootRoute extends _i48.PageRouteInfo<void> {
  const RootRoute({List<_i48.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i37.RootPage();
    },
  );
}

/// generated route for
/// [_i38.SettingsPage]
class SettingsRoute extends _i48.PageRouteInfo<void> {
  const SettingsRoute({List<_i48.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i38.SettingsPage();
    },
  );
}

/// generated route for
/// [_i39.SignInPage]
class SignInRoute extends _i48.PageRouteInfo<void> {
  const SignInRoute({List<_i48.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i39.SignInPage();
    },
  );
}

/// generated route for
/// [_i40.SignUpPage]
class SignUpRoute extends _i48.PageRouteInfo<void> {
  const SignUpRoute({List<_i48.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i40.SignUpPage();
    },
  );
}

/// generated route for
/// [_i41.SourcePage]
class SourceRoute extends _i48.PageRouteInfo<void> {
  const SourceRoute({List<_i48.PageRouteInfo>? children})
    : super(SourceRoute.name, initialChildren: children);

  static const String name = 'SourceRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i41.SourcePage();
    },
  );
}

/// generated route for
/// [_i42.SourceRouterPage]
class SourceRouterRoute extends _i48.PageRouteInfo<void> {
  const SourceRouterRoute({List<_i48.PageRouteInfo>? children})
    : super(SourceRouterRoute.name, initialChildren: children);

  static const String name = 'SourceRouterRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i42.SourceRouterPage();
    },
  );
}

/// generated route for
/// [_i43.SurahDetailPage]
class SurahDetailRoute extends _i48.PageRouteInfo<SurahDetailRouteArgs> {
  SurahDetailRoute({
    _i49.Key? key,
    required int surahNumber,
    List<_i48.PageRouteInfo>? children,
  }) : super(
         SurahDetailRoute.name,
         args: SurahDetailRouteArgs(key: key, surahNumber: surahNumber),
         rawPathParams: {'surahId': surahNumber},
         initialChildren: children,
       );

  static const String name = 'SurahDetailRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SurahDetailRouteArgs>(
        orElse: () =>
            SurahDetailRouteArgs(surahNumber: pathParams.getInt('surahId')),
      );
      return _i43.SurahDetailPage(key: args.key, surahNumber: args.surahNumber);
    },
  );
}

class SurahDetailRouteArgs {
  const SurahDetailRouteArgs({this.key, required this.surahNumber});

  final _i49.Key? key;

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
/// [_i44.ToolsPage]
class ToolsRoute extends _i48.PageRouteInfo<void> {
  const ToolsRoute({List<_i48.PageRouteInfo>? children})
    : super(ToolsRoute.name, initialChildren: children);

  static const String name = 'ToolsRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i44.ToolsPage();
    },
  );
}

/// generated route for
/// [_i45.ToolsRouterPage]
class ToolsRouterRoute extends _i48.PageRouteInfo<void> {
  const ToolsRouterRoute({List<_i48.PageRouteInfo>? children})
    : super(ToolsRouterRoute.name, initialChildren: children);

  static const String name = 'ToolsRouterRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i45.ToolsRouterPage();
    },
  );
}

/// generated route for
/// [_i46.WebViewPage]
class WebViewRoute extends _i48.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i49.Key? key,
    String url = '',
    String title = '',
    List<_i48.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         rawQueryParams: {'url': url, 'title': title},
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<WebViewRouteArgs>(
        orElse: () => WebViewRouteArgs(
          url: queryParams.getString('url', ''),
          title: queryParams.getString('title', ''),
        ),
      );
      return _i46.WebViewPage(key: args.key, url: args.url, title: args.title);
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, this.url = '', this.title = ''});

  final _i49.Key? key;

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
/// [_i47.ZakatCalculatorPage]
class ZakatCalculatorRoute extends _i48.PageRouteInfo<void> {
  const ZakatCalculatorRoute({List<_i48.PageRouteInfo>? children})
    : super(ZakatCalculatorRoute.name, initialChildren: children);

  static const String name = 'ZakatCalculatorRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i47.ZakatCalculatorPage();
    },
  );
}
