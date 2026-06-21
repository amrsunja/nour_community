import 'package:intl/intl.dart';

/// Shared currency / count formatting for Impact cards & detail.
class ImpactFormat {
  const ImpactFormat._();

  static String symbol(String currency) => switch (currency) {
    'USD' => '\$',
    'GBP' => '£',
    _ => '€',
  };

  /// `12400, 'EUR'` → `12,400€`.
  static String money(double amount, String currency) {
    final n = NumberFormat.decimalPattern().format(amount.round());
    return '$n${symbol(currency)}';
  }

  /// `12000` → `12k+`, `850` → `850`.
  static String compactCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).floor()}M+';
    if (n >= 1000) return '${(n / 1000).floor()}k+';
    return '$n';
  }
}
