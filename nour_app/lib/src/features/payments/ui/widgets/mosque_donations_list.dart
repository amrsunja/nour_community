import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

import '../../data/models/tx_enums.dart';

/// "My donations → Mosques" tab (P3): recurring mosque gifts (cancellable)
/// followed by the one-time history. Receipts open the donor receipts page.
class MosqueDonationsList extends ConsumerWidget {
  const MosqueDonationsList({
    super.key,
    required this.donations,
    required this.subscriptions,
    required this.cancellingId,
    required this.onCancel,
    required this.onTapMosque,
    required this.onReceipts,
  });

  final List<MyMosqueDonation> donations;
  final List<MyMosqueSubscription> subscriptions;
  final int? cancellingId;
  final ValueChanged<int> onCancel;
  final ValueChanged<int> onTapMosque;
  final VoidCallback onReceipts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final lang = Localizations.localeOf(context).languageCode;
    final live = subscriptions.where((s) => s.status.isLive).toList();

    if (donations.isEmpty && live.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
        children: [
          const Icon(Icons.mosque_outlined, color: UIColorsToken.textYellow, size: 44),
          const UISpace.vert(12),
          Text(l10n.my_donations_empty_mosques, textAlign: TextAlign.center, style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph)),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        if (live.isNotEmpty) ...[
          Text(l10n.my_donations_tab_recurring, style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700)),
          const UISpace.vert(10),
          for (final s in live) ...[
            _SubTile(sub: s, l10n: l10n, lang: lang, busy: cancellingId == s.id, onCancel: () => onCancel(s.id), onTap: () => onTapMosque(s.mosqueId)),
            const UISpace.vert(8),
          ],
          const UISpace.vert(14),
        ],
        Row(
          children: [
            Expanded(child: Text(l10n.my_donations_tab_history, style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700))),
            UITap(onTap: onReceipts, child: Text(l10n.mosque_admin_receipts, style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow))),
          ],
        ),
        const UISpace.vert(10),
        for (final d in donations) ...[
          _TxTile(d: d, l10n: l10n, lang: lang, onTap: () => onTapMosque(d.mosqueId)),
          const UISpace.vert(8),
        ],
      ],
    );
  }
}

class _SubTile extends StatelessWidget {
  const _SubTile({required this.sub, required this.l10n, required this.lang, required this.busy, required this.onCancel, required this.onTap});
  final MyMosqueSubscription sub;
  final AppLocale l10n;
  final String lang;
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final money = MosqueFormat.money(sub.amount);
    final label = sub.frequency == DonationFrequency.monthly ? l10n.donate_per_month(money) : l10n.donate_per_year(money);
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.autorenew, color: UIColorsToken.green, size: 20),
            const UISpace.horz(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.mosqueName ?? '', style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  const UISpace.vert(2),
                  Text(
                    [
                      label,
                      sub.type == 'mosque_membership' ? l10n.mosque_admin_type_membership : l10n.mosque_admin_type_sadaqa,
                      if (sub.currentPeriodEnd != null)
                        sub.cancelAtPeriodEnd
                            ? l10n.my_donations_sub_ends_on(DateFormat.yMMMd(lang).format(sub.currentPeriodEnd!))
                            : l10n.my_donations_next_charge(DateFormat.yMMMd(lang).format(sub.currentPeriodEnd!)),
                    ].join(' · '),
                    style: typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
            if (!sub.cancelAtPeriodEnd)
              busy
                  ? const UICircularProgressBar(size: 16)
                  : UITap(onTap: onCancel, child: Text(l10n.my_donations_cancel, style: typo.inter.bodySmall.copyWith(color: UIColorsToken.red))),
          ],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.d, required this.l10n, required this.lang, required this.onTap});
  final MyMosqueDonation d;
  final AppLocale l10n;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final (status, color) = switch (d.status) {
      TxStatus.succeeded => (l10n.my_donations_status_succeeded, UIColorsToken.greenAccent),
      TxStatus.failed => (l10n.my_donations_status_failed, UIColorsToken.red),
      TxStatus.refunded => (l10n.my_donations_status_refunded, UIColorsToken.textYellow),
      _ => (l10n.my_donations_status_processing, UIColorsToken.textParagraph),
    };
    final kind = switch (d.type) {
      'mosque_campaign' => d.campaignTitle ?? l10n.mosque_admin_type_campaign,
      'mosque_membership' => l10n.mosque_admin_type_membership,
      _ => l10n.mosque_admin_type_sadaqa,
    };
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.mosqueName, style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  const UISpace.vert(2),
                  Text(
                    [kind, if (d.isRecurring) l10n.my_donations_recurring_badge, DateFormat.yMMMd(lang).format(d.createdAt)].join(' · '),
                    style: typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(MosqueFormat.money(d.amount), style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700)),
                Text(status, style: typo.inter.smallCaption.copyWith(color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
