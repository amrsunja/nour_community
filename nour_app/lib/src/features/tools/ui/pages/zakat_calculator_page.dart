import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/enums/currency_type.dart';

import '../state_management/zakat_calculator_provider.dart';
import '../state_management/zakat_calculator_state.dart';

@RoutePage()
class ZakatCalculatorPage extends HookConsumerWidget {
  const ZakatCalculatorPage({super.key});

  /// Formats a monetary value in the active currency (symbol suffixed).
  static String money(double value, String lang, CurrencyType currency) {
    final f = NumberFormat.decimalPattern(lang)
      ..maximumFractionDigits = value % 1 == 0 ? 0 : 2;
    return '${f.format(value)}${currency.symbol}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(zakatCalculatorProvider.notifier);
    final state = ref.watch(zakatCalculatorProvider);
    final currency = state.currency;

    // One controller per editable field.
    final goldCtrl = useTextEditingController();
    final silverCtrl = useTextEditingController();
    final otherCtrl = useTextEditingController();
    final cashCtrl = useTextEditingController();
    final savingsCtrl = useTextEditingController();
    final investmentsCtrl = useTextEditingController();
    final loansCtrl = useTextEditingController();
    final personalDebtsCtrl = useTextEditingController();
    final billsCtrl = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    void onReset() {
      for (final c in [
        goldCtrl,
        silverCtrl,
        otherCtrl,
        cashCtrl,
        savingsCtrl,
        investmentsCtrl,
        loansCtrl,
        personalDebtsCtrl,
        billsCtrl,
      ]) {
        c.clear();
      }
      presenter.reset();
    }

    return UIGradientLinedScaffold(
      bgArabicText: 'الزكاة',
      appBar: UIAppBar(title: l10n.zakat_title, onBack: context.pop),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CurrencySelector(
                selected: currency,
                onSelected: presenter.setCurrency,
              ),
              const SizedBox(height: 16),
              UIAppearAnimation(
                child: _SummaryCard(
                  l10n: l10n,
                  lang: lang,
                  currency: currency,
                  state: state,
                  onReset: onReset,
                  onGive: () {}, // Implemented later by the app owner.
                ),
              ),
              const SizedBox(height: 24),
              _Section(title: l10n.zakat_section_precious_metals),
              _ZakatField(
                label: l10n.zakat_field_gold,
                currency: currency,
                controller: goldCtrl,
                onChanged: presenter.setGold,
              ),
              _ZakatField(
                label: l10n.zakat_field_silver,
                currency: currency,
                controller: silverCtrl,
                onChanged: presenter.setSilver,
              ),
              _ZakatField(
                label: l10n.zakat_field_other,
                currency: currency,
                controller: otherCtrl,
                onChanged: presenter.setOther,
              ),
              _Section(title: l10n.zakat_section_cash),
              _ZakatField(
                label: l10n.zakat_field_cash,
                currency: currency,
                controller: cashCtrl,
                onChanged: presenter.setCash,
              ),
              _ZakatField(
                label: l10n.zakat_field_savings,
                currency: currency,
                controller: savingsCtrl,
                onChanged: presenter.setSavings,
              ),
              _Section(title: l10n.zakat_section_investments),
              _ZakatField(
                label: l10n.zakat_field_investments,
                currency: currency,
                controller: investmentsCtrl,
                onChanged: presenter.setInvestments,
              ),
              _ZakatField(
                label: l10n.zakat_field_loans_given,
                currency: currency,
                controller: loansCtrl,
                onChanged: presenter.setLoansGiven,
              ),
              _Section(title: l10n.zakat_section_debts),
              _ZakatField(
                label: l10n.zakat_field_personal_loans,
                currency: currency,
                controller: personalDebtsCtrl,
                onChanged: presenter.setPersonalDebts,
                isDebt: true,
              ),
              _ZakatField(
                label: l10n.zakat_field_bills,
                currency: currency,
                controller: billsCtrl,
                onChanged: presenter.setBillsDue,
                isDebt: true,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.zakat_footer_quote,
                  textAlign: TextAlign.center,
                  style: UITheme.of(context).typo.inter.bodyMedium.copyWith(
                        color: UIColorsToken.textParagraph,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _parse(String v) => double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;

/// Selectable currency chips (Wrap). Selected → yellow fill / black text,
/// unselected → transparent / white text; radius 8, small. Label is
/// `currencyType.toString()`.
class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({required this.selected, required this.onSelected});

  final CurrencyType selected;
  final ValueChanged<CurrencyType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in CurrencyType.values)
          _CurrencyChip(
            currency: c,
            selected: c == selected,
            onTap: () => onSelected(c),
          ),
      ],
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  final CurrencyType currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? UIColorsToken.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? UIColorsToken.yellow : UIColorsToken.stroke,
          ),
        ),
        child: Text(
          // Per spec: label is currencyType.toString().
          currency.toString(),
          style: theme.typo.inter.bodySmall.copyWith(
            color: selected ? UIColorsToken.black : UIColorsToken.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.l10n,
    required this.lang,
    required this.currency,
    required this.state,
    required this.onReset,
    required this.onGive,
  });

  final AppLocale l10n;
  final String lang;
  final CurrencyType currency;
  final ZakatCalculatorState state;
  final VoidCallback onReset;
  final VoidCallback onGive;

  String _money(double v) => ZakatCalculatorPage.money(v, lang, currency);

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final result = state.result;

    return UICard(
      padding: const EdgeInsets.all(16),
      colors: const [Color(0xff2C3427), Color(0xff20271D)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(theme, l10n.zakat_total_assets, _money(result.totalAssets)),
          const SizedBox(height: 10),
          _row(
            theme,
            l10n.zakat_total_debts,
            '-${_money(result.totalDebts)}',
            valueColor: UIColorsToken.red,
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: UIColorsToken.stroke),
          const SizedBox(height: 12),
          _row(
            theme,
            l10n.zakat_net_assets,
            _money(result.netAssets),
            labelColor: UIColorsToken.textYellow,
            bold: true,
          ),
          if (result.nisabThreshold > 0) ...[
            const SizedBox(height: 10),
            _row(
              theme,
              l10n.zakat_nisab_threshold,
              _money(result.nisabThreshold),
            ),
          ],
          const SizedBox(height: 16),
          _NisabPill(l10n: l10n, isAbove: result.isAboveNisab),
          const SizedBox(height: 20),
          Center(
            child: Text(
              l10n.zakat_your_zakat,
              style: theme.typo.inter.title.copyWith(
                color: UIColorsToken.textYellow,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: state.loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          UIColorsToken.textYellow,
                        ),
                      ),
                    ),
                  )
                : Text(
                    _money(result.zakatDue),
                    style: theme.typo.inter.hero.copyWith(
                      color: UIColorsToken.textYellow,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            state.apiError
                ? l10n.zakat_api_unavailable
                : l10n.zakat_obligation_note,
            textAlign: TextAlign.center,
            style: theme.typo.inter.bodyMedium.copyWith(
              color: state.apiError
                  ? UIColorsToken.red
                  : UIColorsToken.textParagraph,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              UIButton.textual(
                label: l10n.zakat_reset,
                contentColor: UIColorsToken.white,
                onTap: onReset,
              ),
              UIButton.primary(
                label: l10n.zakat_give,
                onTap: onGive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    UIThemeData theme,
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
    bool bold = false,
  }) {
    final labelStyle = theme.typo.inter.body.copyWith(
      color: labelColor ?? UIColorsToken.textParagraph,
    );
    final valueStyle = (bold ? theme.typo.inter.title : theme.typo.inter.body)
        .copyWith(color: valueColor ?? UIColorsToken.white);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _NisabPill extends StatelessWidget {
  const _NisabPill({required this.l10n, required this.isAbove});

  final AppLocale l10n;
  final bool isAbove;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final color = isAbove ? UIColorsToken.pastelGreen : UIColorsToken.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            isAbove ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAbove ? l10n.zakat_above_nisab : l10n.zakat_below_nisab,
              style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: theme.typo.inter.title.copyWith(color: UIColorsToken.white),
      ),
    );
  }
}

class _ZakatField extends StatelessWidget {
  const _ZakatField({
    required this.label,
    required this.currency,
    required this.controller,
    required this.onChanged,
    this.isDebt = false,
  });

  final String label;
  final CurrencyType currency;
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  final bool isDebt;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: UIColorsToken.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: isDebt
            ? Border.all(color: UIColorsToken.red.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: TextField(
              controller: controller,
              onChanged: (v) => onChanged(_parse(v)),
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              cursorColor: UIColorsToken.textYellow,
              style: theme.typo.inter.title.copyWith(color: UIColorsToken.white),
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: UIColorsToken.bgPrimary,
                hintText: '0',
                hintStyle: theme.typo.inter.title.copyWith(
                  color: UIColorsToken.textParagraph,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: _border(Colors.transparent),
                enabledBorder: _border(Colors.transparent),
                focusedBorder: _border(UIColorsToken.textYellow, width: 1.5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            currency.symbol,
            style: theme.typo.inter.title.copyWith(color: UIColorsToken.white),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
