import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
import 'package:url_launcher/url_launcher.dart';

import '../widgets/donor_tax_profile_sheet.dart';

/// Receipts issued by the mosque (devis B7). Also used by donors
/// (`mosqueId == null` → own receipts across mosques).
@RoutePage()
class MosqueAdminReceiptsPage extends HookConsumerWidget {
  const MosqueAdminReceiptsPage({super.key, @QueryParam('mine') this.mine = false});

  /// True when opened from the donor side ("My donations").
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final snackbar = ref.read(snackbarProvider);
    final appEvents = ref.read(appEventProvider);
    final repo = ref.read(mosqueRepoProvider);
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final rows = useState<List<MosqueReceipt>>(const []);
    final loading = useState(true);
    final openingId = useState<int?>(null);
    // Donor self-service: the (mosque, year) pairs they gave to.
    final years = useState<List<MosqueDonationYear>>(const []);
    final requesting = useState<String?>(null);

    Future<void> load() async {
      loading.value = true;
      final res = await repo.getReceipts(mosqueId: mine ? null : mosque?.id);
      res.when((v) => rows.value = v, (e) => appEvents.send(ShowErrorEvent(e)));
      if (mine) {
        final y = await repo.getMyDonationYears();
        y.when((v) => years.value = v, (e) => appEvents.send(ShowErrorEvent(e)));
      }
      loading.value = false;
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => load());
      return null;
    }, [mosque?.id]);

    /// Asks the server for a document. A tax receipt needs the donor's postal
    /// address (mandatory in FR and collected nowhere else), so the sheet is
    /// shown first when the fiscal profile is incomplete.
    Future<void> request(MosqueDonationYear y, {required bool taxReceipt}) async {
      final key = '${y.mosqueId}-${y.year}-$taxReceipt';
      if (requesting.value != null) return;

      if (taxReceipt) {
        final profileRes = await repo.getMyTaxProfile();
        final profile = profileRes.when((v) => v, (_) => null);
        if (profile == null || !profile.isComplete) {
          if (!context.mounted) return;
          final saved = await askDonorTaxProfile(context, ref, initial: profile);
          if (saved == null) return;
        }
      }

      requesting.value = key;
      final res = await repo.generateReceipt(
        mosqueId: y.mosqueId,
        year: y.year,
        kind: taxReceipt ? MosqueReceipt.kindTax : MosqueReceipt.kindAttestation,
      );
      requesting.value = null;

      await res.when((generated) async {
        await load();
        final url = generated.url;
        if (url != null) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }, (e) async => appEvents.send(ShowErrorEvent(e)));
    }

    Future<void> open(MosqueReceipt r) async {
      openingId.value = r.id;
      final url = await repo.receiptUrl(r.storagePath);
      openingId.value = null;
      if (url == null) {
        snackbar.showError(l10n.error_api_mosque_receipt_failed);
        return;
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    final canIssue = !mine && (mosque?.canIssueTaxReceipts ?? false);

    return Scaffold(
      appBar: UIAppBar(title: l10n.mosque_admin_receipts, onBack: () => context.router.maybePop()),
      body: loading.value && rows.value.isEmpty
          ? const Center(child: UICircularProgressBar())
          : Column(
              children: [
                if (mine && years.value.isNotEmpty)
                  _DonorRequestSection(
                    years: years.value,
                    l10n: l10n,
                    lang: lang,
                    theme: theme,
                    busyKey: requesting.value,
                    onRequest: request,
                  ),
                if (!mine && !canIssue)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Text(l10n.error_api_mosque_receipts_not_allowed, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                    ),
                  ),
                Expanded(
                  child: rows.value.isEmpty
                      ? Center(child: Text(l10n.mosque_receipts_empty, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 12, kPageHorzPadding, 40),
                          physics: const BouncingScrollPhysics(),
                          itemCount: rows.value.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final r = rows.value[i];
                            return UITap(
                              onTap: () => open(r),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf_outlined, color: UIColorsToken.textYellow),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r.number, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                                          const SizedBox(height: 2),
                                          Text(
                                            [
                                              r.transactionId == null ? l10n.mosque_receipt_yearly(r.year) : l10n.mosque_receipt_single,
                                              MosqueFormat.longDate(r.createdAt, lang),
                                            ].join(' · '),
                                            style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(MosqueFormat.money(r.amount), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    openingId.value == r.id
                                        ? const UICircularProgressBar(size: 16)
                                        : Icon(Icons.open_in_new, size: 16, color: UIColorsToken.textParagraph),
                                  ],
                                ),
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

/// "Get my document" — one row per (mosque, year) the donor gave to.
///
/// A tax receipt is offered only where the country actually has one, the
/// mosque holds the right, and the year is closed. Everywhere else the donor
/// is offered the neutral attestation instead of a button that would fail.
class _DonorRequestSection extends StatelessWidget {
  const _DonorRequestSection({
    required this.years,
    required this.l10n,
    required this.lang,
    required this.theme,
    required this.busyKey,
    required this.onRequest,
  });

  final List<MosqueDonationYear> years;
  final AppLocale l10n;
  final String lang;
  final UIThemeData theme;
  final String? busyKey;
  final Future<void> Function(MosqueDonationYear, {required bool taxReceipt}) onRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 12, kPageHorzPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mosque_receipts_request_title,
            style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
          ),
          const SizedBox(height: 8),
          for (final y in years) ...[
            Builder(
              builder: (_) {
                final tax = y.taxReceiptAvailable;
                final key = '${y.mosqueId}-${y.year}-$tax';
                final busy = busyKey == key;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: UIColorsToken.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${y.mosqueName} · ${y.year}',
                                style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                            const SizedBox(height: 2),
                            Text(
                              tax
                                  ? l10n.mosque_receipts_request_tax
                                  : (y.canIssue && y.regimeSupported && !y.isClosedYear
                                      ? l10n.mosque_receipts_request_wait_year
                                      : l10n.mosque_receipts_request_attestation_only),
                              style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      busy
                          ? const UICircularProgressBar(size: 16)
                          : UITap(
                              onTap: () => onRequest(y, taxReceipt: tax),
                              child: Text(
                                tax ? l10n.mosque_receipts_request_cta : l10n.mosque_receipts_request_cta_attestation,
                                style: theme.typo.inter.caption.copyWith(
                                  color: UIColorsToken.textYellow,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
