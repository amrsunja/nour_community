import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/impact/data/datasources/impact_remote_datasource.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';

import '../../data/models/donation_subscription_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/tx_enums.dart';
import '../state_management/my_donations_provider.dart';

enum _Tab { history, recurring }

/// Profile → "My donations": one-time history (with status) and the recurring
/// donations the user can stop.
@RoutePage()
class MyDonationsPage extends HookConsumerWidget {
  const MyDonationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final langCode = Localizations.localeOf(context).languageCode;
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(myDonationsProvider.notifier);
    final state = ref.watch(myDonationsProvider);
    final tab = useState(_Tab.history);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    Future<void> confirmCancel(DonationSubscriptionModel sub) async {
      final ok = await _confirmStop(context, l10n);
      if (ok == true) await presenter.cancelSubscription(sub.id);
    }

    return Scaffold(
      appBar: UIAppBar(
        onBack: () => context.router.maybePop(),
        title: l10n.profile_my_donations,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: UITabs<_Tab>(
                selected: tab.value,
                trackColor: UIColorsToken.bgSurface,
                padding: const EdgeInsets.all(4),
                borderRadius: 10,
                items: [
                  UITabItem(value: _Tab.history, label: l10n.my_donations_tab_history),
                  UITabItem(value: _Tab.recurring, label: l10n.my_donations_tab_recurring),
                ],
                onChanged: (t) => tab.value = t,
              ),
            ),
            Expanded(
              child: state.isLoading && state.history.isEmpty && state.subscriptions.isEmpty
                  ? const Center(child: UICircularProgressBar())
                  : UIRefreshIndicator(
                      onRefresh: presenter.refresh,
                      child: switch (tab.value) {
                        _Tab.history => _HistoryList(
                            items: state.history,
                            langCode: langCode,
                            l10n: l10n,
                            typo: typo,
                            onTapProject: (id) => nav.toImpactProjectDetail(projectId: id),
                          ),
                        _Tab.recurring => _RecurringList(
                            items: state.subscriptions,
                            langCode: langCode,
                            l10n: l10n,
                            typo: typo,
                            cancellingId: state.cancellingId,
                            onCancel: confirmCancel,
                            onTapProject: (id) => nav.toImpactProjectDetail(projectId: id),
                          ),
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmStop(BuildContext context, AppLocale l10n) {
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
                l10n.my_donations_cancel_confirm_title,
                style: typo.inter.title.copyWith(color: UIColorsToken.white),
              ),
              const UISpace.vert(8),
              Text(
                l10n.my_donations_cancel_confirm_message,
                style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
              ),
              const UISpace.vert(24),
              UIButton.primary(
                label: l10n.my_donations_cancel_confirm_yes,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(true),
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
}

// ── History ───────────────────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.items,
    required this.langCode,
    required this.l10n,
    required this.typo,
    required this.onTapProject,
  });

  final List<TransactionModel> items;
  final String langCode;
  final AppLocale l10n;
  final UITypographyToken typo;
  final ValueChanged<int> onTapProject;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Empty(text: l10n.my_donations_empty_history);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const UISpace.vert(10),
      itemBuilder: (_, i) => _HistoryTile(
        tx: items[i],
        langCode: langCode,
        l10n: l10n,
        onTapProject: onTapProject,
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.tx,
    required this.langCode,
    required this.l10n,
    required this.onTapProject,
  });

  final TransactionModel tx;
  final String langCode;
  final AppLocale l10n;
  final ValueChanged<int> onTapProject;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final first = tx.items.isNotEmpty ? tx.items.first : null;
    final project = first?.project;
    final title = project == null
        ? '—'
        : (project['title_$langCode'] as String?)?.isNotEmpty == true
            ? project['title_$langCode'] as String
            : project['title_en'] as String? ?? '—';
    final cover = ImpactRemoteDatasource.publicStoryImageUrl(
      project?['cover_image_url'] as String?,
    );
    final (statusLabel, statusColor) = switch (tx.status) {
      TxStatus.succeeded => (l10n.my_donations_status_succeeded, UIColorsToken.greenAccent),
      TxStatus.failed => (l10n.my_donations_status_failed, UIColorsToken.red),
      TxStatus.refunded => (l10n.my_donations_status_refunded, UIColorsToken.textYellow),
      _ => (l10n.my_donations_status_processing, UIColorsToken.textParagraph),
    };
    final projectId = first?.impactProjectId;

    return UICard(
      disableBorder: true,
      padding: const EdgeInsets.all(12),
      onTap: projectId == null ? null : () => onTapProject(projectId),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: cover != null
                  ? CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover)
                  : Container(color: UIColorsToken.bgSurface),
            ),
          ),
          const UISpace.horz(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.inter.bodyMedium.copyWith(
                          color: UIColorsToken.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      ImpactFormat.moneyPrecise(tx.amountTotal, tx.currency),
                      style: typo.inter.title.copyWith(
                        color: UIColorsToken.textYellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const UISpace.vert(4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Chip(label: statusLabel, color: statusColor),
                    _Chip(
                      label: tx.type == TxType.zakat
                          ? l10n.my_donations_zakat
                          : l10n.my_donations_sadaqa,
                      color: UIColorsToken.textParagraph,
                    ),
                    if (tx.isRecurring)
                      _Chip(label: l10n.my_donations_recurring_badge, color: UIColorsToken.textParagraph),
                    if (tx.isAnonymous)
                      _Chip(label: l10n.my_donations_anonymous, color: UIColorsToken.textParagraph),
                  ],
                ),
                const UISpace.vert(6),
                Text(
                  [
                    DateFormat.yMMMd().format(tx.createdAt),
                    if (tx.feeCovered > 0)
                      l10n.my_donations_fee_included(
                        ImpactFormat.moneyPrecise(tx.feeCovered, tx.currency),
                      ),
                  ].join(' · '),
                  style: typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recurring ─────────────────────────────────────────────────────────────────

class _RecurringList extends StatelessWidget {
  const _RecurringList({
    required this.items,
    required this.langCode,
    required this.l10n,
    required this.typo,
    required this.cancellingId,
    required this.onCancel,
    required this.onTapProject,
  });

  final List<DonationSubscriptionModel> items;
  final String langCode;
  final AppLocale l10n;
  final UITypographyToken typo;
  final int? cancellingId;
  final ValueChanged<DonationSubscriptionModel> onCancel;
  final ValueChanged<int> onTapProject;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Empty(text: l10n.my_donations_empty_recurring);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const UISpace.vert(10),
      itemBuilder: (_, i) {
        final sub = items[i];
        final money = ImpactFormat.money(sub.amount, sub.currency);
        final amountLabel = sub.frequency == DonationFrequency.monthly
            ? l10n.donate_per_month(money)
            : l10n.donate_per_year(money);
        final (statusLabel, statusColor) = sub.cancelAtPeriodEnd && sub.status.isLive
            ? (
                l10n.my_donations_sub_ends_on(
                  sub.currentPeriodEnd == null
                      ? '—'
                      : DateFormat.yMMMd().format(sub.currentPeriodEnd!),
                ),
                UIColorsToken.textYellow,
              )
            : switch (sub.status) {
                SubscriptionStatus.active => (l10n.my_donations_sub_active, UIColorsToken.greenAccent),
                SubscriptionStatus.pastDue => (l10n.my_donations_sub_past_due, UIColorsToken.red),
                SubscriptionStatus.canceled => (l10n.my_donations_sub_canceled, UIColorsToken.textParagraph),
                SubscriptionStatus.unpaid => (l10n.my_donations_sub_past_due, UIColorsToken.red),
                _ => (l10n.my_donations_sub_incomplete, UIColorsToken.textParagraph),
              };
        final canStop = sub.isActive;
        final busy = cancellingId == sub.id;

        return UICard(
          disableBorder: true,
          padding: const EdgeInsets.all(14),
          onTap: () => onTapProject(sub.impactProjectId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sub.projectTitle(langCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.bodyMedium.copyWith(
                        color: UIColorsToken.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    amountLabel,
                    style: typo.inter.title.copyWith(
                      color: UIColorsToken.textYellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const UISpace.vert(6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Chip(label: statusLabel, color: statusColor),
                  if (sub.isAnonymous)
                    _Chip(label: l10n.my_donations_anonymous, color: UIColorsToken.textParagraph),
                ],
              ),
              if (sub.isActive && sub.currentPeriodEnd != null) ...[
                const UISpace.vert(6),
                Text(
                  l10n.my_donations_next_charge(
                    DateFormat.yMMMd().format(sub.currentPeriodEnd!),
                  ),
                  style: typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                ),
              ],
              if (canStop) ...[
                const UISpace.vert(10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: UIButton.secondary(
                    label: l10n.my_donations_cancel,
                    isSmall: true,
                    isBusy: busy,
                    onTap: busy ? null : () => onCancel(sub),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Text(
        label,
        style: typo.inter.smallCaption.copyWith(color: color),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      children: [
        const Icon(Icons.volunteer_activism_outlined, color: UIColorsToken.textYellow, size: 44),
        const UISpace.vert(12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
        ),
      ],
    );
  }
}
