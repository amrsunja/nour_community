import 'package:auto_route/auto_route.dart';
import 'package:nour/src/features/admin/ui/widgets/admin_mosques_tab.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';
import 'package:nour/src/features/payments/data/models/transaction_model.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:nour/src/features/payments/ui/widgets/payout_proof_image.dart';

import '../../data/models/project_analytics_model.dart';
import '../state_management/admin_provider.dart';
import '../state_management/admin_state.dart';
import '../widgets/record_payout_sheet.dart';

/// Admin › Transactions & Donations analytics. Summary totals + three tabs:
/// per-project donation breakdown (with a "record payout" action), the payout
/// ledger (with proofs), and the raw received-transactions feed.
@RoutePage()
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final state = ref.watch(adminProvider);
    final notifier = ref.read(adminProvider.notifier);
    final langCode = Localizations.localeOf(context).languageCode;
    final currency = state.displayCurrency;

    return Scaffold(
      appBar: UIAppBar(
        onBack: () => context.router.maybePop(),
        title: l10n.admin_analytics_title,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UIColorsToken.textYellow,
        foregroundColor: UIColorsToken.black,
        onPressed: () => RecordPayoutSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.admin_record_payout),
      ),
      body: state.isLoading && !state.loaded
          ? const Center(child: UICircularProgressBar())
          : RefreshIndicator(
              onRefresh: notifier.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  kPageHorzPadding,
                  12,
                  kPageHorzPadding,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary.
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: l10n.admin_total_donated,
                            value: ImpactFormat.money(
                                state.totalDonated, currency),
                            icon: Icons.volunteer_activism,
                          ),
                        ),
                        const UISpace.horz(10),
                        Expanded(
                          child: _StatCard(
                            label: l10n.admin_total_donors,
                            value: '${state.totalDonors}',
                            icon: Icons.groups_outlined,
                          ),
                        ),
                      ],
                    ),
                    const UISpace.vert(10),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: l10n.admin_total_paid_out,
                            value: ImpactFormat.money(
                                state.totalPaidOut, currency),
                            icon: Icons.outbond_outlined,
                          ),
                        ),
                        const UISpace.horz(10),
                        Expanded(
                          child: _StatCard(
                            label: l10n.admin_outstanding,
                            value: ImpactFormat.money(
                                state.totalOutstanding, currency),
                            icon: Icons.pending_actions_outlined,
                          ),
                        ),
                      ],
                    ),
                    const UISpace.vert(16),

                    // Zakat vs Sadaqa separation — filters the totals above
                    // and the lists below.
                    UITabs<AdminTypeFilter>(
                      selected: state.typeFilter,
                      trackColor: UIColorsToken.bgSurface,
                      padding: const EdgeInsets.all(4),
                      borderRadius: 10,
                      items: [
                        UITabItem(
                          value: AdminTypeFilter.all,
                          label: l10n.admin_filter_all,
                        ),
                        UITabItem(
                          value: AdminTypeFilter.donation,
                          label: l10n.donate_type_donation,
                        ),
                        UITabItem(
                          value: AdminTypeFilter.zakat,
                          label: l10n.donate_type_zakat,
                        ),
                      ],
                      onChanged: notifier.selectTypeFilter,
                    ),
                    const UISpace.vert(14),

                    UITabs<AdminTab>(
                      selected: state.tab,
                      items: [
                        UITabItem(
                          value: AdminTab.projects,
                          label: l10n.admin_tab_projects,
                        ),
                        UITabItem(
                          value: AdminTab.payouts,
                          label: l10n.admin_tab_payouts,
                        ),
                        UITabItem(
                          value: AdminTab.received,
                          label: l10n.admin_tab_received,
                        ),
                        UITabItem(
                          value: AdminTab.mosques,
                          label: l10n.admin_tab_mosques,
                        ),
                      ],
                      onChanged: notifier.selectTab,
                    ),
                    const UISpace.vert(14),

                    switch (state.tab) {
                      AdminTab.projects => _ProjectsTab(
                          state: state,
                          langCode: langCode,
                          l10n: l10n,
                        ),
                      AdminTab.payouts => _PayoutsTab(
                          state: state,
                          langCode: langCode,
                          l10n: l10n,
                          onChangeStatus: (payout, status) => notifier
                              .updatePayoutStatus(payout.id, status),
                          onDelete: (payout) => notifier.deletePayout(payout.id),
                        ),
                      AdminTab.received => _ReceivedTab(
                          state: state,
                          langCode: langCode,
                          l10n: l10n,
                        ),
                      AdminTab.mosques => const AdminMosquesTab(),
                    },
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UICard(
      padding: const EdgeInsets.all(14),
      disableBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: UIColorsToken.textYellow, size: 20),
          const UISpace.vert(10),
          Text(
            value,
            style: typo.inter.title.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const UISpace.vert(2),
          Text(
            label,
            style: typo.inter.bodySmall
                .copyWith(color: UIColorsToken.textParagraph),
          ),
        ],
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({
    required this.state,
    required this.langCode,
    required this.l10n,
  });

  final AdminState state;
  final String langCode;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    // Group analytics rows by project.
    final byProject = <int, List<ProjectAnalyticsModel>>{};
    for (final row in state.visibleAnalytics) {
      byProject.putIfAbsent(row.projectId, () => []).add(row);
    }

    final projects = state.projectsById.values.toList();
    if (projects.isEmpty) {
      return _Empty(l10n.admin_empty_projects);
    }

    return Column(
      children: [
        for (final project in projects)
          SizedBox(
          width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProjectCard(
                project: project,
                rows: byProject[project.id] ?? const [],
                langCode: langCode,
                l10n: l10n,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.rows,
    required this.langCode,
    required this.l10n,
  });

  final ImpactProjectModel project;
  final List<ProjectAnalyticsModel> rows;
  final String langCode;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final currency = project.currency;

    return UICard(
      padding: const EdgeInsets.all(16),
      disableBorder: true,
      color: UIColorsToken.bgSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title(langCode),
            style: typo.inter.title.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const UISpace.vert(12),
          if (rows.isEmpty)
            Text(
              l10n.admin_no_donations_yet,
              style: typo.inter.bodySmall
                  .copyWith(color: UIColorsToken.textParagraph),
            )
          else
            for (final row in rows) ...[
              _TypeBreakdown(row: row, currency: currency, l10n: l10n),
              const UISpace.vert(8),
            ],
          const UISpace.vert(6),
          UIButton.secondary(
            label: l10n.admin_record_payout,
            isSmall: true,
            onTap: () => RecordPayoutSheet.show(
              context,
              presetProject: project,
              presetType: rows.isNotEmpty ? rows.first.type : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBreakdown extends StatelessWidget {
  const _TypeBreakdown({
    required this.row,
    required this.currency,
    required this.l10n,
  });

  final ProjectAnalyticsModel row;
  final String currency;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final isZakat = row.type == TxType.zakat;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UIColorsToken.bgSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isZakat ? l10n.donate_type_zakat : l10n.donate_type_donation,
                style: typo.inter.bodyMedium.copyWith(
                  color: isZakat
                      ? UIColorsToken.greenAccent
                      : UIColorsToken.textYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.admin_donors_count('${row.donorsCount}'),
                style: typo.inter.bodySmall
                    .copyWith(color: UIColorsToken.textParagraph),
              ),
            ],
          ),
          const UISpace.vert(8),
          _Line(l10n.admin_total_donated,
              ImpactFormat.money(row.totalDonated, currency)),
          _Line(l10n.admin_total_paid_out,
              ImpactFormat.money(row.paidOut, currency)),
          _Line(
            l10n.admin_outstanding,
            ImpactFormat.money(row.outstanding, currency),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: typo.inter.bodySmall
                .copyWith(color: UIColorsToken.textParagraph),
          ),
          Text(
            value,
            style: typo.inter.bodySmall.copyWith(
              color: highlight ? UIColorsToken.textYellow : UIColorsToken.white,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutsTab extends StatelessWidget {
  const _PayoutsTab({
    required this.state,
    required this.langCode,
    required this.l10n,
    required this.onChangeStatus,
    required this.onDelete,
  });

  final AdminState state;
  final String langCode;
  final AppLocale l10n;
  final void Function(PayoutModel payout, PayoutStatus status) onChangeStatus;
  final void Function(PayoutModel payout) onDelete;

  @override
  Widget build(BuildContext context) {
    if (state.visiblePayouts.isEmpty) return _Empty(l10n.admin_empty_payouts);
    return Column(
      children: [
        for (final payout in state.visiblePayouts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PayoutTile(
              payout: payout,
              projectTitle:
                  state.projectsById[payout.impactProjectId]?.title(langCode),
              l10n: l10n,
              isUpdating: state.updatingPayoutId == payout.id,
              // Tap a row to advance/revert its lifecycle. Only `confirmed`
              // payouts appear in the public project "Transactions" block.
              onTap: state.updatingPayoutId != null
                  ? null
                  : () async {
                      final action = await _PayoutStatusSheet.show(
                        context,
                        current: payout.status,
                        l10n: l10n,
                      );
                      if (action == null) return;
                      if (action.delete) {
                        if (!context.mounted) return;
                        final ok = await _confirmDeletePayout(context, l10n);
                        if (ok == true) onDelete(payout);
                      } else if (action.status != null &&
                          action.status != payout.status) {
                        onChangeStatus(payout, action.status!);
                      }
                    },
            ),
          ),
      ],
    );
  }
}

/// What the admin picked in the payout sheet: a new status, or deletion.
class _PayoutSheetAction {
  const _PayoutSheetAction.status(PayoutStatus this.status) : delete = false;
  const _PayoutSheetAction.delete()
      : status = null,
        delete = true;

  final PayoutStatus? status;
  final bool delete;
}

/// Bottom sheet to pick a payout's new status (or delete a wrong entry).
/// Explains that only `confirmed` disbursements are shown publicly.
class _PayoutStatusSheet extends StatelessWidget {
  const _PayoutStatusSheet({required this.current, required this.l10n});

  final PayoutStatus current;
  final AppLocale l10n;

  static Future<_PayoutSheetAction?> show(
    BuildContext context, {
    required PayoutStatus current,
    required AppLocale l10n,
  }) {
    return showModalBottomSheet<_PayoutSheetAction>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true, // content is taller than the default half-sheet
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PayoutStatusSheet(current: current, l10n: l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    (String, String) describe(PayoutStatus s) => switch (s) {
          PayoutStatus.pending => (
              l10n.payout_pending,
              l10n.admin_status_pending_hint,
            ),
          PayoutStatus.sent => (
              l10n.payout_sent,
              l10n.admin_status_sent_hint,
            ),
          PayoutStatus.confirmed => (
              l10n.payout_confirmed,
              l10n.admin_status_confirmed_hint,
            ),
        };

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UIColorsToken.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const UISpace.vert(20),
            Text(
              l10n.admin_change_status_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(4),
            Text(
              l10n.admin_change_status_subtitle,
              style: typo.inter.bodySmall
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(16),
            for (final s in PayoutStatus.values) ...[
              UITap(
                onTap: () =>
                    Navigator.of(context).pop(_PayoutSheetAction.status(s)),
                child: UISelecteableCard(
                  selected: s == current,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              describe(s).$1,
                              style: typo.inter.title.copyWith(
                                color: s == current
                                    ? UIColorsToken.textYellow
                                    : UIColorsToken.white,
                              ),
                            ),
                            const UISpace.vert(2),
                            Text(
                              describe(s).$2,
                              style: typo.inter.bodySmall.copyWith(
                                color: UIColorsToken.textParagraph,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (s == current)
                        const Icon(Icons.check,
                            size: 18, color: UIColorsToken.textYellow),
                    ],
                  ),
                ),
              ),
              const UISpace.vert(10),
            ],
            const UISpace.vert(4),
            // Correction path: a wrongly recorded payout can be removed.
            UITap(
              onTap: () =>
                  Navigator.of(context).pop(const _PayoutSheetAction.delete()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: UIColorsToken.red.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 20, color: UIColorsToken.red),
                    const UISpace.horz(10),
                    Text(
                      l10n.admin_delete_payout,
                      style: typo.inter.title
                          .copyWith(color: UIColorsToken.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Destructive confirmation before removing a payout from the ledger.
Future<bool?> _confirmDeletePayout(BuildContext context, AppLocale l10n) {
  final typo = UITheme.of(context).typo;
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: UIColorsToken.bgPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UIColorsToken.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const UISpace.vert(20),
            Text(
              l10n.admin_delete_payout_confirm_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(8),
            Text(
              l10n.admin_delete_payout_confirm_message,
              style: typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(24),
            UITap(
              onTap: () => Navigator.of(ctx).pop(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: UIColorsToken.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.admin_delete_payout_confirm_yes,
                  style: typo.inter.buttonLabel
                      .copyWith(color: UIColorsToken.white),
                ),
              ),
            ),
            const UISpace.vert(8),
            UIButton.textual(
              label: l10n.my_donations_keep,
              fullWidth: true,
              onTap: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A single payout row — reused by the admin ledger and (read-only) elsewhere.
class PayoutTile extends StatelessWidget {
  const PayoutTile({
    super.key,
    required this.payout,
    required this.l10n,
    this.projectTitle,
    this.onTap,
    this.isUpdating = false,
  });

  final PayoutModel payout;
  final String? projectTitle;
  final AppLocale l10n;

  /// When set the tile is tappable (admin ledger → change status).
  final VoidCallback? onTap;

  /// Shows a small spinner instead of the status chip while an update runs.
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final date = payout.executedAt ?? payout.createdAt;

    return UICard(
      padding: const EdgeInsets.all(14),
      disableBorder: true,
      color: UIColorsToken.bgSurface,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (payout.hasProof) ...[
            PayoutProofImage(proofPath: payout.proofPath!),
            const UISpace.horz(12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ImpactFormat.money(payout.amount, payout.currency),
                      style: typo.inter.title.copyWith(
                        color: UIColorsToken.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    isUpdating
                        ? const UICircularProgressBar(
                            size: 18, color: UIColorsToken.textYellow)
                        : _StatusChip(status: payout.status, l10n: l10n),
                  ],
                ),
                const UISpace.vert(4),
                if (projectTitle != null)
                  Text(
                    projectTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                const UISpace.vert(2),
                Text(
                  '${payout.type.value.toUpperCase()} · '
                  '${payout.method.value.toUpperCase()} · '
                  '${DateFormat.yMMMd().format(date)}',
                  style: typo.inter.smallCaption
                      .copyWith(color: UIColorsToken.textParagraph),
                ),
                if (payout.note != null && payout.note!.isNotEmpty) ...[
                  const UISpace.vert(6),
                  Text(
                    payout.note!,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final PayoutStatus status;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final (color, label) = switch (status) {
      PayoutStatus.confirmed => (UIColorsToken.greenAccent, l10n.payout_confirmed),
      PayoutStatus.sent => (UIColorsToken.textYellow, l10n.payout_sent),
      PayoutStatus.pending => (UIColorsToken.textParagraph, l10n.payout_pending),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: typo.inter.smallCaption
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ReceivedTab extends StatelessWidget {
  const _ReceivedTab({
    required this.state,
    required this.langCode,
    required this.l10n,
  });

  final AdminState state;
  final String langCode;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    if (state.visibleTransactions.isEmpty) return _Empty(l10n.admin_empty_received);
    return Column(
      children: [
        for (final tx in state.visibleTransactions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TransactionTile(tx: tx, l10n: l10n),
          ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx, required this.l10n});

  final TransactionModel tx;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final statusColor = switch (tx.status) {
      TxStatus.succeeded => UIColorsToken.greenAccent,
      TxStatus.failed || TxStatus.refunded => UIColorsToken.red,
      _ => UIColorsToken.textYellow,
    };

    return UICard(
      padding: const EdgeInsets.all(14),
      disableBorder: true,
      borderRadius: 10,
      color: UIColorsToken.bgSurface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ImpactFormat.money(tx.amountTotal, tx.currency),
                  style: typo.inter.bodyMedium.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const UISpace.vert(2),
                Text(
                  '${tx.type.value.toUpperCase()} · '
                  '${DateFormat.yMMMd().add_Hm().format(tx.createdAt)}',
                  style: typo.inter.smallCaption
                      .copyWith(color: UIColorsToken.textParagraph),
                ),
              ],
            ),
          ),
          Text(
            tx.status.value,
            style: typo.inter.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: typo.inter.bodyMedium
              .copyWith(color: UIColorsToken.textParagraph),
        ),
      ),
    );
  }
}
