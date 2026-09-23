import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// Version of the legal text the admin accepts in the declaration dialog.
/// Bump it whenever that wording changes: it is stored on every
/// `mosque_tax_declarations` row and is what proves WHAT was accepted.
const kTaxDeclarationVersion = 'fr-cgi-200-v1';

/// Tax receipts — the right, the issuer data it requires, and the signatory.
///
/// Deliberately NOT part of the Stripe page: the right to issue a tax receipt
/// is a legal attribute of the association, not a payments setting, and tying
/// it to onboarding is what left mosques unable to enable it afterwards.
/// See docs/TAX_RECEIPTS_MULTI_COUNTRY.md
@RoutePage()
class MosqueAdminTaxSettingsPage extends HookConsumerWidget {
  const MosqueAdminTaxSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final repo = ref.read(mosqueRepoProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final readiness = state.taxReadiness;

    final signatoryName = useTextEditingController(text: mosque?.signatoryName ?? '');
    final signatoryRole = useTextEditingController(text: mosque?.signatoryRole ?? '');
    final signatureUrl = useState<String?>(null);

    useEffect(() {
      if (!state.loaded) WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    // The signature lives in a private bucket: it needs a signed URL to preview.
    useEffect(() {
      final path = mosque?.signaturePath;
      if (path == null || path.isEmpty) {
        signatureUrl.value = null;
        return null;
      }
      repo.signatureUrl(path).then((u) => signatureUrl.value = u);
      return null;
    }, [mosque?.signaturePath]);

    Future<void> pickSignature() async {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 92);
      if (x == null) return;
      final ok = await presenter.uploadSignature(
        File(x.path),
        name: signatoryName.text.trim().isEmpty ? null : signatoryName.text.trim(),
        role: signatoryRole.text.trim().isEmpty ? null : signatoryRole.text.trim(),
      );
      if (ok) snackbar.showSuccess(l10n.mosque_admin_tax_signature_saved);
    }

    Future<void> saveSignatory() async {
      final ok = await presenter.saveSignatory(
        name: signatoryName.text.trim().isEmpty ? null : signatoryName.text.trim(),
        role: signatoryRole.text.trim().isEmpty ? null : signatoryRole.text.trim(),
      );
      if (ok) snackbar.showSuccess(l10n.mosque_admin_profile_saved);
    }

    Future<void> toggle(bool value) async {
      if (value) {
        final accepted = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: UIColorsToken.bgSurface,
            title: Text(l10n.mosque_admin_tax_declaration_title, style: const TextStyle(color: UIColorsToken.white)),
            content: SingleChildScrollView(
              child: Text(
                l10n.mosque_admin_tax_declaration_body,
                style: TextStyle(color: UIColorsToken.textParagraph),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.common_cancel)),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.mosque_admin_tax_declaration_confirm,
                    style: const TextStyle(color: UIColorsToken.green)),
              ),
            ],
          ),
        );
        if (accepted != true) return;
      }
      final ok = await presenter.setTaxReceipts(value, declarationVersion: kTaxDeclarationVersion);
      if (ok) {
        snackbar.showSuccess(value ? l10n.mosque_admin_tax_enabled : l10n.mosque_admin_tax_disabled);
      }
    }

    return Scaffold(
      appBar: UIAppBar(title: l10n.mosque_admin_tax_title, onBack: () => context.router.maybePop()),
      body: state.isLoading && !state.loaded
          ? const Center(child: UICircularProgressBar())
          : RefreshIndicator(
              onRefresh: presenter.refreshTaxReadiness,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
                children: [
                  _RegimeCard(readiness: readiness, l10n: l10n),
                  const SizedBox(height: 20),

                  if (readiness?.supported == true && readiness?.regimeKind == 'receipt') ...[
                    AdminLabel(l10n.mosque_admin_tax_checklist, muted: true),
                    _Checklist(
                      readiness: readiness!,
                      l10n: l10n,
                      onFixProfile: () => context.router.push(const MosqueAdminEditProfileRoute()),
                    ),
                    const SizedBox(height: 24),

                    // ── Signatory ──────────────────────────────────────────
                    AdminLabel(l10n.mosque_admin_tax_signatory, muted: true),
                    Text(
                      l10n.mosque_admin_tax_signatory_hint,
                      style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                    ),
                    const SizedBox(height: 10),
                    UIInputField(controller: signatoryName, hintText: l10n.mosque_admin_tax_signatory_name),
                    const SizedBox(height: 10),
                    UIInputField(controller: signatoryRole, hintText: l10n.mosque_admin_tax_signatory_role),
                    const SizedBox(height: 12),
                    _SignatureBox(
                      url: signatureUrl.value,
                      label: l10n.mosque_admin_tax_signature,
                      emptyLabel: l10n.mosque_admin_tax_signature_add,
                      onTap: pickSignature,
                    ),
                    const SizedBox(height: 12),
                    UIButton.secondary(
                      label: l10n.common_save,
                      fullWidth: true,
                      isBusy: state.busy,
                      onTap: saveSignatory,
                    ),
                    const SizedBox(height: 24),

                    // ── The right itself ───────────────────────────────────
                    AdminLabel(l10n.mosque_admin_tax_right_section, muted: true),
                    AdminToggleRow(
                      title: l10n.mosque_admin_tax_right,
                      subtitle: readiness.canToggle
                          ? l10n.mosque_admin_tax_right_hint
                          : l10n.mosque_admin_tax_right_blocked,
                      value: readiness.enabled,
                      enabled: readiness.canToggle && !state.busy,
                      onChanged: toggle,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.mosque_admin_tax_liability,
                      style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                    ),

                    if (readiness.enabled) ...[
                      const SizedBox(height: 24),
                      UIButton.textual(
                        label: l10n.mosque_admin_receipts,
                        fullWidth: true,
                        onTap: nav.toMosqueAdminReceipts,
                      ),
                      _YearSummary(l10n: l10n),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}

/// What the country allows. Three mutually exclusive states, and each one is
/// an answer the admin can act on rather than a silent disabled switch.
class _RegimeCard extends StatelessWidget {
  const _RegimeCard({required this.readiness, required this.l10n});
  final MosqueTaxReadiness? readiness;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final r = readiness;

    final String title;
    final String body;
    final Color color;
    if (r == null) {
      title = l10n.mosque_admin_tax_regime_checking;
      body = '';
      color = UIColorsToken.textParagraph;
    } else if (r.supported && r.regimeKind == 'receipt') {
      title = l10n.mosque_admin_tax_regime_available;
      body = r.legalRef ?? '';
      color = UIColorsToken.green;
    } else if (r.notReceiptBased) {
      // UK-style: the relief is reclaimed by the charity, there is no receipt.
      title = l10n.mosque_admin_tax_regime_not_receipt_based;
      body = l10n.mosque_admin_tax_regime_not_receipt_based_hint;
      color = UIColorsToken.yellow;
    } else {
      title = l10n.mosque_admin_tax_regime_unavailable;
      body = l10n.mosque_admin_tax_regime_unavailable_hint;
      color = UIColorsToken.yellow;
    }

    return UICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
              ),
              if (r != null)
                Text(r.country, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(body, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
          ],
          if (r?.templateKey != null) ...[
            const SizedBox(height: 6),
            Text(r!.templateKey!,
                style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          ],
        ],
      ),
    );
  }
}

/// Every blocker the server would refuse on, spelled out.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.readiness, required this.l10n, required this.onFixProfile});
  final MosqueTaxReadiness readiness;
  final AppLocale l10n;
  final VoidCallback onFixProfile;

  String _label(TaxBlocker b) => switch (b) {
        TaxBlocker.mosqueNotApproved => l10n.mosque_admin_tax_blocker_not_approved,
        TaxBlocker.legalName => l10n.mosque_admin_tax_blocker_legal_name,
        TaxBlocker.addressLine || TaxBlocker.postalCode || TaxBlocker.city =>
          l10n.mosque_admin_tax_blocker_address,
        TaxBlocker.legalId => l10n.mosque_admin_tax_blocker_legal_id,
        TaxBlocker.signatory => l10n.mosque_admin_tax_blocker_signatory,
        TaxBlocker.unknown => l10n.mosque_admin_tax_blocker_unknown,
      };

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final blockers = readiness.blockers.toSet().toList();

    if (blockers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 18, color: UIColorsToken.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l10n.mosque_admin_tax_checklist_ok,
                  style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final b in blockers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked, size: 18, color: UIColorsToken.yellow),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_label(b),
                        style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white)),
                  ),
                  // Legal identifiers are a Nour-admin column: the mosque
                  // cannot fix that one itself, so no action is offered.
                  if (b != TaxBlocker.legalId && b != TaxBlocker.signatory && b != TaxBlocker.mosqueNotApproved)
                    UITap(
                      onTap: onFixProfile,
                      child: Text(l10n.common_edit,
                          style: theme.typo.inter.caption
                              .copyWith(color: UIColorsToken.textYellow, decoration: TextDecoration.underline)),
                    ),
                ],
              ),
            ),
          ),
        if (blockers.contains(TaxBlocker.legalId))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.mosque_admin_tax_blocker_legal_id_hint,
                style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          ),
      ],
    );
  }
}

class _SignatureBox extends StatelessWidget {
  const _SignatureBox({required this.url, required this.label, required this.emptyLabel, required this.onTap});
  final String? url;
  final String label;
  final String emptyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIColorsToken.bgSurface),
        ),
        alignment: Alignment.center,
        child: url == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.draw_outlined, color: UIColorsToken.textParagraph),
                  const SizedBox(height: 6),
                  Text(emptyLabel,
                      style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(url!, fit: BoxFit.contain),
              ),
      ),
    );
  }
}

/// Totals for the annual filing (France: form 2070-SD).
class _YearSummary extends HookConsumerWidget {
  const _YearSummary({required this.l10n});
  final AppLocale l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final year = DateTime.now().year - 1;
    final summary = useState<MosqueTaxYearSummary?>(null);

    useEffect(() {
      presenter.taxYearSummary(year).then((v) => summary.value = v);
      return null;
    }, const []);

    final s = summary.value;
    if (s == null || s.receiptsCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mosque_admin_tax_summary_title(year),
                style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
            const SizedBox(height: 6),
            Text(
              l10n.mosque_admin_tax_summary_body(s.receiptsCount, s.donorsCount, s.total.toStringAsFixed(2)),
              style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
        ),
      ),
    );
  }
}
