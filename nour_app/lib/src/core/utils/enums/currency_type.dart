/// Display / working currency for the Zakat calculator.
///
/// The user estimates every asset (gold, silver, other valuables, cash …) as a
/// monetary amount in the [CurrencyType] selected at the top of the screen.
///
/// Fiqh / API note: the EsakoAPI money engine derives the Nisab threshold from
/// the **live silver price in USD**. The selected currency is therefore the
/// user's working currency for entering estimates and for display — the 2.5%
/// rate itself is currency-agnostic.
enum CurrencyType {
  usd(code: 'USD', symbol: '\$'),
  eur(code: 'EUR', symbol: '€'),
  gbp(code: 'GBP', symbol: '£'),
  sar(code: 'SAR', symbol: 'SAR'),
  aed(code: 'AED', symbol: 'AED'),
  mad(code: 'MAD', symbol: 'MAD');

  const CurrencyType({required this.code, required this.symbol});

  /// ISO 4217 code, also used as the selector label (`toString`).
  final String code;

  /// Symbol appended to formatted amounts (falls back to the code).
  final String symbol;

  static const CurrencyType defaultCurrency = CurrencyType.eur;

  /// Selector chip label — per spec the label is `currencyType.toString()`.
  @override
  String toString() => code;

  String get dbValue => code;

  static CurrencyType fromString(String? value) {
    if (value == null) return defaultCurrency;
    return CurrencyType.values.firstWhere(
      (e) => e.code == value || e.name == value,
      orElse: () => defaultCurrency,
    );
  }
}
