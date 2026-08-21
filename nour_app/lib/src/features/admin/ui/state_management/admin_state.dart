import 'package:equatable/equatable.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:nour/src/features/payments/data/models/transaction_model.dart';

import '../../data/models/project_analytics_model.dart';

/// Which admin tab is showing.
enum AdminTab { projects, payouts, received }

/// Money-type filter — zakat and sadaqa are separated end to end, so the
/// admin can inspect each pool on its own (totals, ledger and received feed).
enum AdminTypeFilter { all, donation, zakat }

class AdminState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final bool loaded;
  final AdminTab tab;
  final List<ProjectAnalyticsModel> analytics;
  final Map<int, ImpactProjectModel> projectsById;
  final List<PayoutModel> payouts;
  final List<TransactionModel> transactions;
  final bool isSubmittingPayout;

  /// Payout id whose status change is in flight (row spinner).
  final int? updatingPayoutId;

  /// Active money-type filter (All / Sadaqa / Zakat).
  final AdminTypeFilter typeFilter;

  const AdminState({
    this.isLoading = false,
    this.hasError = false,
    this.loaded = false,
    this.tab = AdminTab.projects,
    this.analytics = const [],
    this.projectsById = const {},
    this.payouts = const [],
    this.transactions = const [],
    this.isSubmittingPayout = false,
    this.updatingPayoutId,
    this.typeFilter = AdminTypeFilter.all,
  });

  TxType? get _filterType => switch (typeFilter) {
    AdminTypeFilter.all => null,
    AdminTypeFilter.donation => TxType.donation,
    AdminTypeFilter.zakat => TxType.zakat,
  };

  // ── Filtered views (respect the zakat/sadaqa separation) ───────────────────
  List<ProjectAnalyticsModel> get visibleAnalytics => _filterType == null
      ? analytics
      : [for (final r in analytics) if (r.type == _filterType) r];

  List<PayoutModel> get visiblePayouts => _filterType == null
      ? payouts
      : [for (final p in payouts) if (p.type == _filterType) p];

  List<TransactionModel> get visibleTransactions => _filterType == null
      ? transactions
      : [for (final t in transactions) if (t.type == _filterType) t];

  // ── Aggregate totals across the FILTERED (project,type) rows ──────────────
  double get totalDonated =>
      visibleAnalytics.fold(0, (s, r) => s + r.totalDonated);

  double get totalPaidOut => visibleAnalytics.fold(0, (s, r) => s + r.paidOut);

  double get totalOutstanding =>
      visibleAnalytics.fold(0, (s, r) => s + r.outstanding);

  int get totalDonors => visibleAnalytics.fold(0, (s, r) => s + r.donorsCount);

  /// Currency to label the totals with — derived from the first known project,
  /// defaulting to EUR (the app's default currency).
  String get displayCurrency =>
      projectsById.values.isNotEmpty
          ? projectsById.values.first.currency
          : 'EUR';

  AdminState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? loaded,
    AdminTab? tab,
    List<ProjectAnalyticsModel>? analytics,
    Map<int, ImpactProjectModel>? projectsById,
    List<PayoutModel>? payouts,
    List<TransactionModel>? transactions,
    bool? isSubmittingPayout,
    int? updatingPayoutId,
    bool clearUpdatingPayout = false,
    AdminTypeFilter? typeFilter,
  }) => AdminState(
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
    loaded: loaded ?? this.loaded,
    tab: tab ?? this.tab,
    analytics: analytics ?? this.analytics,
    projectsById: projectsById ?? this.projectsById,
    payouts: payouts ?? this.payouts,
    transactions: transactions ?? this.transactions,
    isSubmittingPayout: isSubmittingPayout ?? this.isSubmittingPayout,
    updatingPayoutId: clearUpdatingPayout
        ? null
        : (updatingPayoutId ?? this.updatingPayoutId),
    typeFilter: typeFilter ?? this.typeFilter,
  );

  @override
  List<Object?> get props => [
    isLoading,
    hasError,
    loaded,
    tab,
    analytics,
    projectsById,
    payouts,
    transactions,
    isSubmittingPayout,
    updatingPayoutId,
    typeFilter,
  ];
}
