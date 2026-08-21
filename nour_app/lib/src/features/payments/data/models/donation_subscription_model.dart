import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'tx_enums.dart';

/// One row of `public.donation_subscriptions` — a recurring (monthly / yearly)
/// donation to a single project, backed by a Stripe Subscription.
class DonationSubscriptionModel extends Equatable {
  final int id;
  final String userId;
  final int impactProjectId;
  final double amount;
  final double feeCovered;
  final String currency;
  final DonationFrequency frequency;
  final SubscriptionStatus status;
  final bool isAnonymous;
  final PaymentMethodKind? paymentMethod;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? canceledAt;
  final DateTime createdAt;

  /// Embedded project title columns when the query joins `impact_projects`.
  final Json? project;

  const DonationSubscriptionModel({
    required this.id,
    required this.userId,
    required this.impactProjectId,
    required this.amount,
    required this.feeCovered,
    required this.currency,
    required this.frequency,
    required this.status,
    required this.isAnonymous,
    required this.paymentMethod,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.canceledAt,
    required this.createdAt,
    this.project,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  factory DonationSubscriptionModel.fromJson(Json json) {
    final project = json['impact_projects'];
    return DonationSubscriptionModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      impactProjectId: json['impact_project_id'] as int,
      amount: _toDouble(json['amount']),
      feeCovered: _toDouble(json['fee_covered']),
      currency: json['currency'] as String? ?? 'EUR',
      frequency: DonationFrequency.fromInterval(json['interval'] as String?),
      status: SubscriptionStatus.fromString(json['status'] as String?),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      paymentMethod: json['payment_method'] == null
          ? null
          : PaymentMethodKind.fromString(json['payment_method'] as String?),
      currentPeriodEnd: DateTime.tryParse(json['current_period_end'] ?? ''),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      canceledAt: DateTime.tryParse(json['canceled_at'] ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      project: project is Map<String, dynamic> ? project : null,
    );
  }

  /// Localized project title from the embedded join (falls back to English).
  String projectTitle(String langCode) {
    final p = project;
    if (p == null) return '';
    final localized = p['title_$langCode'];
    if (localized is String && localized.isNotEmpty) return localized;
    return p['title_en'] as String? ?? '';
  }

  /// Still charging (or awaiting a retry) and not scheduled to stop.
  bool get isActive => status.isLive && !cancelAtPeriodEnd;

  @override
  List<Object?> get props => [
    id,
    userId,
    impactProjectId,
    amount,
    feeCovered,
    currency,
    frequency,
    status,
    isAnonymous,
    paymentMethod,
    currentPeriodEnd,
    cancelAtPeriodEnd,
    canceledAt,
    createdAt,
    project,
  ];
}
