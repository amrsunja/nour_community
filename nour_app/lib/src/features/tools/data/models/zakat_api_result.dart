/// Parsed outcome of an EsakoAPI `/money/{amount}` call.
///
/// The endpoint answers in two shapes:
///
/// * **Above Nisab** — `code: 200`
///   ```json
///   { "code":200, "response":50.0,
///     "requirements":[ "...silver price of 2.8008 USD per gram." ],
///     "Unit":"$", "date":"...", "time":"..." }
///   ```
/// * **Below Nisab** — `code: 325`
///   ```json
///   { "code":325, "ok":true,
///     "message":"...Nisaab for money is 12841.2073 USD (based on gold)
///                or 1666.4629 USD (based on silver)." }
///   ```
///
/// All Nisab figures are in **USD** (live silver/gold prices).
class ZakatApiResult {
  /// HTTP-ish status returned in the body (200, 325, 4xx …).
  final int code;

  /// Whether net wealth reached the (silver) Nisab and Zakat is due.
  final bool aboveNisab;

  /// Zakat owed in the amount's currency (0 when below Nisab). 2.5% of net.
  final double zakatDue;

  /// Nisab in USD based on the gold standard (85g), when reported.
  final double? nisabGoldUsd;

  /// Operative Nisab in USD based on the silver standard (595g) — the lower,
  /// *anfaʿ lil-fuqaraʾ* threshold the API actually measures against.
  final double? nisabSilverUsd;

  /// Shariah conditions returned alongside a successful calculation.
  final List<String> requirements;

  /// Human-readable message (present on the below-Nisab / error branches).
  final String? message;

  /// Currency unit reported by the API (e.g. `$`).
  final String unit;

  const ZakatApiResult({
    required this.code,
    required this.aboveNisab,
    required this.zakatDue,
    this.nisabGoldUsd,
    this.nisabSilverUsd,
    this.requirements = const [],
    this.message,
    this.unit = '\$',
  });

  bool get isError => code != 200 && code != 325;

  factory ZakatApiResult.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] as num?)?.toInt() ?? 0;

    if (code == 200) {
      final reqs = (json['requirements'] ?? json['conditions']);
      final requirements = reqs is List
          ? reqs.map((e) => e.toString()).toList()
          : const <String>[];
      return ZakatApiResult(
        code: 200,
        aboveNisab: true,
        zakatDue: ((json['response'] ?? 0) as num).toDouble(),
        nisabSilverUsd: _silverNisabFromRequirements(requirements),
        requirements: requirements,
        unit: (json['Unit'] ?? json['unit'] ?? '\$').toString(),
      );
    }

    if (code == 325) {
      final msg = json['message']?.toString() ?? '';
      final nisab = _nisabFromMessage(msg);
      return ZakatApiResult(
        code: 325,
        aboveNisab: false,
        zakatDue: 0,
        nisabGoldUsd: nisab.$1,
        nisabSilverUsd: nisab.$2,
        message: msg,
      );
    }

    return ZakatApiResult(
      code: code,
      aboveNisab: false,
      zakatDue: 0,
      message: json['message']?.toString(),
    );
  }

  /// Extracts `(gold, silver)` Nisab from the below-Nisab message, e.g.
  /// "...12841.2073 USD (based on gold) or 1666.4629 USD (based on silver)."
  static (double?, double?) _nisabFromMessage(String msg) {
    double? grab(String anchor) {
      final m = RegExp(r'([\d.]+)\s*USD\s*\(based on ' + anchor + r'\)',
              caseSensitive: false)
          .firstMatch(msg);
      return m == null ? null : double.tryParse(m.group(1)!);
    }

    return (grab('gold'), grab('silver'));
  }

  /// Derives the silver Nisab (595g) from the live "silver price of X USD per
  /// gram" line in the success requirements.
  static double? _silverNisabFromRequirements(List<String> requirements) {
    for (final r in requirements) {
      final m = RegExp(r'silver price of\s*([\d.]+)', caseSensitive: false)
          .firstMatch(r);
      if (m != null) {
        final price = double.tryParse(m.group(1)!);
        if (price != null) return price * 595;
      }
    }
    return null;
  }
}
