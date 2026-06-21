/// Raw inputs of the Zakat calculator screen.
///
/// Every field is a **monetary value in the user's selected currency** — the
/// user estimates what each asset is worth (e.g. the resale value of their
/// gold, silver and other valuables) rather than entering weights. All assets
/// are pooled following the Hanafi *Dam' al-Amwal* principle, immediate debts
/// are deducted, and the net is measured against the Nisab.
class ZakatInput {
  // ── Zakatable assets (estimated market value) ─────────────────────────────
  final double gold; // estimated value of gold owned
  final double silver; // estimated value of silver owned
  final double other; // other valuables (gemstones, trade goods, …)
  final double cash; // cash & bank balance
  final double savings; // saved for future use
  final double investments; // stocks, ETFs, crypto (ʿurud al-tijarah)
  final double loansGiven; // good receivables (dayn marjuww — expected back)

  // ── Deductible liabilities (immediate debts — dayn al-hal) ────────────────
  final double personalDebts; // personal loans, credit due now
  final double billsDue; // bills & rent due now

  const ZakatInput({
    this.gold = 0,
    this.silver = 0,
    this.other = 0,
    this.cash = 0,
    this.savings = 0,
    this.investments = 0,
    this.loansGiven = 0,
    this.personalDebts = 0,
    this.billsDue = 0,
  });

  double get totalAssets =>
      gold + silver + other + cash + savings + investments + loansGiven;

  double get totalDebts => personalDebts + billsDue;

  /// Net zakatable wealth — the figure sent to the Zakat engine.
  double get netAssets => totalAssets - totalDebts;
}

/// Outcome of a Zakat calculation (engine result + aggregated totals).
class ZakatResult {
  final double totalAssets;
  final double totalDebts;
  final double netAssets;

  /// Resolved Nisab threshold the [netAssets] are measured against.
  final double nisabThreshold;

  final bool isAboveNisab;

  /// Zakat owed (`netAssets * rate`) when above Nisab, else 0.
  final double zakatDue;

  /// Applied rate (0.025 = 2.5%).
  final double rate;

  /// `true` when [zakatDue] / [isAboveNisab] came from the EsakoAPI engine,
  /// `false` when it is the offline fallback estimate.
  final bool fromApi;

  const ZakatResult({
    required this.totalAssets,
    required this.totalDebts,
    required this.netAssets,
    required this.nisabThreshold,
    required this.isAboveNisab,
    required this.zakatDue,
    required this.rate,
    this.fromApi = false,
  });

  static const empty = ZakatResult(
    totalAssets: 0,
    totalDebts: 0,
    netAssets: 0,
    nisabThreshold: 0,
    isAboveNisab: false,
    zakatDue: 0,
    rate: ZakatTool.zakatRate,
  );

  ZakatResult copyWith({
    double? totalAssets,
    double? totalDebts,
    double? netAssets,
    double? nisabThreshold,
    bool? isAboveNisab,
    double? zakatDue,
    double? rate,
    bool? fromApi,
  }) {
    return ZakatResult(
      totalAssets: totalAssets ?? this.totalAssets,
      totalDebts: totalDebts ?? this.totalDebts,
      netAssets: netAssets ?? this.netAssets,
      nisabThreshold: nisabThreshold ?? this.nisabThreshold,
      isAboveNisab: isAboveNisab ?? this.isAboveNisab,
      zakatDue: zakatDue ?? this.zakatDue,
      rate: rate ?? this.rate,
      fromApi: fromApi ?? this.fromApi,
    );
  }
}

/// Aggregation + offline fallback for Zakat al-Mal.
///
/// The authoritative calculation (Nisab determination from the live silver
/// price + the 2.5% rate) is delegated to the EsakoAPI money engine. This class
/// only pools the inputs and provides a deterministic offline estimate when the
/// network is unavailable, using the last Nisab the engine reported.
class ZakatTool {
  const ZakatTool._();

  /// Zakat rate on monetary wealth: 2.5% (rubʿ al-ʿushr — 1/40). Hadith of Ali
  /// (ra), Sunan Abu Dawud 1573.
  static const double zakatRate = 0.025;

  /// Aggregate-only result: totals computed locally, Zakat left at 0 until the
  /// API answers (used as the instant, pre-network snapshot).
  static ZakatResult aggregate(ZakatInput input) {
    return ZakatResult(
      totalAssets: input.totalAssets,
      totalDebts: input.totalDebts,
      netAssets: input.netAssets,
      nisabThreshold: 0,
      isAboveNisab: false,
      zakatDue: 0,
      rate: zakatRate,
      fromApi: false,
    );
  }

  /// Offline fallback: apply the rate locally against a known [nisab] (e.g. the
  /// last value the API returned). Returns an [aggregate] result when no Nisab
  /// reference is available.
  static ZakatResult fallback(ZakatInput input, {double? nisab}) {
    final net = input.netAssets;
    if (nisab == null || nisab <= 0) return aggregate(input);
    final above = net >= nisab;
    return ZakatResult(
      totalAssets: input.totalAssets,
      totalDebts: input.totalDebts,
      netAssets: net,
      nisabThreshold: nisab,
      isAboveNisab: above,
      zakatDue: above ? net * zakatRate : 0,
      rate: zakatRate,
      fromApi: false,
    );
  }
}
