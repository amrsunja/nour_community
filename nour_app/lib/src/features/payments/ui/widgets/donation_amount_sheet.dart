import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';

import '../../data/fee_policy.dart';
import '../../data/models/tx_enums.dart';

/// What the donor picked in the "Donate how much?" sheet.
class DonationAmountSelection {
  const DonationAmountSelection({required this.amount, required this.frequency});

  final double amount;
  final DonationFrequency frequency;
}

/// Step 1 of the donation flow — the "Donate how much?" bottom sheet.
///
/// Pure UI: collects a frequency (Yearly / Monthly / One time) and an amount
/// (preset list or manual input) and returns a [DonationAmountSelection]; the
/// caller pushes the Checkout page. No money logic lives here.
class DonationAmountSheet extends HookConsumerWidget {
  const DonationAmountSheet({
    super.key,
    required this.currency,
    required this.presetAmounts,
    this.initialAmount,
    this.allowRecurring = true,
  });

  final String currency;
  final List<int> presetAmounts;

  /// Pre-selects an amount (tier tap on the project page).
  final double? initialAmount;

  /// Zakat is one-time only; the caller disables recurring in that case.
  final bool allowRecurring;

  static Future<DonationAmountSelection?> show(
    BuildContext context, {
    required String currency,
    required List<int> presetAmounts,
    double? initialAmount,
    bool allowRecurring = true,
  }) {
    return showModalBottomSheet<DonationAmountSelection>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DonationAmountSheet(
        currency: currency,
        presetAmounts: presetAmounts,
        initialAmount: initialAmount,
        allowRecurring: allowRecurring,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;

    final frequency = useState<DonationFrequency>(DonationFrequency.oneTime);
    final presets = presetAmounts.isEmpty ? const [10, 50, 100, 150] : presetAmounts;

    // Either a preset (index) or a manual amount is "selected" — never both.
    final selectedPreset = useState<int?>(
      initialAmount != null && presets.contains(initialAmount!.round())
          ? initialAmount!.round()
          : null,
    );
    final manualCtrl = useTextEditingController(
      text: initialAmount != null && !presets.contains(initialAmount!.round())
          ? _fmt(initialAmount!)
          : '',
    );
    final manualAmount = useState<double>(
      double.tryParse(manualCtrl.text.replaceAll(',', '.')) ?? 0,
    );

    useEffect(() {
      void listener() {
        final v = double.tryParse(manualCtrl.text.replaceAll(',', '.')) ?? 0;
        manualAmount.value = v;
        if (v > 0) selectedPreset.value = null;
      }

      manualCtrl.addListener(listener);
      return () => manualCtrl.removeListener(listener);
    }, const []);

    final amount = selectedPreset.value?.toDouble() ?? manualAmount.value;
    final canContinue = amount >= FeePolicy.minAmount && amount <= FeePolicy.maxAmount;

    void pickPreset(int v) {
      selectedPreset.value = v;
      if (manualCtrl.text.isNotEmpty) manualCtrl.clear();
      FocusScope.of(context).unfocus();
    }

    String amountLabel(int v) {
      final money = ImpactFormat.money(v.toDouble(), currency);
      return switch (frequency.value) {
        DonationFrequency.monthly => l10n.donate_per_month(money),
        DonationFrequency.yearly => l10n.donate_per_year(money),
        DonationFrequency.oneTime => money,
      };
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: UIColorsToken.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const UISpace.vert(22),

            // Frequency
            if (allowRecurring) ...[
              Row(
                children: [
                  for (final f in DonationFrequency.values) ...[
                    Expanded(
                      child: _FrequencyChip(
                        label: switch (f) {
                          DonationFrequency.yearly => l10n.donate_frequency_yearly,
                          DonationFrequency.monthly => l10n.donate_frequency_monthly,
                          DonationFrequency.oneTime => l10n.donate_frequency_one_time,
                        },
                        selected: frequency.value == f,
                        onTap: () => frequency.value = f,
                      ),
                    ),
                    if (f != DonationFrequency.values.last) const UISpace.horz(10),
                  ],
                ],
              ),
              const UISpace.vert(26),
            ],

            Text(
              l10n.donate_how_much,
              style: typo.inter.title.copyWith(
                color: UIColorsToken.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const UISpace.vert(16),

            // Presets
            for (final v in presets) ...[
              _AmountTile(
                label: amountLabel(v),
                selected: selectedPreset.value == v,
                onTap: () => pickPreset(v),
              ),
              const UISpace.vert(10),
            ],

            const UISpace.vert(4),
            Row(
              children: [
                Expanded(child: Divider(color: UIColorsToken.stroke, thickness: 0.6)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    l10n.donate_or,
                    style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ),
                Expanded(child: Divider(color: UIColorsToken.stroke, thickness: 0.6)),
              ],
            ),
            const UISpace.vert(14),

            // Manual amount
            UIInputField(
              controller: manualCtrl,
              hintText: l10n.donate_enter_manually,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(8),
              ],
            ),
            const UISpace.vert(18),

            UIButton.primary(
              label: l10n.donate_checkout,
              fullWidth: true,
              onTap: canContinue
                  ? () => Navigator.of(context).pop(
                        DonationAmountSelection(
                          amount: amount,
                          frequency: allowRecurring
                              ? frequency.value
                              : DonationFrequency.oneTime,
                        ),
                      )
                  : null,
            ),
            const UISpace.vert(12),
            Text(
              l10n.donate_footer_partners,
              textAlign: TextAlign.center,
              style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
            ),
            Text(
              l10n.donate_footer_transparent,
              textAlign: TextAlign.center,
              style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? UIColorsToken.bgPriYellow : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : UIColorsToken.stroke,
            width: 1,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typo.inter.title.copyWith(
            color: selected ? UIColorsToken.black : UIColorsToken.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xff252219) : UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? UIColorsToken.textYellow : Colors.transparent,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: typo.inter.title.copyWith(
            color: selected ? UIColorsToken.textYellow : UIColorsToken.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
