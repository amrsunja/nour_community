import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Donors list (devis B5/B7): year + type filters, CSV export, per-gift
/// receipt generation (when the mosque can issue tax receipts).
@RoutePage()
class MosqueAdminDonorsPage extends HookConsumerWidget {
  const MosqueAdminDonorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final snackbar = ref.read(snackbarProvider);
    final appEvents = ref.read(appEventProvider);
    final repo = ref.read(mosqueRepoProvider);
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));

    final year = useState<int?>(DateTime.now().year);
    final type = useState<String?>(null);
    final rows = useState<List<MosqueDonorRow>>(const []);
    final loading = useState(true);
    final hasMore = useState(false);
    final busyId = useState<int?>(null);

    Future<void> load({bool more = false}) async {
      final id = mosque?.id;
      if (id == null) return;
      loading.value = true;
      final offset = more ? rows.value.length : 0;
      final res = await repo.getDonors(id, year: year.value, type: type.value, limit: 50, offset: offset);
      res.when((v) {
        rows.value = more ? [...rows.value, ...v] : v;
        hasMore.value = v.length == 50;
      }, (e) => appEvents.send(ShowErrorEvent(e)));
      loading.value = false;
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => load());
      return null;
    }, [year.value, type.value, mosque?.id]);

    Future<void> exportCsv() async {
      final b = StringBuffer('date,name,email,amount,type,recurring,anonymous,campaign,receipt\n');
      for (final r in rows.value) {
        String esc(String? s) => '"${(s ?? '').replaceAll('"', '""')}"';
        b.writeln([
          DateFormat('yyyy-MM-dd').format(r.createdAt),
          esc(r.name),
          esc(r.email),
          r.amount.toStringAsFixed(2),
          r.type,
          r.isRecurring ? 'yes' : 'no',
          r.isAnonymous ? 'yes' : 'no',
          esc(r.campaignTitle),
          r.receiptId?.toString() ?? '',
        ].join(','));
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/donors_${year.value ?? 'all'}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
      await file.writeAsString(b.toString());
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    }

    Future<void> receipt(MosqueDonorRow r) async {
      busyId.value = r.transactionId;
      final res = await repo.generateReceipt(transactionId: r.transactionId);
      busyId.value = null;
      res.when((g) async {
        snackbar.showSuccess(l10n.mosque_admin_receipt_generated);
        if (g.url != null) await launchUrl(Uri.parse(g.url!), mode: LaunchMode.externalApplication);
        await load();
      }, (e) => appEvents.send(ShowErrorEvent(e)));
    }

    final years = [for (var y = DateTime.now().year; y >= DateTime.now().year - 4; y--) y];
    final types = <(String?, String)>[
      (null, l10n.mosque_admin_filter_all),
      ('mosque_sadaqa', l10n.mosque_admin_type_sadaqa),
      ('mosque_campaign', l10n.mosque_admin_type_campaign),
      ('mosque_membership', l10n.mosque_admin_type_membership),
    ];

    return UIGradientLinedScaffold(
      appBar: UIAppBar(
        title: l10n.mosque_admin_donors_list,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          UITap(onTap: rows.value.isEmpty ? null : exportCsv, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.download_outlined, color: UIColorsToken.textYellow))),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
              children: [
                _Chip(label: l10n.mosque_admin_filter_all, selected: year.value == null, onTap: () => year.value = null),
                for (final y in years) _Chip(label: '$y', selected: year.value == y, onTap: () => year.value = y),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
              children: [for (final t in types) _Chip(label: t.$2, selected: type.value == t.$1, onTap: () => type.value = t.$1)],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading.value && rows.value.isEmpty
                ? const Center(child: UICircularProgressBar())
                : rows.value.isEmpty
                    ? Center(child: Text(l10n.mosque_admin_donors_empty, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 4, kPageHorzPadding, 40),
                        physics: const BouncingScrollPhysics(),
                        itemCount: rows.value.length + (hasMore.value ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          if (i >= rows.value.length) {
                            return Center(child: UIButton.textual(label: l10n.common_load_more, onTap: () => load(more: true)));
                          }
                          final r = rows.value[i];
                          final typeLabel = switch (r.type) {
                            'mosque_campaign' => r.campaignTitle ?? l10n.mosque_admin_type_campaign,
                            'mosque_membership' => l10n.mosque_admin_type_membership,
                            _ => l10n.mosque_admin_type_sadaqa,
                          };
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                UIAvatar(url: r.avatarUrl, initial: (r.name ?? 'A').isEmpty ? 'A' : r.name!.substring(0, 1).toUpperCase(), color: UIColorsToken.black80, size: 38),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.isAnonymous ? l10n.mosque_donor_anonymous : (r.name ?? ''), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                                      const SizedBox(height: 2),
                                      Text(
                                        [typeLabel, if (r.isRecurring) l10n.mosque_admin_recurring, MosqueFormat.longDate(r.createdAt, lang)].join(' · '),
                                        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(MosqueFormat.money(r.amount), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700)),
                                    if ((mosque?.canIssueTaxReceipts ?? false) && !r.isAnonymous)
                                      busyId.value == r.transactionId
                                          ? const Padding(padding: EdgeInsets.only(top: 4), child: UICircularProgressBar(size: 14))
                                          : UITap(
                                              onTap: () => receipt(r),
                                              child: Text(
                                                r.receiptId != null ? l10n.mosque_admin_receipt_view : l10n.mosque_admin_receipt_issue,
                                                style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph, decoration: TextDecoration.underline),
                                              ),
                                            ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: UITap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected ? UIColorsToken.bgPriYellow : null,
            color: selected ? null : Colors.transparent,
          ),
          child: Text(label, style: theme.typo.inter.bodyMedium.copyWith(color: selected ? UIColorsToken.black : UIColorsToken.white)),
        ),
      ),
    );
  }
}
