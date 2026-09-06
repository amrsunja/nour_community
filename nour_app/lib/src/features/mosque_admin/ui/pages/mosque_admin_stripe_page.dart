import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// Stripe Connect (Express) onboarding & status — devis B1.
///
/// The hosted onboarding runs in the browser; when the app resumes we sync
/// the account status (`action: 'status'`), which also flips
/// `mosques.donations_enabled` server-side.
@RoutePage()
class MosqueAdminStripePage extends HookConsumerWidget {
  const MosqueAdminStripePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final taxReceipts = useState(mosque?.canIssueTaxReceipts ?? false);
    final launched = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.refresh(syncStripe: true));
      return null;
    }, const []);

    // Back from the Stripe hosted flow → sync.
    useOnAppLifecycleStateChange((_, current) {
      if (current == AppLifecycleState.resumed && launched.value) {
        launched.value = false;
        presenter.refresh(syncStripe: true);
      }
    });

    Future<void> start() async {
      final url = await presenter.startStripeOnboarding(canIssueTaxReceipts: taxReceipts.value);
      if (url == null) return;
      launched.value = true;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    final acct = state.stripe;
    final (statusLabel, statusColor) = switch (acct.status) {
      MosqueStripeStatus.enabled => (l10n.mosque_admin_stripe_status_enabled, UIColorsToken.green),
      MosqueStripeStatus.pending => (l10n.mosque_admin_stripe_status_pending, UIColorsToken.yellow),
      MosqueStripeStatus.restricted => (l10n.mosque_admin_stripe_status_restricted, UIColorsToken.red),
      MosqueStripeStatus.rejected => (l10n.mosque_admin_stripe_status_rejected, UIColorsToken.red),
      MosqueStripeStatus.notStarted => (l10n.mosque_admin_stripe_status_not_started, UIColorsToken.textParagraph),
    };

    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: l10n.mosque_admin_stripe_title, onBack: () => context.router.maybePop()),
      body: state.isLoading && !state.loaded
          ? const Center(child: UICircularProgressBar())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UICard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                            const SizedBox(width: 8),
                            Text(statusLabel, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            if (state.isLoading) const UICircularProgressBar(size: 16),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _Row(l10n.mosque_admin_stripe_charges, acct.chargesEnabled),
                        _Row(l10n.mosque_admin_stripe_payouts, acct.payoutsEnabled),
                        _Row(l10n.mosque_admin_stripe_details, acct.detailsSubmitted),
                        if (acct.currentlyDue.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(l10n.mosque_admin_stripe_requirements, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                          const SizedBox(height: 4),
                          for (final r in acct.currentlyDue.take(8))
                            Text('• ${r.replaceAll('_', ' ').replaceAll('.', ' › ')}', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.mosque_admin_stripe_explainer, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                  const SizedBox(height: 16),
                  if (!acct.hasAccount)
                    AdminToggleRow(
                      title: l10n.mosque_admin_stripe_tax_receipts,
                      subtitle: l10n.mosque_admin_stripe_tax_receipts_hint,
                      value: taxReceipts.value,
                      onChanged: (v) => taxReceipts.value = v,
                    ),
                  const SizedBox(height: 16),
                  if (!acct.chargesEnabled)
                    UIButton.primary(
                      label: acct.hasAccount ? l10n.mosque_admin_stripe_continue : l10n.mosque_admin_stripe_start,
                      fullWidth: true,
                      isBusy: state.busy,
                      onTap: start,
                    )
                  else ...[
                    if (acct.dashboardUrl != null)
                      UIButton.primary(
                        label: l10n.mosque_admin_stripe_dashboard,
                        fullWidth: true,
                        onTap: () => launchUrl(Uri.parse(acct.dashboardUrl!), mode: LaunchMode.externalApplication),
                      ),
                    if (acct.currentlyDue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      UIButton.secondary(label: l10n.mosque_admin_stripe_update_info, fullWidth: true, isBusy: state.busy, onTap: start),
                    ],
                  ],
                  const SizedBox(height: 8),
                  UIButton.textual(label: l10n.common_refresh, fullWidth: true, onTap: () => presenter.refresh(syncStripe: true)),
                ],
              ),
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.ok);
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: ok ? UIColorsToken.green : UIColorsToken.textParagraph),
          const SizedBox(width: 8),
          Text(label, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white)),
        ],
      ),
    );
  }
}
