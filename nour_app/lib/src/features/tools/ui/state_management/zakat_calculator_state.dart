import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/enums/currency_type.dart';
import 'package:nour/src/core/utils/islamic_tools/zakat_tool.dart';

/// Immutable Zakat calculator screen state (hand-written, no codegen).
class ZakatCalculatorState extends Equatable {
  /// Whether the screen has finished its first frame init.
  final bool ready;

  /// A live calculation request is in flight.
  final bool loading;

  /// The last network calculation failed (showing offline estimate).
  final bool apiError;

  /// Working / display currency for all money fields.
  final CurrencyType currency;

  // Asset inputs (estimated monetary value, selected currency).
  final double gold;
  final double silver;
  final double other;
  final double cash;
  final double savings;
  final double investments;
  final double loansGiven;

  // Liability inputs.
  final double personalDebts;
  final double billsDue;

  /// Last Nisab (in the working currency) the engine reported — reused by the
  /// offline fallback.
  final double? lastNisab;

  /// Latest computed result (defaults to zeros).
  final ZakatResult result;

  const ZakatCalculatorState({
    this.ready = false,
    this.loading = false,
    this.apiError = false,
    this.currency = CurrencyType.defaultCurrency,
    this.gold = 0,
    this.silver = 0,
    this.other = 0,
    this.cash = 0,
    this.savings = 0,
    this.investments = 0,
    this.loansGiven = 0,
    this.personalDebts = 0,
    this.billsDue = 0,
    this.lastNisab,
    this.result = ZakatResult.empty,
  });

  ZakatInput get input => ZakatInput(
        gold: gold,
        silver: silver,
        other: other,
        cash: cash,
        savings: savings,
        investments: investments,
        loansGiven: loansGiven,
        personalDebts: personalDebts,
        billsDue: billsDue,
      );

  ZakatCalculatorState copyWith({
    bool? ready,
    bool? loading,
    bool? apiError,
    CurrencyType? currency,
    double? gold,
    double? silver,
    double? other,
    double? cash,
    double? savings,
    double? investments,
    double? loansGiven,
    double? personalDebts,
    double? billsDue,
    double? lastNisab,
    ZakatResult? result,
  }) {
    return ZakatCalculatorState(
      ready: ready ?? this.ready,
      loading: loading ?? this.loading,
      apiError: apiError ?? this.apiError,
      currency: currency ?? this.currency,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      other: other ?? this.other,
      cash: cash ?? this.cash,
      savings: savings ?? this.savings,
      investments: investments ?? this.investments,
      loansGiven: loansGiven ?? this.loansGiven,
      personalDebts: personalDebts ?? this.personalDebts,
      billsDue: billsDue ?? this.billsDue,
      lastNisab: lastNisab ?? this.lastNisab,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        ready,
        loading,
        apiError,
        currency,
        gold,
        silver,
        other,
        cash,
        savings,
        investments,
        loansGiven,
        personalDebts,
        billsDue,
        lastNisab,
        result,
      ];
}
