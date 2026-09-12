import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_donation_widgets.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// "Sadaqa settings" (devis B2): title, description, suggested amounts,
/// frequencies, tax badge, membership fee amounts.
@RoutePage()
class MosqueAdminSadaqaSettingsPage extends HookConsumerWidget {
  const MosqueAdminSadaqaSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final feeFlag = ref.watch(appConfigProvider.select((c) => c.mosqueMembershipFeeEnabled));

    final initial = state.settings ?? MosqueDonationSettings(mosqueId: mosque?.id ?? 0);
    final draft = useState(initial);
    final title = useTextEditingController(text: initial.title);
    final description = useTextEditingController(text: initial.description ?? '');
    final amounts = useTextEditingController(text: initial.suggestedAmounts.join(', '));
    final fees = useTextEditingController(text: initial.membershipFeeAmounts.join(', '));
    useListenable(title);
    useListenable(amounts);

    useEffect(() {
      if (!state.loaded) WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    List<int> parseAmounts(String s) => s
        .split(RegExp(r'[,\s;]+'))
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .where((e) => e > 0)
        .toSet()
        .toList()
      ..sort();

    Future<void> save() async {
      final suggested = parseAmounts(amounts.text);
      final feeAmounts = parseAmounts(fees.text);
      if (title.text.trim().isEmpty || suggested.isEmpty) {
        snackbar.showError(l10n.mosque_admin_sadaqa_invalid);
        return;
      }
      if (!draft.value.allowOneTime && !draft.value.allowMonthly && !draft.value.allowYearly) {
        snackbar.showError(l10n.mosque_admin_sadaqa_frequency_required);
        return;
      }
      final ok = await presenter.saveSettings(draft.value.copyWith(
        title: title.text.trim(),
        description: description.text.trim(),
        suggestedAmounts: suggested.take(6).toList(),
        membershipFeeAmounts: feeAmounts.isEmpty ? const [60, 120, 240] : feeAmounts.take(6).toList(),
      ));
      if (ok) {
        snackbar.showSuccess(l10n.mosque_admin_profile_saved);
        if (context.mounted) context.router.maybePop();
      }
    }

    return Scaffold(
      appBar: UIAppBar(
        title: l10n.mosque_admin_sadaqa_settings_title,
        onBack: () => context.router.maybePop(),
        leadingIcons: [UIButton.primary(label: l10n.common_save, isSmall: true, isBusy: state.busy, onTap: save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminLabel(l10n.mosque_admin_sadaqa_card_title),
            UIInputField(controller: title, hintText: l10n.mosque_admin_sadaqa_card_title_hint),
            const SizedBox(height: 16),
            AdminLabel(l10n.mosque_post_description, optional: true, l10n: l10n),
            AdminTextArea(controller: description, hint: l10n.mosque_admin_sadaqa_description_hint, minLines: 2, maxLines: 5),
            const SizedBox(height: 16),
            AdminLabel(l10n.mosque_admin_sadaqa_amounts),
            UIInputField(
              controller: amounts,
              hintText: '10, 50, 100, 150',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\s]'))],
            ),
            const SizedBox(height: 4),
            Text(l10n.mosque_admin_sadaqa_amounts_hint, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 20),
            AdminLabel(l10n.mosque_admin_sadaqa_frequencies),
            AdminToggleRow(title: l10n.donate_frequency_one_time, value: draft.value.allowOneTime, onChanged: (v) => draft.value = draft.value.copyWith(allowOneTime: v)),
            const SizedBox(height: 8),
            AdminToggleRow(title: l10n.donate_frequency_monthly, value: draft.value.allowMonthly, onChanged: (v) => draft.value = draft.value.copyWith(allowMonthly: v)),
            const SizedBox(height: 8),
            AdminToggleRow(title: l10n.donate_frequency_yearly, value: draft.value.allowYearly, onChanged: (v) => draft.value = draft.value.copyWith(allowYearly: v)),
            const SizedBox(height: 20),
            AdminToggleRow(
              title: l10n.mosque_admin_sadaqa_tax_badge,
              subtitle: (mosque?.canIssueTaxReceipts ?? false) ? l10n.mosque_admin_sadaqa_tax_badge_hint : l10n.mosque_admin_sadaqa_tax_badge_locked,
              value: draft.value.showTaxBadge && (mosque?.canIssueTaxReceipts ?? false),
              enabled: mosque?.canIssueTaxReceipts ?? false,
              onChanged: (v) => draft.value = draft.value.copyWith(showTaxBadge: v),
            ),
            if (feeFlag) ...[
              const SizedBox(height: 24),
              AdminLabel(l10n.mosque_admin_membership_fee_amounts),
              UIInputField(
                controller: fees,
                hintText: '60, 120, 240',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\s]'))],
              ),
              const SizedBox(height: 4),
              Text(l10n.mosque_admin_membership_fee_amounts_hint, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            ],
            const SizedBox(height: 24),
            AdminLabel(l10n.mosque_admin_preview),
            UICard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title.text.isEmpty ? initial.title : title.text, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600))),
                      if (draft.value.showTaxBadge && (mosque?.canIssueTaxReceipts ?? false)) MosqueTaxBadge(l10n: l10n),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [for (final a in parseAmounts(amounts.text)) MosqueChip(label: '$a€', selected: false, dense: true)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
