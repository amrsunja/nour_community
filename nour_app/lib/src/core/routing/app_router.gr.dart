// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i75;
import 'package:flutter/material.dart' as _i76;
import 'package:nour/src/features/adhkar/ui/pages/adhkar_detail_page.dart'
    as _i2;
import 'package:nour/src/features/adhkar/ui/pages/adhkars_list_page.dart'
    as _i3;
import 'package:nour/src/features/admin/ui/pages/admin_dashboard_page.dart'
    as _i4;
import 'package:nour/src/features/auth/ui/pages/profile_type_page.dart' as _i54;
import 'package:nour/src/features/auth/ui/pages/sign_in_page.dart' as _i63;
import 'package:nour/src/features/auth/ui/pages/sign_up_page.dart' as _i64;
import 'package:nour/src/features/auth/ui/pages/welcome_page.dart' as _i71;
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
import 'package:nour/src/features/home/source_router_page.dart' as _i66;
import 'package:nour/src/features/home/tools_router_route.dart' as _i69;
import 'package:nour/src/features/impact/ui/pages/impact_page.dart' as _i23;
import 'package:nour/src/features/impact/ui/pages/impact_project_detail_page.dart'
    as _i24;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_campaign_form_page.dart'
    as _i27;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_campaign_page.dart'
    as _i28;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_community_page.dart'
    as _i29;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_create_post_page.dart'
    as _i30;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_dashboard_page.dart'
    as _i31;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_donors_page.dart'
    as _i32;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_edit_profile_page.dart'
    as _i33;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_mosque_page.dart'
    as _i34;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_notifications_page.dart'
    as _i35;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_post_form_page.dart'
    as _i36;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_receipts_page.dart'
    as _i37;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_sadaqa_settings_page.dart'
    as _i38;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_shell_page.dart'
    as _i39;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_admin_stripe_page.dart'
    as _i40;
import 'package:nour/src/features/mosque_admin/ui/pages/mosque_settings_page.dart'
    as _i48;
import 'package:nour/src/features/mosque_onboarding/ui/pages/mosque_onboarding_page.dart'
    as _i44;
import 'package:nour/src/features/mosque_onboarding/ui/pages/mosque_review_page.dart'
    as _i46;
import 'package:nour/src/features/mosques/ui/pages/mosque_become_member_page.dart'
    as _i41;
import 'package:nour/src/features/mosques/ui/pages/mosque_campaign_page.dart'
    as _i42;
import 'package:nour/src/features/mosques/ui/pages/mosque_checkout_page.dart'
    as _i43;
import 'package:nour/src/features/mosques/ui/pages/mosque_profile_page.dart'
    as _i45;
import 'package:nour/src/features/mosques/ui/pages/mosque_search_page.dart'
    as _i47;
import 'package:nour/src/features/notifications/ui/pages/push_settings_page.dart'
    as _i55;
import 'package:nour/src/features/onboarding/ui/pages/onboarding_page.dart'
    as _i50;
import 'package:nour/src/features/payments/ui/pages/checkout_page.dart' as _i7;
import 'package:nour/src/features/payments/ui/pages/donation_reward_page.dart'
    as _i14;
import 'package:nour/src/features/payments/ui/pages/my_donations_page.dart'
    as _i49;
import 'package:nour/src/features/payments/ui/pages/zakat_checkout_page.dart'
    as _i73;
import 'package:nour/src/features/payments/ui/pages/zakat_reward_page.dart'
    as _i74;
import 'package:nour/src/features/profile/ui/pages/account_information_page.dart'
    as _i1;
import 'package:nour/src/features/profile/ui/pages/favorites_page.dart' as _i18;
import 'package:nour/src/features/profile/ui/pages/profile_page.dart' as _i52;
import 'package:nour/src/features/profile/ui/pages/profile_statistics_page.dart'
    as _i53;
import 'package:nour/src/features/profile/ui/pages/reward_daily_dhikr_page.dart'
    as _i59;
import 'package:nour/src/features/profile/ui/pages/reward_streak_page.dart'
    as _i60;
import 'package:nour/src/features/quiz/ui/pages/quiz_page.dart' as _i57;
import 'package:nour/src/features/quran/ui/pages/ayah_reader_page.dart' as _i5;
import 'package:nour/src/features/quran/ui/pages/daily_ayah_page.dart' as _i8;
import 'package:nour/src/features/quran/ui/pages/surah_detail_page.dart'
    as _i67;
import 'package:nour/src/features/root_page.dart' as _i61;
import 'package:nour/src/features/settings/ui/pages/favorite_reciter_page.dart'
    as _i17;
import 'package:nour/src/features/settings/ui/pages/language_page.dart' as _i26;
import 'package:nour/src/features/settings/ui/pages/reminders_page.dart'
    as _i58;
import 'package:nour/src/features/settings/ui/pages/settings_page.dart' as _i62;
import 'package:nour/src/features/source/ui/pages/source_page.dart' as _i65;
import 'package:nour/src/features/tools/ui/pages/calendar_page.dart' as _i6;
import 'package:nour/src/features/tools/ui/pages/prayer_times_page.dart'
    as _i51;
import 'package:nour/src/features/tools/ui/pages/qibla_finder_page.dart'
    as _i56;
import 'package:nour/src/features/tools/ui/pages/tools_page.dart' as _i68;
import 'package:nour/src/features/tools/ui/pages/zakat_calculator_page.dart'
    as _i72;
import 'package:nour/src/features/webview/ui/pages/web_view_page.dart' as _i70;

/// generated route for
/// [_i1.AccountInformationPage]
class AccountInformationRoute extends _i75.PageRouteInfo<void> {
  const AccountInformationRoute({List<_i75.PageRouteInfo>? children})
    : super(AccountInformationRoute.name, initialChildren: children);

  static const String name = 'AccountInformationRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountInformationPage();
    },
  );
}

/// generated route for
/// [_i2.AdhkarDetailPage]
class AdhkarDetailRoute extends _i75.PageRouteInfo<AdhkarDetailRouteArgs> {
  AdhkarDetailRoute({
    _i76.Key? key,
    required int subcategoryId,
    int? initialAdhkarId,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class AdhkarsListRoute extends _i75.PageRouteInfo<void> {
  const AdhkarsListRoute({List<_i75.PageRouteInfo>? children})
    : super(AdhkarsListRoute.name, initialChildren: children);

  static const String name = 'AdhkarsListRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdhkarsListPage();
    },
  );
}

/// generated route for
/// [_i4.AdminDashboardPage]
class AdminDashboardRoute extends _i75.PageRouteInfo<void> {
  const AdminDashboardRoute({List<_i75.PageRouteInfo>? children})
    : super(AdminDashboardRoute.name, initialChildren: children);

  static const String name = 'AdminDashboardRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i4.AdminDashboardPage();
    },
  );
}

/// generated route for
/// [_i5.AyahReaderPage]
class AyahReaderRoute extends _i75.PageRouteInfo<AyahReaderRouteArgs> {
  AyahReaderRoute({
    _i76.Key? key,
    required int surahNumber,
    int initialAyah = 1,
    bool recordProgress = true,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class CalendarRoute extends _i75.PageRouteInfo<void> {
  const CalendarRoute({List<_i75.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i6.CalendarPage();
    },
  );
}

/// generated route for
/// [_i7.CheckoutPage]
class CheckoutRoute extends _i75.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i76.Key? key,
    required int projectId,
    double amount = 10,
    String frequency = 'oneTime',
    bool isZakat = false,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class DailyAyahRoute extends _i75.PageRouteInfo<void> {
  const DailyAyahRoute({List<_i75.PageRouteInfo>? children})
    : super(DailyAyahRoute.name, initialChildren: children);

  static const String name = 'DailyAyahRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i8.DailyAyahPage();
    },
  );
}

/// generated route for
/// [_i9.DailyDuaPage]
class DailyDuaRoute extends _i75.PageRouteInfo<void> {
  const DailyDuaRoute({List<_i75.PageRouteInfo>? children})
    : super(DailyDuaRoute.name, initialChildren: children);

  static const String name = 'DailyDuaRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i9.DailyDuaPage();
    },
  );
}

/// generated route for
/// [_i10.DashboardPage]
class DashboardRoute extends _i75.PageRouteInfo<void> {
  const DashboardRoute({List<_i75.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i10.DashboardPage();
    },
  );
}

/// generated route for
/// [_i11.DashboardRouterPage]
class DashboardRouterRoute extends _i75.PageRouteInfo<void> {
  const DashboardRouterRoute({List<_i75.PageRouteInfo>? children})
    : super(DashboardRouterRoute.name, initialChildren: children);

  static const String name = 'DashboardRouterRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i11.DashboardRouterPage();
    },
  );
}

/// generated route for
/// [_i12.DhikrPage]
class DhikrRoute extends _i75.PageRouteInfo<DhikrRouteArgs> {
  DhikrRoute({
    _i76.Key? key,
    int selectedId = 0,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         DhikrRoute.name,
         args: DhikrRouteArgs(key: key, selectedId: selectedId),
         rawQueryParams: {'id': selectedId},
         initialChildren: children,
       );

  static const String name = 'DhikrRoute';

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class DhikrsListRoute extends _i75.PageRouteInfo<void> {
  const DhikrsListRoute({List<_i75.PageRouteInfo>? children})
    : super(DhikrsListRoute.name, initialChildren: children);

  static const String name = 'DhikrsListRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i13.DhikrsListPage();
    },
  );
}

/// generated route for
/// [_i14.DonationRewardPage]
class DonationRewardRoute extends _i75.PageRouteInfo<DonationRewardRouteArgs> {
  DonationRewardRoute({
    _i76.Key? key,
    required int projectId,
    double amount = 0,
    String frequency = 'oneTime',
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class DuaDetailRoute extends _i75.PageRouteInfo<DuaDetailRouteArgs> {
  DuaDetailRoute({
    _i76.Key? key,
    required int initialDuaId,
    bool recordProgress = true,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class DuaListRoute extends _i75.PageRouteInfo<void> {
  const DuaListRoute({List<_i75.PageRouteInfo>? children})
    : super(DuaListRoute.name, initialChildren: children);

  static const String name = 'DuaListRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i16.DuaListPage();
    },
  );
}

/// generated route for
/// [_i17.FavoriteReciterPage]
class FavoriteReciterRoute extends _i75.PageRouteInfo<void> {
  const FavoriteReciterRoute({List<_i75.PageRouteInfo>? children})
    : super(FavoriteReciterRoute.name, initialChildren: children);

  static const String name = 'FavoriteReciterRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i17.FavoriteReciterPage();
    },
  );
}

/// generated route for
/// [_i18.FavoritesPage]
class FavoritesRoute extends _i75.PageRouteInfo<void> {
  const FavoritesRoute({List<_i75.PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i18.FavoritesPage();
    },
  );
}

/// generated route for
/// [_i19.HadithCollectionDetailPage]
class HadithCollectionDetailRoute
    extends _i75.PageRouteInfo<HadithCollectionDetailRouteArgs> {
  HadithCollectionDetailRoute({
    _i76.Key? key,
    required int collectionId,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class HadithDetailRoute extends _i75.PageRouteInfo<HadithDetailRouteArgs> {
  HadithDetailRoute({
    _i76.Key? key,
    required int collectionId,
    required int initialHadithId,
    bool recordProgress = true,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class HomeRoute extends _i75.PageRouteInfo<void> {
  const HomeRoute({List<_i75.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i21.HomePage();
    },
  );
}

/// generated route for
/// [_i22.HomeRouterPage]
class HomeRouterRoute extends _i75.PageRouteInfo<void> {
  const HomeRouterRoute({List<_i75.PageRouteInfo>? children})
    : super(HomeRouterRoute.name, initialChildren: children);

  static const String name = 'HomeRouterRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i22.HomeRouterPage();
    },
  );
}

/// generated route for
/// [_i23.ImpactPage]
class ImpactRoute extends _i75.PageRouteInfo<void> {
  const ImpactRoute({List<_i75.PageRouteInfo>? children})
    : super(ImpactRoute.name, initialChildren: children);

  static const String name = 'ImpactRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i23.ImpactPage();
    },
  );
}

/// generated route for
/// [_i24.ImpactProjectDetailPage]
class ImpactProjectDetailRoute
    extends _i75.PageRouteInfo<ImpactProjectDetailRouteArgs> {
  ImpactProjectDetailRoute({
    _i76.Key? key,
    required int projectId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         ImpactProjectDetailRoute.name,
         args: ImpactProjectDetailRouteArgs(key: key, projectId: projectId),
         rawPathParams: {'id': projectId},
         initialChildren: children,
       );

  static const String name = 'ImpactProjectDetailRoute';

  static _i75.PageInfo page = _i75.PageInfo(
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

  final _i76.Key? key;

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
class ImpactRouterRoute extends _i75.PageRouteInfo<void> {
  const ImpactRouterRoute({List<_i75.PageRouteInfo>? children})
    : super(ImpactRouterRoute.name, initialChildren: children);

  static const String name = 'ImpactRouterRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i25.ImpactRouterPage();
    },
  );
}

/// generated route for
/// [_i26.LanguagePage]
class LanguageRoute extends _i75.PageRouteInfo<void> {
  const LanguageRoute({List<_i75.PageRouteInfo>? children})
    : super(LanguageRoute.name, initialChildren: children);

  static const String name = 'LanguageRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i26.LanguagePage();
    },
  );
}

/// generated route for
/// [_i27.MosqueAdminCampaignFormPage]
class MosqueAdminCampaignFormRoute
    extends _i75.PageRouteInfo<MosqueAdminCampaignFormRouteArgs> {
  MosqueAdminCampaignFormRoute({
    _i76.Key? key,
    int? campaignId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueAdminCampaignFormRoute.name,
         args: MosqueAdminCampaignFormRouteArgs(
           key: key,
           campaignId: campaignId,
         ),
         rawQueryParams: {'campaignId': campaignId},
         initialChildren: children,
       );

  static const String name = 'MosqueAdminCampaignFormRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<MosqueAdminCampaignFormRouteArgs>(
        orElse: () => MosqueAdminCampaignFormRouteArgs(
          campaignId: queryParams.optInt('campaignId'),
        ),
      );
      return _i27.MosqueAdminCampaignFormPage(
        key: args.key,
        campaignId: args.campaignId,
      );
    },
  );
}

class MosqueAdminCampaignFormRouteArgs {
  const MosqueAdminCampaignFormRouteArgs({this.key, this.campaignId});

  final _i76.Key? key;

  final int? campaignId;

  @override
  String toString() {
    return 'MosqueAdminCampaignFormRouteArgs{key: $key, campaignId: $campaignId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueAdminCampaignFormRouteArgs) return false;
    return key == other.key && campaignId == other.campaignId;
  }

  @override
  int get hashCode => key.hashCode ^ campaignId.hashCode;
}

/// generated route for
/// [_i28.MosqueAdminCampaignPage]
class MosqueAdminCampaignRoute
    extends _i75.PageRouteInfo<MosqueAdminCampaignRouteArgs> {
  MosqueAdminCampaignRoute({
    _i76.Key? key,
    required int campaignId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueAdminCampaignRoute.name,
         args: MosqueAdminCampaignRouteArgs(key: key, campaignId: campaignId),
         rawPathParams: {'campaignId': campaignId},
         initialChildren: children,
       );

  static const String name = 'MosqueAdminCampaignRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MosqueAdminCampaignRouteArgs>(
        orElse: () => MosqueAdminCampaignRouteArgs(
          campaignId: pathParams.getInt('campaignId'),
        ),
      );
      return _i28.MosqueAdminCampaignPage(
        key: args.key,
        campaignId: args.campaignId,
      );
    },
  );
}

class MosqueAdminCampaignRouteArgs {
  const MosqueAdminCampaignRouteArgs({this.key, required this.campaignId});

  final _i76.Key? key;

  final int campaignId;

  @override
  String toString() {
    return 'MosqueAdminCampaignRouteArgs{key: $key, campaignId: $campaignId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueAdminCampaignRouteArgs) return false;
    return key == other.key && campaignId == other.campaignId;
  }

  @override
  int get hashCode => key.hashCode ^ campaignId.hashCode;
}

/// generated route for
/// [_i29.MosqueAdminCommunityPage]
class MosqueAdminCommunityRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminCommunityRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminCommunityRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminCommunityRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i29.MosqueAdminCommunityPage();
    },
  );
}

/// generated route for
/// [_i30.MosqueAdminCreatePostPage]
class MosqueAdminCreatePostRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminCreatePostRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminCreatePostRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminCreatePostRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i30.MosqueAdminCreatePostPage();
    },
  );
}

/// generated route for
/// [_i31.MosqueAdminDashboardPage]
class MosqueAdminDashboardRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminDashboardRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminDashboardRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminDashboardRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i31.MosqueAdminDashboardPage();
    },
  );
}

/// generated route for
/// [_i32.MosqueAdminDonorsPage]
class MosqueAdminDonorsRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminDonorsRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminDonorsRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminDonorsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i32.MosqueAdminDonorsPage();
    },
  );
}

/// generated route for
/// [_i33.MosqueAdminEditProfilePage]
class MosqueAdminEditProfileRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminEditProfileRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminEditProfileRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminEditProfileRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i33.MosqueAdminEditProfilePage();
    },
  );
}

/// generated route for
/// [_i34.MosqueAdminMosquePage]
class MosqueAdminMosqueRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminMosqueRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminMosqueRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminMosqueRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i34.MosqueAdminMosquePage();
    },
  );
}

/// generated route for
/// [_i35.MosqueAdminNotificationsPage]
class MosqueAdminNotificationsRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminNotificationsRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminNotificationsRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminNotificationsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i35.MosqueAdminNotificationsPage();
    },
  );
}

/// generated route for
/// [_i36.MosqueAdminPostFormPage]
class MosqueAdminPostFormRoute
    extends _i75.PageRouteInfo<MosqueAdminPostFormRouteArgs> {
  MosqueAdminPostFormRoute({
    _i76.Key? key,
    required String type,
    int? postId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueAdminPostFormRoute.name,
         args: MosqueAdminPostFormRouteArgs(
           key: key,
           type: type,
           postId: postId,
         ),
         rawPathParams: {'type': type},
         initialChildren: children,
       );

  static const String name = 'MosqueAdminPostFormRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MosqueAdminPostFormRouteArgs>(
        orElse: () =>
            MosqueAdminPostFormRouteArgs(type: pathParams.getString('type')),
      );
      return _i36.MosqueAdminPostFormPage(
        key: args.key,
        type: args.type,
        postId: args.postId,
      );
    },
  );
}

class MosqueAdminPostFormRouteArgs {
  const MosqueAdminPostFormRouteArgs({
    this.key,
    required this.type,
    this.postId,
  });

  final _i76.Key? key;

  final String type;

  final int? postId;

  @override
  String toString() {
    return 'MosqueAdminPostFormRouteArgs{key: $key, type: $type, postId: $postId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueAdminPostFormRouteArgs) return false;
    return key == other.key && type == other.type && postId == other.postId;
  }

  @override
  int get hashCode => key.hashCode ^ type.hashCode ^ postId.hashCode;
}

/// generated route for
/// [_i37.MosqueAdminReceiptsPage]
class MosqueAdminReceiptsRoute
    extends _i75.PageRouteInfo<MosqueAdminReceiptsRouteArgs> {
  MosqueAdminReceiptsRoute({
    _i76.Key? key,
    bool mine = false,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueAdminReceiptsRoute.name,
         args: MosqueAdminReceiptsRouteArgs(key: key, mine: mine),
         rawQueryParams: {'mine': mine},
         initialChildren: children,
       );

  static const String name = 'MosqueAdminReceiptsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<MosqueAdminReceiptsRouteArgs>(
        orElse: () => MosqueAdminReceiptsRouteArgs(
          mine: queryParams.getBool('mine', false),
        ),
      );
      return _i37.MosqueAdminReceiptsPage(key: args.key, mine: args.mine);
    },
  );
}

class MosqueAdminReceiptsRouteArgs {
  const MosqueAdminReceiptsRouteArgs({this.key, this.mine = false});

  final _i76.Key? key;

  final bool mine;

  @override
  String toString() {
    return 'MosqueAdminReceiptsRouteArgs{key: $key, mine: $mine}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueAdminReceiptsRouteArgs) return false;
    return key == other.key && mine == other.mine;
  }

  @override
  int get hashCode => key.hashCode ^ mine.hashCode;
}

/// generated route for
/// [_i38.MosqueAdminSadaqaSettingsPage]
class MosqueAdminSadaqaSettingsRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminSadaqaSettingsRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminSadaqaSettingsRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminSadaqaSettingsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i38.MosqueAdminSadaqaSettingsPage();
    },
  );
}

/// generated route for
/// [_i39.MosqueAdminShellPage]
class MosqueAdminShellRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminShellRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminShellRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminShellRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i39.MosqueAdminShellPage();
    },
  );
}

/// generated route for
/// [_i40.MosqueAdminStripePage]
class MosqueAdminStripeRoute extends _i75.PageRouteInfo<void> {
  const MosqueAdminStripeRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueAdminStripeRoute.name, initialChildren: children);

  static const String name = 'MosqueAdminStripeRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i40.MosqueAdminStripePage();
    },
  );
}

/// generated route for
/// [_i41.MosqueBecomeMemberPage]
class MosqueBecomeMemberRoute
    extends _i75.PageRouteInfo<MosqueBecomeMemberRouteArgs> {
  MosqueBecomeMemberRoute({
    _i76.Key? key,
    required int mosqueId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueBecomeMemberRoute.name,
         args: MosqueBecomeMemberRouteArgs(key: key, mosqueId: mosqueId),
         rawPathParams: {'id': mosqueId},
         initialChildren: children,
       );

  static const String name = 'MosqueBecomeMemberRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MosqueBecomeMemberRouteArgs>(
        orElse: () =>
            MosqueBecomeMemberRouteArgs(mosqueId: pathParams.getInt('id')),
      );
      return _i41.MosqueBecomeMemberPage(
        key: args.key,
        mosqueId: args.mosqueId,
      );
    },
  );
}

class MosqueBecomeMemberRouteArgs {
  const MosqueBecomeMemberRouteArgs({this.key, required this.mosqueId});

  final _i76.Key? key;

  final int mosqueId;

  @override
  String toString() {
    return 'MosqueBecomeMemberRouteArgs{key: $key, mosqueId: $mosqueId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueBecomeMemberRouteArgs) return false;
    return key == other.key && mosqueId == other.mosqueId;
  }

  @override
  int get hashCode => key.hashCode ^ mosqueId.hashCode;
}

/// generated route for
/// [_i42.MosqueCampaignPage]
class MosqueCampaignRoute extends _i75.PageRouteInfo<MosqueCampaignRouteArgs> {
  MosqueCampaignRoute({
    _i76.Key? key,
    required int mosqueId,
    required int campaignId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueCampaignRoute.name,
         args: MosqueCampaignRouteArgs(
           key: key,
           mosqueId: mosqueId,
           campaignId: campaignId,
         ),
         rawPathParams: {'id': mosqueId, 'campaignId': campaignId},
         initialChildren: children,
       );

  static const String name = 'MosqueCampaignRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MosqueCampaignRouteArgs>(
        orElse: () => MosqueCampaignRouteArgs(
          mosqueId: pathParams.getInt('id'),
          campaignId: pathParams.getInt('campaignId'),
        ),
      );
      return _i42.MosqueCampaignPage(
        key: args.key,
        mosqueId: args.mosqueId,
        campaignId: args.campaignId,
      );
    },
  );
}

class MosqueCampaignRouteArgs {
  const MosqueCampaignRouteArgs({
    this.key,
    required this.mosqueId,
    required this.campaignId,
  });

  final _i76.Key? key;

  final int mosqueId;

  final int campaignId;

  @override
  String toString() {
    return 'MosqueCampaignRouteArgs{key: $key, mosqueId: $mosqueId, campaignId: $campaignId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueCampaignRouteArgs) return false;
    return key == other.key &&
        mosqueId == other.mosqueId &&
        campaignId == other.campaignId;
  }

  @override
  int get hashCode => key.hashCode ^ mosqueId.hashCode ^ campaignId.hashCode;
}

/// generated route for
/// [_i43.MosqueCheckoutPage]
class MosqueCheckoutRoute extends _i75.PageRouteInfo<MosqueCheckoutRouteArgs> {
  MosqueCheckoutRoute({
    _i76.Key? key,
    required int mosqueId,
    double amount = 10,
    String frequency = 'oneTime',
    int? campaignId,
    int? membershipId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueCheckoutRoute.name,
         args: MosqueCheckoutRouteArgs(
           key: key,
           mosqueId: mosqueId,
           amount: amount,
           frequency: frequency,
           campaignId: campaignId,
           membershipId: membershipId,
         ),
         rawPathParams: {'id': mosqueId},
         rawQueryParams: {
           'amount': amount,
           'frequency': frequency,
           'campaignId': campaignId,
           'membershipId': membershipId,
         },
         initialChildren: children,
       );

  static const String name = 'MosqueCheckoutRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<MosqueCheckoutRouteArgs>(
        orElse: () => MosqueCheckoutRouteArgs(
          mosqueId: pathParams.getInt('id'),
          amount: queryParams.getDouble('amount', 10),
          frequency: queryParams.getString('frequency', 'oneTime'),
          campaignId: queryParams.optInt('campaignId'),
          membershipId: queryParams.optInt('membershipId'),
        ),
      );
      return _i43.MosqueCheckoutPage(
        key: args.key,
        mosqueId: args.mosqueId,
        amount: args.amount,
        frequency: args.frequency,
        campaignId: args.campaignId,
        membershipId: args.membershipId,
      );
    },
  );
}

class MosqueCheckoutRouteArgs {
  const MosqueCheckoutRouteArgs({
    this.key,
    required this.mosqueId,
    this.amount = 10,
    this.frequency = 'oneTime',
    this.campaignId,
    this.membershipId,
  });

  final _i76.Key? key;

  final int mosqueId;

  final double amount;

  final String frequency;

  final int? campaignId;

  final int? membershipId;

  @override
  String toString() {
    return 'MosqueCheckoutRouteArgs{key: $key, mosqueId: $mosqueId, amount: $amount, frequency: $frequency, campaignId: $campaignId, membershipId: $membershipId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueCheckoutRouteArgs) return false;
    return key == other.key &&
        mosqueId == other.mosqueId &&
        amount == other.amount &&
        frequency == other.frequency &&
        campaignId == other.campaignId &&
        membershipId == other.membershipId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      mosqueId.hashCode ^
      amount.hashCode ^
      frequency.hashCode ^
      campaignId.hashCode ^
      membershipId.hashCode;
}

/// generated route for
/// [_i44.MosqueOnboardingPage]
class MosqueOnboardingRoute extends _i75.PageRouteInfo<void> {
  const MosqueOnboardingRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueOnboardingRoute.name, initialChildren: children);

  static const String name = 'MosqueOnboardingRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i44.MosqueOnboardingPage();
    },
  );
}

/// generated route for
/// [_i45.MosqueProfilePage]
class MosqueProfileRoute extends _i75.PageRouteInfo<MosqueProfileRouteArgs> {
  MosqueProfileRoute({
    _i76.Key? key,
    required int mosqueId,
    String? tab,
    int? postId,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         MosqueProfileRoute.name,
         args: MosqueProfileRouteArgs(
           key: key,
           mosqueId: mosqueId,
           tab: tab,
           postId: postId,
         ),
         rawPathParams: {'id': mosqueId},
         rawQueryParams: {'tab': tab, 'postId': postId},
         initialChildren: children,
       );

  static const String name = 'MosqueProfileRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<MosqueProfileRouteArgs>(
        orElse: () => MosqueProfileRouteArgs(
          mosqueId: pathParams.getInt('id'),
          tab: queryParams.optString('tab'),
          postId: queryParams.optInt('postId'),
        ),
      );
      return _i45.MosqueProfilePage(
        key: args.key,
        mosqueId: args.mosqueId,
        tab: args.tab,
        postId: args.postId,
      );
    },
  );
}

class MosqueProfileRouteArgs {
  const MosqueProfileRouteArgs({
    this.key,
    required this.mosqueId,
    this.tab,
    this.postId,
  });

  final _i76.Key? key;

  final int mosqueId;

  final String? tab;

  final int? postId;

  @override
  String toString() {
    return 'MosqueProfileRouteArgs{key: $key, mosqueId: $mosqueId, tab: $tab, postId: $postId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MosqueProfileRouteArgs) return false;
    return key == other.key &&
        mosqueId == other.mosqueId &&
        tab == other.tab &&
        postId == other.postId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ mosqueId.hashCode ^ tab.hashCode ^ postId.hashCode;
}

/// generated route for
/// [_i46.MosqueReviewPage]
class MosqueReviewRoute extends _i75.PageRouteInfo<void> {
  const MosqueReviewRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueReviewRoute.name, initialChildren: children);

  static const String name = 'MosqueReviewRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i46.MosqueReviewPage();
    },
  );
}

/// generated route for
/// [_i47.MosqueSearchPage]
class MosqueSearchRoute extends _i75.PageRouteInfo<void> {
  const MosqueSearchRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueSearchRoute.name, initialChildren: children);

  static const String name = 'MosqueSearchRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i47.MosqueSearchPage();
    },
  );
}

/// generated route for
/// [_i48.MosqueSettingsPage]
class MosqueSettingsRoute extends _i75.PageRouteInfo<void> {
  const MosqueSettingsRoute({List<_i75.PageRouteInfo>? children})
    : super(MosqueSettingsRoute.name, initialChildren: children);

  static const String name = 'MosqueSettingsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i48.MosqueSettingsPage();
    },
  );
}

/// generated route for
/// [_i49.MyDonationsPage]
class MyDonationsRoute extends _i75.PageRouteInfo<void> {
  const MyDonationsRoute({List<_i75.PageRouteInfo>? children})
    : super(MyDonationsRoute.name, initialChildren: children);

  static const String name = 'MyDonationsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i49.MyDonationsPage();
    },
  );
}

/// generated route for
/// [_i50.OnboardingPage]
class OnboardingRoute extends _i75.PageRouteInfo<void> {
  const OnboardingRoute({List<_i75.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i50.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i51.PrayerTimesPage]
class PrayerTimesRoute extends _i75.PageRouteInfo<void> {
  const PrayerTimesRoute({List<_i75.PageRouteInfo>? children})
    : super(PrayerTimesRoute.name, initialChildren: children);

  static const String name = 'PrayerTimesRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i51.PrayerTimesPage();
    },
  );
}

/// generated route for
/// [_i52.ProfilePage]
class ProfileRoute extends _i75.PageRouteInfo<void> {
  const ProfileRoute({List<_i75.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i52.ProfilePage();
    },
  );
}

/// generated route for
/// [_i53.ProfileStatisticsPage]
class ProfileStatisticsRoute extends _i75.PageRouteInfo<void> {
  const ProfileStatisticsRoute({List<_i75.PageRouteInfo>? children})
    : super(ProfileStatisticsRoute.name, initialChildren: children);

  static const String name = 'ProfileStatisticsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i53.ProfileStatisticsPage();
    },
  );
}

/// generated route for
/// [_i54.ProfileTypePage]
class ProfileTypeRoute extends _i75.PageRouteInfo<void> {
  const ProfileTypeRoute({List<_i75.PageRouteInfo>? children})
    : super(ProfileTypeRoute.name, initialChildren: children);

  static const String name = 'ProfileTypeRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i54.ProfileTypePage();
    },
  );
}

/// generated route for
/// [_i55.PushSettingsPage]
class PushSettingsRoute extends _i75.PageRouteInfo<void> {
  const PushSettingsRoute({List<_i75.PageRouteInfo>? children})
    : super(PushSettingsRoute.name, initialChildren: children);

  static const String name = 'PushSettingsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i55.PushSettingsPage();
    },
  );
}

/// generated route for
/// [_i56.QiblaFinderPage]
class QiblaFinderRoute extends _i75.PageRouteInfo<void> {
  const QiblaFinderRoute({List<_i75.PageRouteInfo>? children})
    : super(QiblaFinderRoute.name, initialChildren: children);

  static const String name = 'QiblaFinderRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i56.QiblaFinderPage();
    },
  );
}

/// generated route for
/// [_i57.QuizPage]
class QuizRoute extends _i75.PageRouteInfo<void> {
  const QuizRoute({List<_i75.PageRouteInfo>? children})
    : super(QuizRoute.name, initialChildren: children);

  static const String name = 'QuizRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i57.QuizPage();
    },
  );
}

/// generated route for
/// [_i58.RemindersPage]
class RemindersRoute extends _i75.PageRouteInfo<void> {
  const RemindersRoute({List<_i75.PageRouteInfo>? children})
    : super(RemindersRoute.name, initialChildren: children);

  static const String name = 'RemindersRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i58.RemindersPage();
    },
  );
}

/// generated route for
/// [_i59.RewardDailyDhikrPage]
class RewardDailyDhikrRoute
    extends _i75.PageRouteInfo<RewardDailyDhikrRouteArgs> {
  RewardDailyDhikrRoute({
    _i76.Key? key,
    int dhikrCompleted = 0,
    int ajrEarned = 0,
    List<_i75.PageRouteInfo>? children,
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

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<RewardDailyDhikrRouteArgs>(
        orElse: () => RewardDailyDhikrRouteArgs(
          dhikrCompleted: queryParams.getInt('dhikrCompleted', 0),
          ajrEarned: queryParams.getInt('ajrEarned', 0),
        ),
      );
      return _i59.RewardDailyDhikrPage(
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

  final _i76.Key? key;

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
/// [_i60.RewardStreakPage]
class RewardStreakRoute extends _i75.PageRouteInfo<RewardStreakRouteArgs> {
  RewardStreakRoute({
    _i76.Key? key,
    int streakDay = 1,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         RewardStreakRoute.name,
         args: RewardStreakRouteArgs(key: key, streakDay: streakDay),
         rawQueryParams: {'streakDay': streakDay},
         initialChildren: children,
       );

  static const String name = 'RewardStreakRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<RewardStreakRouteArgs>(
        orElse: () => RewardStreakRouteArgs(
          streakDay: queryParams.getInt('streakDay', 1),
        ),
      );
      return _i60.RewardStreakPage(key: args.key, streakDay: args.streakDay);
    },
  );
}

class RewardStreakRouteArgs {
  const RewardStreakRouteArgs({this.key, this.streakDay = 1});

  final _i76.Key? key;

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
/// [_i61.RootPage]
class RootRoute extends _i75.PageRouteInfo<void> {
  const RootRoute({List<_i75.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i61.RootPage();
    },
  );
}

/// generated route for
/// [_i62.SettingsPage]
class SettingsRoute extends _i75.PageRouteInfo<void> {
  const SettingsRoute({List<_i75.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i62.SettingsPage();
    },
  );
}

/// generated route for
/// [_i63.SignInPage]
class SignInRoute extends _i75.PageRouteInfo<void> {
  const SignInRoute({List<_i75.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i63.SignInPage();
    },
  );
}

/// generated route for
/// [_i64.SignUpPage]
class SignUpRoute extends _i75.PageRouteInfo<void> {
  const SignUpRoute({List<_i75.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i64.SignUpPage();
    },
  );
}

/// generated route for
/// [_i65.SourcePage]
class SourceRoute extends _i75.PageRouteInfo<void> {
  const SourceRoute({List<_i75.PageRouteInfo>? children})
    : super(SourceRoute.name, initialChildren: children);

  static const String name = 'SourceRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i65.SourcePage();
    },
  );
}

/// generated route for
/// [_i66.SourceRouterPage]
class SourceRouterRoute extends _i75.PageRouteInfo<void> {
  const SourceRouterRoute({List<_i75.PageRouteInfo>? children})
    : super(SourceRouterRoute.name, initialChildren: children);

  static const String name = 'SourceRouterRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i66.SourceRouterPage();
    },
  );
}

/// generated route for
/// [_i67.SurahDetailPage]
class SurahDetailRoute extends _i75.PageRouteInfo<SurahDetailRouteArgs> {
  SurahDetailRoute({
    _i76.Key? key,
    required int surahNumber,
    List<_i75.PageRouteInfo>? children,
  }) : super(
         SurahDetailRoute.name,
         args: SurahDetailRouteArgs(key: key, surahNumber: surahNumber),
         rawPathParams: {'surahId': surahNumber},
         initialChildren: children,
       );

  static const String name = 'SurahDetailRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SurahDetailRouteArgs>(
        orElse: () =>
            SurahDetailRouteArgs(surahNumber: pathParams.getInt('surahId')),
      );
      return _i67.SurahDetailPage(key: args.key, surahNumber: args.surahNumber);
    },
  );
}

class SurahDetailRouteArgs {
  const SurahDetailRouteArgs({this.key, required this.surahNumber});

  final _i76.Key? key;

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
/// [_i68.ToolsPage]
class ToolsRoute extends _i75.PageRouteInfo<void> {
  const ToolsRoute({List<_i75.PageRouteInfo>? children})
    : super(ToolsRoute.name, initialChildren: children);

  static const String name = 'ToolsRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i68.ToolsPage();
    },
  );
}

/// generated route for
/// [_i69.ToolsRouterPage]
class ToolsRouterRoute extends _i75.PageRouteInfo<void> {
  const ToolsRouterRoute({List<_i75.PageRouteInfo>? children})
    : super(ToolsRouterRoute.name, initialChildren: children);

  static const String name = 'ToolsRouterRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i69.ToolsRouterPage();
    },
  );
}

/// generated route for
/// [_i70.WebViewPage]
class WebViewRoute extends _i75.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i76.Key? key,
    String url = '',
    String title = '',
    List<_i75.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         rawQueryParams: {'url': url, 'title': title},
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<WebViewRouteArgs>(
        orElse: () => WebViewRouteArgs(
          url: queryParams.getString('url', ''),
          title: queryParams.getString('title', ''),
        ),
      );
      return _i70.WebViewPage(key: args.key, url: args.url, title: args.title);
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, this.url = '', this.title = ''});

  final _i76.Key? key;

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
/// [_i71.WelcomePage]
class WelcomeRoute extends _i75.PageRouteInfo<void> {
  const WelcomeRoute({List<_i75.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i71.WelcomePage();
    },
  );
}

/// generated route for
/// [_i72.ZakatCalculatorPage]
class ZakatCalculatorRoute extends _i75.PageRouteInfo<void> {
  const ZakatCalculatorRoute({List<_i75.PageRouteInfo>? children})
    : super(ZakatCalculatorRoute.name, initialChildren: children);

  static const String name = 'ZakatCalculatorRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i72.ZakatCalculatorPage();
    },
  );
}

/// generated route for
/// [_i73.ZakatCheckoutPage]
class ZakatCheckoutRoute extends _i75.PageRouteInfo<void> {
  const ZakatCheckoutRoute({List<_i75.PageRouteInfo>? children})
    : super(ZakatCheckoutRoute.name, initialChildren: children);

  static const String name = 'ZakatCheckoutRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i73.ZakatCheckoutPage();
    },
  );
}

/// generated route for
/// [_i74.ZakatRewardPage]
class ZakatRewardRoute extends _i75.PageRouteInfo<void> {
  const ZakatRewardRoute({List<_i75.PageRouteInfo>? children})
    : super(ZakatRewardRoute.name, initialChildren: children);

  static const String name = 'ZakatRewardRoute';

  static _i75.PageInfo page = _i75.PageInfo(
    name,
    builder: (data) {
      return const _i74.ZakatRewardPage();
    },
  );
}
