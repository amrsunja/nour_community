import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../widgets/admin_campaign_actions.dart';
import '../widgets/admin_campaign_row.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// "Fundraising settings" (devis B3) — the campaigns' OWN configuration.
///
/// Campaigns used to borrow the Sadaqa card settings, which was wrong: a
/// campaign is a separate product with its own amounts, its own frequencies and
/// its own tax badge. This page edits the mosque-wide fundraising defaults a
/// new campaign is seeded from, and drives the campaigns already running
/// (extend / edit / post an update / close).
///
/// Saving here never rewrites a running campaign: a campaign keeps what it was
/// launched with until it is edited.
@RoutePage()
class MosqueAdminFundraisingSettingsPage extends HookConsumerWidget {
  const MosqueAdminFundraisingSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final canIssueReceipts = mosque?.canIssueTaxReceipts ?? false;

    final initial = state.campaignSettings ?? MosqueCampaignSettings(mosqueId: mosque?.id ?? 0);
    final draft = useState(initial);
    final amounts = useState<List<int>>(List.of(initial.amountsOrDefault));

    useEffect(() {
      if (!state.loaded) WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    // The row arrives asynchronously: hydrate the form once, without clobbering
    // what the admin has already changed.
    final hydrated = useRef(false);
    useEffect(() {
      final loaded = state.campaignSettings;
      if (!hydrated.value && loaded != null) {
        hydrated.value = true;
        draft.value = loaded;
        amounts.value = List.of(loaded.amountsOrDefault);
      }
      return null;
    }, [state.campaignSettings]);

    Future<void> save() async {
      final suggested = (amounts.value.where((a) => a > 0).toSet().toList()..sort()).take(kCampaignMaxAmounts).toList();
      if (suggested.isEmpty) {
        snackbar.showError(l10n.mosque_admin_fundraising_amounts_required);
        return;
      }
      if (draft.value.frequencies.isEmpty) {
        snackbar.showError(l10n.mosque_admin_sadaqa_frequency_required);
        return;
      }
      final ok = await presenter.saveCampaignSettings(draft.value.copyWith(suggestedAmounts: suggested));
      if (ok) {
        snackbar.showSuccess(l10n.mosque_admin_profile_saved);
        if (context.mounted) context.router.maybePop();
      }
    }

    final active = state.activeCampaigns;

    return Scaffold(
      appBar: UIAppBar(
        title: l10n.mosque_admin_fundraising_settings_title,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          SizedBox(
            height: 35,
            child: UIButton.primary(label: l10n.common_save, isSmall: true, isBusy: state.busy, onTap: save),
          ),
        ],
      ),
      body: state.isLoading && !state.loaded
          ? const Center(child: UICircularProgressBar())
          : RefreshIndicator(
              onRefresh: presenter.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
                children: [
                  // ── Active campaigns ───────────────────────────────────────
                  Row(
                    children: [
                      AdminLabel(l10n.mosque_admin_campaigns_active_title, muted: true),
                      const SizedBox(width: 8),
                      Padding(padding: const EdgeInsets.only(bottom: 12), child: AdminCountBadge(count: active.length)),
                      const Spacer(),
                      if (state.donationsReady && state.canCreateCampaign)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UIButton.primary(
                            label: l10n.mosque_admin_campaign_new_short,
                            assetIcon: UIIconsToken.icons.plus,
                            iconAxis: UIButtonIconAxis.leading,
                            isSmall: true,
                            onTap: () => nav.toMosqueAdminCampaignForm(),
                          ),
                        ),
                    ],
                  ),
                  if (active.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        l10n.mosque_admin_campaigns_empty,
                        style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ),
                  for (final c in active) ...[
                    AdminCampaignManageCard(campaign: c, onOpen: () => nav.toMosqueAdminCampaign(c.id)),
                    const SizedBox(height: 12),
                  ],
                  if (state.pastCampaigns.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    UIButton.textual(label: l10n.mosque_admin_all_campaigns, onTap: nav.toMosqueAdminCampaigns),
                  ],

                  // ── Suggested amounts ──────────────────────────────────────
                  const SizedBox(height: 24),
                  AdminLabel(l10n.mosque_admin_sadaqa_amounts, muted: true),
                  AdminAmountsEditor(
                    values: amounts.value,
                    onChanged: (v) => amounts.value = v,
                    addLabel: l10n.mosque_admin_sadaqa_add_amount,
                    maxItems: kCampaignMaxAmounts,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.mosque_admin_fundraising_amounts_hint,
                    style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                  ),

                  // ── Frequencies ────────────────────────────────────────────
                  const SizedBox(height: 24),
                  AdminLabel(l10n.mosque_admin_fundraising_frequencies, muted: true),
                  AdminToggleRow(
                    title: l10n.donate_frequency_one_time,
                    subtitle: l10n.mosque_admin_fundraising_one_time_hint,
                    value: draft.value.allowOneTime,
                    onChanged: (v) => draft.value = draft.value.copyWith(allowOneTime: v),
                  ),
                  const SizedBox(height: 8),
                  AdminToggleRow(
                    title: l10n.mosque_admin_fundraising_monthly,
                    subtitle: l10n.mosque_admin_fundraising_monthly_hint,
                    value: draft.value.allowMonthly,
                    onChanged: (v) => draft.value = draft.value.copyWith(allowMonthly: v),
                  ),
                  const SizedBox(height: 8),
                  AdminToggleRow(
                    title: l10n.mosque_admin_fundraising_yearly,
                    subtitle: l10n.mosque_admin_fundraising_yearly_hint,
                    value: draft.value.allowYearly,
                    onChanged: (v) => draft.value = draft.value.copyWith(allowYearly: v),
                  ),

                  // ── Tax badge ──────────────────────────────────────────────
                  const SizedBox(height: 24),
                  AdminLabel(l10n.mosque_admin_fundraising_tax_section, muted: true),
                  AdminToggleRow(
                    title: l10n.mosque_admin_sadaqa_tax_badge,
                    subtitle: canIssueReceipts ? l10n.mosque_admin_sadaqa_tax_badge_hint : l10n.mosque_admin_sadaqa_tax_badge_locked,
                    value: draft.value.showTaxBadge && canIssueReceipts,
                    enabled: canIssueReceipts,
                    onChanged: (v) => draft.value = draft.value.copyWith(showTaxBadge: v),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    l10n.mosque_admin_fundraising_defaults_note,
                    style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
    );
  }
}
