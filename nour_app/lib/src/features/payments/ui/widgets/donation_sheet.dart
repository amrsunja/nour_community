import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';

import '../../data/models/tx_enums.dart';
import '../state_management/donation_provider.dart';
import '../state_management/donation_state.dart';

/// Bottom sheet that runs a single-project donation / zakat payment. Zakat is
/// only offered when the project is `eligible_for_zakat`.
class DonationSheet extends HookConsumerWidget {
  const DonationSheet({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.currency,
    required this.eligibleForZakat,
  });

  final int projectId;
  final String projectTitle;
  final String currency;
  final bool eligibleForZakat;

  /// Returns `true` when a payment succeeded (so the caller can refresh).
  static Future<bool?> show(
    BuildContext context, {
    required int projectId,
    required String projectTitle,
    required String currency,
    required bool eligibleForZakat,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DonationSheet(
        projectId: projectId,
        projectTitle: projectTitle,
        currency: currency,
        eligibleForZakat: eligibleForZakat,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = UITheme.of(context);

    final amountCtrl = useTextEditingController();
    final amount = useState<double>(0);
    final coverFees = useState<bool>(false);
    final type = useState<TxType>(
      eligibleForZakat ? TxType.zakat : TxType.donation,
    );

    final state = ref.watch(donationProvider);
    final presenter = ref.read(donationProvider.notifier);

    // Pop with success once the webhook confirms.
    ref.listen<DonationState>(donationProvider, (prev, next) {
      if (next.phase == DonationPhase.success) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (context.mounted) Navigator.of(context).pop(true);
        });
      }
    });

    useEffect(() {
      void listener() {
        amount.value = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
      }

      amountCtrl.addListener(listener);
      return () => amountCtrl.removeListener(listener);
    }, const []);

    final fee = coverFees.value ? _estimateFee(amount.value) : 0.0;
    final charged = amount.value + fee;
    final canPay = amount.value > 0 && !state.isBusy;

    // Non-editable states (processing / success / failed) get a status view.
    if (state.phase == DonationPhase.processing ||
        state.phase == DonationPhase.success ||
        state.phase == DonationPhase.failed) {
      return _StatusView(state: state, l10n: l10n, onRetry: presenter.reset);
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
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
            const UISpace.vert(18),
            Text(
              l10n.donate_title,
              style: theme.typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(4),
            Text(
              projectTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(18),

            // Type — only when the project accepts zakat.
            if (eligibleForZakat) ...[
              UITabs<TxType>(
                selected: type.value,
                items: [
                  UITabItem(value: TxType.zakat, label: l10n.donate_type_zakat),
                  UITabItem(
                    value: TxType.donation,
                    label: l10n.donate_type_donation,
                  ),
                ],
                onChanged: (t) => type.value = t,
              ),
              const UISpace.vert(16),
            ],

            UIInputField(
              controller: amountCtrl,
              labelText: l10n.donate_amount_label(ImpactFormat.symbol(currency)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const UISpace.vert(8),

            // Quick amounts.
            Row(
              children: [
                for (final v in const [10, 25, 50, 100])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _QuickChip(
                      label: ImpactFormat.money(v.toDouble(), currency),
                      onTap: () => amountCtrl.text = '$v',
                    ),
                  ),
              ],
            ),
            const UISpace.vert(16),

            // Cover fees.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.donate_cover_fees,
                        style: theme.typo.inter.bodyMedium
                            .copyWith(color: UIColorsToken.white),
                      ),
                      if (coverFees.value && amount.value > 0)
                        Text(
                          l10n.donate_cover_fees_hint(
                            ImpactFormat.money(fee, currency),
                          ),
                          style: theme.typo.inter.bodySmall
                              .copyWith(color: UIColorsToken.textParagraph),
                        ),
                    ],
                  ),
                ),
                UIToggle(
                  checked: coverFees.value,
                  onCheck: (v) => coverFees.value = v,
                ),
              ],
            ),
            const UISpace.vert(20),

            UIButton.primary(
              label: amount.value > 0
                  ? l10n.donate_button(ImpactFormat.money(charged, currency))
                  : l10n.donate_button_empty,
              fullWidth: true,
              isBusy: state.isBusy,
              onTap: canPay
                  ? () {
                      FocusScope.of(context).unfocus();
                      presenter.pay(
                        type: eligibleForZakat ? type.value : TxType.donation,
                        currency: currency,
                        items: [
                          PaymentItem(
                            projectId: projectId,
                            amount: amount.value,
                          ),
                        ],
                        coverFees: coverFees.value,
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Matches the backend fee approximation (EU card): 1.5 % + 0.25.
  double _estimateFee(double amount) =>
      amount <= 0 ? 0 : (amount * 0.015 + 0.25);
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: typo.inter.bodySmall.copyWith(color: UIColorsToken.white),
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.state,
    required this.l10n,
    required this.onRetry,
  });

  final DonationState state;
  final AppLocale l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final (icon, iconColor, title, message) = switch (state.phase) {
      DonationPhase.success => (
        Icons.check_circle,
        UIColorsToken.greenAccent,
        l10n.donate_success_title,
        l10n.donate_success_message,
      ),
      DonationPhase.failed => (
        Icons.error_outline,
        UIColorsToken.red,
        l10n.donate_failed_title,
        l10n.donate_failed_message,
      ),
      _ => (
        Icons.hourglass_top,
        UIColorsToken.textYellow,
        l10n.donate_processing_title,
        l10n.donate_processing_message,
      ),
    };

    final isProcessing = state.phase == DonationPhase.processing;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing)
              const UICircularProgressBar()
            else
              Icon(icon, color: iconColor, size: 52),
            const UISpace.vert(16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(24),
            if (state.phase == DonationPhase.failed)
              UIButton.primary(
                label: l10n.common_retry,
                fullWidth: true,
                onTap: onRetry,
              )
            else if (state.phase == DonationPhase.success)
              UIButton.primary(
                label: l10n.common_done,
                fullWidth: true,
                onTap: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
  }
}
