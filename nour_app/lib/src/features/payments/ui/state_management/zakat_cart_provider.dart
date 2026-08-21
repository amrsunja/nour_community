import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';

import '../../data/models/tx_enums.dart';

/// One allocated line of the zakat split: a zakat-eligible project + the
/// amount (in the project currency, whole euros from the digits-only input).
class ZakatCartItem extends Equatable {
  const ZakatCartItem({required this.project, required this.amount});

  final ImpactProjectModel project;
  final double amount;

  PaymentItem get paymentItem =>
      PaymentItem(projectId: project.id, amount: amount);

  @override
  List<Object?> get props => [project.id, amount];
}

/// The zakat allocation being paid: what the calculator said is owed and how
/// the user split it across eligible projects.
class ZakatCart extends Equatable {
  const ZakatCart({
    required this.zakatOwed,
    required this.items,
    this.currency = 'EUR',
  });

  /// From the calculator (0 when the user opened the flow without computing).
  final double zakatOwed;
  final List<ZakatCartItem> items;
  final String currency;

  double get allocated => items.fold(0, (s, i) => s + i.amount);

  /// Positive = still owed after this payment; negative = extra (sadaqa).
  double get remaining => zakatOwed - allocated;

  List<PaymentItem> get paymentItems =>
      [for (final i in items) i.paymentItem];

  @override
  List<Object?> get props => [zakatOwed, items, currency];
}

/// Carries the allocation from the calculator sheet to the zakat checkout and
/// reward pages. App-lifetime on purpose: it must survive the sheet closing
/// and the checkout → reward navigation; each new allocation overwrites it.
final zakatCartProvider = StateProvider<ZakatCart?>((ref) => null);
