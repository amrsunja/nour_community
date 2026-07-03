import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';

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

    final analyticsRes = await repo.fetchAnalytics();
    final projectsRes = await repo.fetchAllProjects();
    final payoutsRes = await repo.fetchPayouts();
    final txRes = await repo.fetchTransactions();

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

  List<ImpactProjectModel> get projects =>
      state.projectsById.values.toList();

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
    if (ok) await load(silent: true); // refresh analytics + ledger
    return ok;
  }
}
