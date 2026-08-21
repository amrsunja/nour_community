import 'dart:async';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import '../../data/admin_repo.dart';
import '../../data/models/record_payout_params.dart';
import 'admin_state.dart';

final adminProvider =
    StateNotifierProvider<AdminPresenter, AdminState>((ref) {
  return AdminPresenter(
    repo: ref.read(adminRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class AdminPresenter extends Presenter<AdminState> {
  final AdminRepo repo;
  final AppEvents appEvents;

  AdminPresenter({required this.repo, required this.appEvents})
    : super(const AdminState());

  Future<void> init() async {
    if (state.loaded || state.isLoading) return;
    await load();
  }

  Future<void> load({bool silent = false}) async {
    state = state.copyWith(isLoading: !silent, hasError: false);

    // All four reads are independent — run them in parallel (one round-trip
    // of latency instead of four).
    final (analyticsRes, projectsRes, payoutsRes, txRes) = await (
      repo.fetchAnalytics(),
      repo.fetchAllProjects(),
      repo.fetchPayouts(),
      repo.fetchTransactions(),
    ).wait;

    projectsRes.when(
      (projects) => state = state.copyWith(
        projectsById: {for (final p in projects) p.id: p},
      ),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    payoutsRes.when(
      (payouts) => state = state.copyWith(payouts: payouts),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    txRes.when(
      (tx) => state = state.copyWith(transactions: tx),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );

    analyticsRes.when(
      (rows) => state = state.copyWith(
        analytics: rows,
        loaded: true,
        isLoading: false,
      ),
      (error) {
        state = state.copyWith(isLoading: false, hasError: !silent);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  Future<void> refresh() => load(silent: true);

  void selectTab(AdminTab tab) {
    if (tab == state.tab) return;
    state = state.copyWith(tab: tab);
  }

  /// All / Sadaqa / Zakat — filters totals, ledger and received feed.
  void selectTypeFilter(AdminTypeFilter filter) {
    if (filter == state.typeFilter) return;
    state = state.copyWith(typeFilter: filter);
  }

  List<ImpactProjectModel> get projects =>
      state.projectsById.values.toList();

  /// Changes a payout's status (pending / sent / confirmed). Optimistic: the
  /// ledger row updates immediately, reverts on failure; analytics (paid_out /
  /// outstanding count only confirmed payouts) refresh in the background.
  Future<void> updatePayoutStatus(int payoutId, PayoutStatus status) async {
    if (state.updatingPayoutId != null) return;
    final previous = state.payouts;
    final idx = previous.indexWhere((p) => p.id == payoutId);
    if (idx < 0 || previous[idx].status == status) return;

    state = state.copyWith(
      updatingPayoutId: payoutId,
      payouts: [
        for (final p in previous)
          if (p.id == payoutId)
            PayoutModel(
              id: p.id,
              organizationId: p.organizationId,
              impactProjectId: p.impactProjectId,
              type: p.type,
              amount: p.amount,
              currency: p.currency,
              method: p.method,
              status: status,
              reference: p.reference,
              proofPath: p.proofPath,
              note: p.note,
              executedAt:
                  status == PayoutStatus.pending ? null : DateTime.now(),
              createdAt: p.createdAt,
            )
          else
            p,
      ],
    );

    final res = await repo.updatePayoutStatus(payoutId: payoutId, status: status);
    if (!mounted) return;
    res.when(
      (_) {
        state = state.copyWith(clearUpdatingPayout: true);
        unawaited(load(silent: true)); // refresh analytics totals
      },
      (error) {
        state = state.copyWith(payouts: previous, clearUpdatingPayout: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  /// Deletes a wrongly recorded payout. Optimistic (row disappears at once,
  /// restored on failure); a deleted CONFIRMED payout also disappears from the
  /// public project transparency section and the paid_out/outstanding totals
  /// recompute on the background refresh.
  Future<void> deletePayout(int payoutId) async {
    if (state.updatingPayoutId != null) return;
    final previous = state.payouts;
    final idx = previous.indexWhere((p) => p.id == payoutId);
    if (idx < 0) return;
    final payout = previous[idx];

    state = state.copyWith(
      updatingPayoutId: payoutId,
      payouts: [for (final p in previous) if (p.id != payoutId) p],
    );

    final res = await repo.deletePayout(
      payoutId: payoutId,
      proofPath: payout.proofPath,
    );
    if (!mounted) return;
    res.when(
      (_) {
        state = state.copyWith(clearUpdatingPayout: true);
        unawaited(load(silent: true)); // refresh analytics totals
      },
      (error) {
        state = state.copyWith(payouts: previous, clearUpdatingPayout: true);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  /// Uploads the optional proof image then records the payout. Returns true on
  /// success (the caller can pop / show confirmation).
  Future<bool> recordPayout(
    RecordPayoutParams params, {
    Uint8List? proofBytes,
    String proofExt = 'jpg',
    String proofContentType = 'image/jpeg',
    List<int> transactionItemIds = const [],
  }) async {
    state = state.copyWith(isSubmittingPayout: true);

    String? proofPath = params.proofPath;
    if (proofBytes != null) {
      final upload = await repo.uploadProof(
        bytes: proofBytes,
        fileExt: proofExt,
        contentType: proofContentType,
      );
      final resolved = upload.when((p) => p, (error) {
        appEvents.send(ShowErrorEvent(error));
        return null;
      });
      if (resolved == null) {
        state = state.copyWith(isSubmittingPayout: false);
        return false;
      }
      proofPath = resolved;
    }

    final withProof = RecordPayoutParams(
      organizationId: params.organizationId,
      impactProjectId: params.impactProjectId,
      type: params.type,
      amount: params.amount,
      currency: params.currency,
      method: params.method,
      status: params.status,
      reference: params.reference,
      proofPath: proofPath,
      note: params.note,
      executedAt: params.executedAt,
    );

    final res = await repo.createPayout(
      withProof,
      transactionItemIds: transactionItemIds,
    );

    final ok = res.when((_) => true, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });

    state = state.copyWith(isSubmittingPayout: false);
    // Refresh analytics + ledger in the background — the caller (sheet) pops
    // immediately on success instead of waiting for four more requests.
    if (ok) unawaited(load(silent: true));
    return ok;
  }
}
