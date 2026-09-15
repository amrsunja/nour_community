import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import '../../data/models/mosque_donation_models.dart';
import 'mosque_format.dart';

/// French donation tax-deduction rate (CGI art. 200). Shown under the CTA when
/// the mosque issues tax receipts and the admin enabled the badge.
const int kMosqueTaxDeductiblePercent = 66;

/// The Sadaqa card (devis B2) — the single source of truth for this UI.
/// Rendered live on the worshipper donation tab and, with [interactive] off,
/// as the preview inside the mosque admin "Sadaqa settings" page.
class MosqueSadaqaCard extends StatefulWidget {
  const MosqueSadaqaCard({
    super.key,
    required this.l10n,
    required this.settings,
    required this.canIssueTaxReceipts,
    required this.frequency,
    required this.amount,
    this.onFrequencyChanged,
    this.onAmountChanged,
    this.onDonate,
    this.busy = false,
    this.banner,
    this.interactive = true,
    this.symbol = '€',
    this.taxPercent = kMosqueTaxDeductiblePercent,
  });

  final AppLocale l10n;
  final MosqueDonationSettings settings;
  final bool canIssueTaxReceipts;
  final DonationFrequency frequency;
  final double amount;
  final ValueChanged<DonationFrequency>? onFrequencyChanged;
  final ValueChanged<double>? onAmountChanged;
  final VoidCallback? onDonate;
  final bool busy;

  /// Optional row shown under the description (e.g. the active recurring gift).
  final Widget? banner;

  /// `false` renders a non-tappable preview (admin settings page).
  final bool interactive;
  final String symbol;
  final int taxPercent;

  @override
  State<MosqueSadaqaCard> createState() => _MosqueSadaqaCardState();
}

class _MosqueSadaqaCardState extends State<MosqueSadaqaCard> {
  late final TextEditingController _manual;

  @override
  void initState() {
    super.initState();
    _manual = TextEditingController(text: _isPreset(widget.amount) ? '' : _asText(widget.amount));
  }

  @override
  void didUpdateWidget(covariant MosqueSadaqaCard old) {
    super.didUpdateWidget(old);
    // A preset chip was tapped elsewhere → clear the manual field.
    if (widget.amount != old.amount && _isPreset(widget.amount) && _manual.text.isNotEmpty) {
      _manual.clear();
    }
  }

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  bool _isPreset(double v) => widget.settings.suggestedAmounts.contains(v.round());
  static String _asText(double v) => v <= 0 ? '' : v.round().toString();

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = widget.l10n;
    final s = widget.settings;
    final frequencies = s.frequencies;
    final showTax = s.showTaxBadge && widget.canIssueTaxReceipts;
    final manualActive = _manual.text.trim().isNotEmpty;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          //border: Border.all(color: UIColorsToken.white.withValues(alpha: .06)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Soft gold glow in the top-right corner.
            Positioned(
              top: -90,
              right: -70,
              child: IgnorePointer(
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        UIColorsToken.yellow.withValues(alpha: .10),
                        UIColorsToken.yellow.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.title,
                    style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
                  ),
                  if (s.description != null && s.description!.trim().isNotEmpty) ...[
                    const UISpace.vert(10),
                    Text(
                      s.description!.trim(),
                      style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph, height: 1.35),
                    ),
                  ],
                  if (widget.banner != null) ...[
                    const UISpace.vert(14),
                    widget.banner!,
                  ],
                  if (frequencies.length > 1) ...[
                    const UISpace.vert(22),
                    _FrequencyRow(
                      l10n: l10n,
                      frequencies: frequencies,
                      selected: widget.frequency,
                      onChanged: widget.onFrequencyChanged,
                    ),
                  ],
                  if (s.suggestedAmounts.isNotEmpty) ...[
                    const UISpace.vert(12),
                    _AmountGrid(
                      amounts: s.suggestedAmounts,
                      symbol: widget.symbol,
                      selected: manualActive ? null : widget.amount.round(),
                      onTap: (v) {
                        _manual.clear();
                        widget.onAmountChanged?.call(v.toDouble());
                      },
                    ),
                  ],
                  const UISpace.vert(14),
                  _OrDivider(label: l10n.mosque_donation_or),
                  const UISpace.vert(14),
                  _ManualAmountField(
                    controller: _manual,
                    hint: l10n.mosque_donation_manual_amount_hint,
                    symbol: widget.symbol,
                    onChanged: (v) {
                      setState(() {});
                      final n = double.tryParse(v.trim());
                      if (n != null && n > 0) widget.onAmountChanged?.call(n);
                    },
                  ),
                  const UISpace.vert(18),
                  UIButton.primary(
                    label: _ctaLabel(),
                    fullWidth: true,
                    isBusy: widget.busy,
                    onTap: widget.amount > 0 ? widget.onDonate : null,
                  ),
                  const UISpace.vert(10),
                  Center(
                    child: Text(
                      showTax
                          ? l10n.mosque_donation_tax_deductible('${widget.taxPercent}')
                          : l10n.mosque_donation_secure_note,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.interactive) return card;
    return IgnorePointer(child: card);
  }

  String _ctaLabel() {
    final l10n = widget.l10n;
    if (widget.amount <= 0) return l10n.mosque_donation_give_to_mosque;
    final money = MosqueFormat.money(widget.amount);
    return switch (widget.frequency) {
      DonationFrequency.oneTime => l10n.mosque_donation_give(money),
      DonationFrequency.monthly => l10n.mosque_donation_give_monthly(money),
      DonationFrequency.yearly => l10n.mosque_donation_give_yearly(money),
    };
  }
}

/// Two (or three) large outlined frequency boxes, monthly carrying a "Popular"
/// badge that straddles its top border.
class _FrequencyRow extends StatelessWidget {
  const _FrequencyRow({required this.l10n, required this.frequencies, required this.selected, this.onChanged});

  final AppLocale l10n;
  final List<DonationFrequency> frequencies;
  final DonationFrequency selected;
  final ValueChanged<DonationFrequency>? onChanged;

  String _label(DonationFrequency f) => switch (f) {
        DonationFrequency.oneTime => l10n.donate_frequency_one_time,
        DonationFrequency.monthly => l10n.donate_frequency_monthly,
        DonationFrequency.yearly => l10n.donate_frequency_yearly,
      };

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final showPopular = frequencies.contains(DonationFrequency.monthly) && frequencies.length > 1;

    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Row(
        children: [
          for (var i = 0; i < frequencies.length; i++) ...[
            if (i > 0) const UISpace.horz(14),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  UITap(
                    onTap: onChanged == null ? null : () => onChanged!(frequencies[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      padding: .symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selected == frequencies[i] ? UIColorsToken.yellow.withValues(alpha: .08) : Colors.transparent,
                        border: Border.all(
                          color: selected == frequencies[i]
                              ? UIColorsToken.yellow.withValues(alpha: .85)
                              : UIColorsToken.white.withValues(alpha: .22),
                          width: selected == frequencies[i] ? 1 : 0.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _label(frequencies[i]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  if (showPopular && frequencies[i] == DonationFrequency.monthly)
                    Positioned(
                      top: -11,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: UIColorsToken.bgPriYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.mosque_donation_popular,
                          style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Preset amounts, four per row.
class _AmountGrid extends StatelessWidget {
  const _AmountGrid({required this.amounts, required this.symbol, required this.selected, required this.onTap});

  final List<int> amounts;
  final String symbol;
  final int? selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    const gap = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = math.max(1, math.min(4, amounts.length));
        final width = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final a in amounts)
              SizedBox(
                width: width,
                child: UITap(
                  onTap: () => onTap(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: selected == a
                          ? UIColorsToken.yellow.withValues(alpha: .14)
                          : UIColorsToken.white.withValues(alpha: .04),
                      border: Border.all(
                        color: selected == a ? UIColorsToken.yellow.withValues(alpha: .85) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '$a$symbol',
                          style: theme.typo.inter.title.copyWith(
                            color: selected == a ? UIColorsToken.textYellow : UIColorsToken.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final line = Expanded(child: Container(height: 1, color: UIColorsToken.white.withValues(alpha: .12)));
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
        ),
        line,
      ],
    );
  }
}

class _ManualAmountField extends StatelessWidget {
  const _ManualAmountField({required this.controller, required this.hint, required this.symbol, required this.onChanged});

  final TextEditingController controller;
  final String hint;
  final String symbol;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: UIColorsToken.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        cursorColor: UIColorsToken.textYellow,
        style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: theme.typo.inter.title.copyWith(color: UIColorsToken.textParagraph, fontWeight: FontWeight.w400),
          suffixText: controller.text.isEmpty ? null : symbol,
          suffixStyle: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
