import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

double _num(dynamic v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
int _int(dynamic v) => v == null ? 0 : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
List<int> _ints(dynamic v) => v is List ? v.map(_int).where((e) => e > 0).toList() : const [];

/// Fallback amounts for fundraising (mirrors the `mosque_campaign_settings`
/// / `mosque_campaigns` column defaults).
const List<int> kDefaultCampaignAmounts = [10, 50, 100, 150];

/// How many suggested amounts a campaign carries (the DB guard caps at 6 too).
const int kCampaignMaxAmounts = 6;

/// Mirrors the Postgres enum `public.stripe_account_status`
/// ('not_started' | 'onboarding' | 'active' | 'restricted' | 'disabled'),
/// as stored in `mosque_stripe_accounts.status` and returned by the
/// `mosque-stripe-onboarding` edge function. The wire values MUST match.
enum MosqueStripeStatus {
  notStarted('not_started'),
  pending('onboarding'),
  restricted('restricted'),
  enabled('active'),
  rejected('disabled');

  const MosqueStripeStatus(this.value);
  final String value;

  static MosqueStripeStatus fromString(String? v) =>
      MosqueStripeStatus.values.firstWhere((e) => e.value == v, orElse: () => MosqueStripeStatus.notStarted);
}

/// `mosque_stripe_accounts` row + the live fields returned by
/// `mosque-stripe-onboarding {action:'status'}`.
class MosqueStripeAccount extends Equatable {
  final String? accountId;
  final MosqueStripeStatus status;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final List<String> currentlyDue;
  final String? dashboardUrl;

  const MosqueStripeAccount({
    this.accountId,
    this.status = MosqueStripeStatus.notStarted,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
    this.currentlyDue = const [],
    this.dashboardUrl,
  });

  bool get isEnabled => chargesEnabled;
  bool get hasAccount => accountId != null && accountId!.isNotEmpty;

  factory MosqueStripeAccount.fromRow(Json json) => MosqueStripeAccount(
        accountId: json['stripe_account_id'] as String?,
        status: MosqueStripeStatus.fromString(json['status'] as String?),
        chargesEnabled: json['charges_enabled'] as bool? ?? false,
        payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
        detailsSubmitted: json['details_submitted'] as bool? ?? false,
        currentlyDue: ((json['requirements'] as Map?)?['currently_due'] as List?)?.map((e) => '$e').toList() ?? const [],
      );

  factory MosqueStripeAccount.fromStatus(Json json) => MosqueStripeAccount(
        accountId: json['accountId'] as String?,
        status: MosqueStripeStatus.fromString(json['status'] as String?),
        chargesEnabled: json['chargesEnabled'] as bool? ?? false,
        payoutsEnabled: json['payoutsEnabled'] as bool? ?? false,
        detailsSubmitted: json['detailsSubmitted'] as bool? ?? false,
        currentlyDue: (json['currentlyDue'] as List?)?.map((e) => '$e').toList() ?? const [],
        dashboardUrl: json['dashboardUrl'] as String?,
      );

  @override
  List<Object?> get props => [accountId, status, chargesEnabled, payoutsEnabled, detailsSubmitted, currentlyDue, dashboardUrl];
}

/// `mosque_donation_settings` — the Sadaqa card configuration (devis B2).
class MosqueDonationSettings extends Equatable {
  final int mosqueId;
  final String title;
  final String? description;
  final List<int> suggestedAmounts;
  final bool allowOneTime;
  final bool allowMonthly;
  final bool allowYearly;
  final bool showTaxBadge;
  final List<int> membershipFeeAmounts;

  const MosqueDonationSettings({
    required this.mosqueId,
    this.title = 'Support the mosque',
    this.description,
    this.suggestedAmounts = const [10, 50, 100, 150],
    this.allowOneTime = true,
    this.allowMonthly = true,
    this.allowYearly = true,
    this.showTaxBadge = false,
    this.membershipFeeAmounts = const [60, 120, 240],
  });

  List<DonationFrequency> get frequencies => [
        if (allowOneTime) DonationFrequency.oneTime,
        if (allowMonthly) DonationFrequency.monthly,
        if (allowYearly) DonationFrequency.yearly,
      ];

  factory MosqueDonationSettings.fromJson(Json json) => MosqueDonationSettings(
        mosqueId: _int(json['mosque_id']),
        title: json['title'] as String? ?? 'Support the mosque',
        description: json['description'] as String?,
        suggestedAmounts: _ints(json['suggested_amounts']),
        allowOneTime: json['allow_one_time'] as bool? ?? true,
        allowMonthly: json['allow_monthly'] as bool? ?? true,
        allowYearly: json['allow_yearly'] as bool? ?? true,
        showTaxBadge: json['show_tax_badge'] as bool? ?? false,
        membershipFeeAmounts: _ints(json['membership_fee_amounts']),
      );

  Json toJson() => {
        'mosque_id': mosqueId,
        'title': title,
        'description': description,
        'suggested_amounts': suggestedAmounts,
        'allow_one_time': allowOneTime,
        'allow_monthly': allowMonthly,
        'allow_yearly': allowYearly,
        'show_tax_badge': showTaxBadge,
        'membership_fee_amounts': membershipFeeAmounts,
      };

  MosqueDonationSettings copyWith({
    String? title,
    String? description,
    List<int>? suggestedAmounts,
    bool? allowOneTime,
    bool? allowMonthly,
    bool? allowYearly,
    bool? showTaxBadge,
    List<int>? membershipFeeAmounts,
  }) =>
      MosqueDonationSettings(
        mosqueId: mosqueId,
        title: title ?? this.title,
        description: description ?? this.description,
        suggestedAmounts: suggestedAmounts ?? this.suggestedAmounts,
        allowOneTime: allowOneTime ?? this.allowOneTime,
        allowMonthly: allowMonthly ?? this.allowMonthly,
        allowYearly: allowYearly ?? this.allowYearly,
        showTaxBadge: showTaxBadge ?? this.showTaxBadge,
        membershipFeeAmounts: membershipFeeAmounts ?? this.membershipFeeAmounts,
      );

  @override
  List<Object?> get props =>
      [mosqueId, title, description, suggestedAmounts, allowOneTime, allowMonthly, allowYearly, showTaxBadge, membershipFeeAmounts];
}

/// `mosque_campaign_settings` — the mosque-wide fundraising configuration
/// (devis B3). Campaigns are NOT the Sadaqa card: they carry their own
/// suggested amounts, their own allowed frequencies and their own tax badge.
/// A new campaign is seeded from this row and may then override it.
class MosqueCampaignSettings extends Equatable {
  final int mosqueId;
  final List<int> suggestedAmounts;
  final bool allowOneTime;
  final bool allowMonthly;
  final bool allowYearly;
  final bool showTaxBadge;

  const MosqueCampaignSettings({
    required this.mosqueId,
    this.suggestedAmounts = kDefaultCampaignAmounts,
    this.allowOneTime = true,
    this.allowMonthly = false,
    this.allowYearly = false,
    this.showTaxBadge = false,
  });

  List<DonationFrequency> get frequencies => [
        if (allowOneTime) DonationFrequency.oneTime,
        if (allowMonthly) DonationFrequency.monthly,
        if (allowYearly) DonationFrequency.yearly,
      ];

  /// Amounts to show, never empty (the DB guard applies the same fallback).
  List<int> get amountsOrDefault => suggestedAmounts.isEmpty ? kDefaultCampaignAmounts : suggestedAmounts;

  factory MosqueCampaignSettings.fromJson(Json json) => MosqueCampaignSettings(
        mosqueId: _int(json['mosque_id']),
        suggestedAmounts: _ints(json['suggested_amounts']),
        allowOneTime: json['allow_one_time'] as bool? ?? true,
        allowMonthly: json['allow_monthly'] as bool? ?? false,
        allowYearly: json['allow_yearly'] as bool? ?? false,
        showTaxBadge: json['show_tax_badge'] as bool? ?? false,
      );

  Json toJson() => {
        'mosque_id': mosqueId,
        'suggested_amounts': amountsOrDefault,
        'allow_one_time': allowOneTime,
        'allow_monthly': allowMonthly,
        'allow_yearly': allowYearly,
        'show_tax_badge': showTaxBadge,
      };

  MosqueCampaignSettings copyWith({
    List<int>? suggestedAmounts,
    bool? allowOneTime,
    bool? allowMonthly,
    bool? allowYearly,
    bool? showTaxBadge,
  }) =>
      MosqueCampaignSettings(
        mosqueId: mosqueId,
        suggestedAmounts: suggestedAmounts ?? this.suggestedAmounts,
        allowOneTime: allowOneTime ?? this.allowOneTime,
        allowMonthly: allowMonthly ?? this.allowMonthly,
        allowYearly: allowYearly ?? this.allowYearly,
        showTaxBadge: showTaxBadge ?? this.showTaxBadge,
      );

  @override
  List<Object?> get props => [mosqueId, suggestedAmounts, allowOneTime, allowMonthly, allowYearly, showTaxBadge];
}

/// Mirrors `public.mosque_campaign_status`.
enum MosqueCampaignStatus {
  draft,
  active,
  closed,
  cancelled;

  static MosqueCampaignStatus fromString(String? v) =>
      MosqueCampaignStatus.values.firstWhere((e) => e.name == v, orElse: () => MosqueCampaignStatus.active);
}

/// `mosque_campaigns` (devis B3).
class MosqueCampaignModel extends Equatable {
  final int id;
  final int mosqueId;
  final String title;
  final String? description;
  final String? coverUrl;
  final double goalAmount;
  final double collectedAmount;
  final int donorsCount;
  final List<int> suggestedAmounts;
  final bool allowOneTime;
  final bool allowMonthly;
  final bool allowYearly;
  final bool showTaxBadge;
  final String currency;
  final MosqueCampaignStatus status;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? closedAt;
  final String? closedReason;
  final DateTime createdAt;

  const MosqueCampaignModel({
    required this.id,
    required this.mosqueId,
    required this.title,
    this.description,
    this.coverUrl,
    required this.goalAmount,
    this.collectedAmount = 0,
    this.donorsCount = 0,
    this.suggestedAmounts = kDefaultCampaignAmounts,
    this.allowOneTime = true,
    this.allowMonthly = false,
    this.allowYearly = false,
    this.showTaxBadge = false,
    this.currency = 'EUR',
    this.status = MosqueCampaignStatus.active,
    required this.startsAt,
    required this.endsAt,
    this.closedAt,
    this.closedReason,
    required this.createdAt,
  });

  double get progress => goalAmount <= 0 ? 0 : (collectedAmount / goalAmount).clamp(0, 1).toDouble();
  int get percent => (progress * 100).round();
  double get remaining => (goalAmount - collectedAmount).clamp(0, double.infinity).toDouble();
  int get daysLeft {
    final d = endsAt.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  /// Frequencies this campaign accepts — its own, not the Sadaqa card's.
  List<DonationFrequency> get frequencies => [
        if (allowOneTime) DonationFrequency.oneTime,
        if (allowMonthly) DonationFrequency.monthly,
        if (allowYearly) DonationFrequency.yearly,
      ];

  bool get acceptsRecurring => allowMonthly || allowYearly;

  /// Amounts to show, never empty.
  List<int> get amountsOrDefault => suggestedAmounts.isEmpty ? kDefaultCampaignAmounts : suggestedAmounts;

  /// Default selection of the donor amount picker (2nd amount when there is one).
  double get defaultAmount {
    final a = amountsOrDefault;
    return (a.length > 1 ? a[1] : a.first).toDouble();
  }

  bool get isOpen => status == MosqueCampaignStatus.active && endsAt.isAfter(DateTime.now());
  bool get isEndingSoon => isOpen && endsAt.difference(DateTime.now()).inDays < 7;
  bool get isFunded => collectedAmount >= goalAmount;

  factory MosqueCampaignModel.fromJson(Json json) => MosqueCampaignModel(
        id: _int(json['id']),
        mosqueId: _int(json['mosque_id']),
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        coverUrl: json['cover_url'] as String?,
        goalAmount: _num(json['goal_amount']),
        collectedAmount: _num(json['collected_amount']),
        donorsCount: _int(json['donors_count']),
        suggestedAmounts: _ints(json['suggested_amounts']),
        allowOneTime: json['allow_one_time'] as bool? ?? true,
        allowMonthly: json['allow_monthly'] as bool? ?? false,
        allowYearly: json['allow_yearly'] as bool? ?? false,
        showTaxBadge: json['show_tax_badge'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'EUR',
        status: MosqueCampaignStatus.fromString(json['status'] as String?),
        startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        closedAt: DateTime.tryParse(json['closed_at']?.toString() ?? '')?.toLocal(),
        closedReason: json['closed_reason'] as String?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, mosqueId, title, description, coverUrl, goalAmount, collectedAmount, donorsCount, suggestedAmounts, allowOneTime, allowMonthly, allowYearly, showTaxBadge, currency, status, startsAt, endsAt, closedAt, closedReason, createdAt];
}

/// Admin form payload for a campaign (create / edit).
class MosqueCampaignDraft extends Equatable {
  final int? id;
  final String title;
  final String description;
  final String? coverUrl;
  final double goalAmount;
  final DateTime endsAt;
  final List<int> suggestedAmounts;
  final bool allowOneTime;
  final bool allowMonthly;
  final bool allowYearly;
  final bool showTaxBadge;

  const MosqueCampaignDraft({
    this.id,
    this.title = '',
    this.description = '',
    this.coverUrl,
    this.goalAmount = 0,
    required this.endsAt,
    this.suggestedAmounts = kDefaultCampaignAmounts,
    this.allowOneTime = true,
    this.allowMonthly = false,
    this.allowYearly = false,
    this.showTaxBadge = false,
  });

  factory MosqueCampaignDraft.fromModel(MosqueCampaignModel c) => MosqueCampaignDraft(
        id: c.id,
        title: c.title,
        description: c.description ?? '',
        coverUrl: c.coverUrl,
        goalAmount: c.goalAmount,
        endsAt: c.endsAt,
        suggestedAmounts: c.suggestedAmounts,
        allowOneTime: c.allowOneTime,
        allowMonthly: c.allowMonthly,
        allowYearly: c.allowYearly,
        showTaxBadge: c.showTaxBadge,
      );

  /// A brand-new campaign inherits the mosque's fundraising settings — never
  /// the Sadaqa card. [settings] is null only while the row is still loading.
  factory MosqueCampaignDraft.fromSettings(MosqueCampaignSettings? settings, {Duration duration = const Duration(days: 30)}) =>
      MosqueCampaignDraft(
        endsAt: DateTime.now().add(duration),
        suggestedAmounts: settings?.amountsOrDefault ?? kDefaultCampaignAmounts,
        allowOneTime: settings?.allowOneTime ?? true,
        allowMonthly: settings?.allowMonthly ?? false,
        allowYearly: settings?.allowYearly ?? false,
        showTaxBadge: settings?.showTaxBadge ?? false,
      );

  List<DonationFrequency> get frequencies => [
        if (allowOneTime) DonationFrequency.oneTime,
        if (allowMonthly) DonationFrequency.monthly,
        if (allowYearly) DonationFrequency.yearly,
      ];

  bool get hasFrequency => allowOneTime || allowMonthly || allowYearly;

  bool get isValid =>
      title.trim().isNotEmpty && goalAmount > 0 && endsAt.isAfter(DateTime.now()) && suggestedAmounts.isNotEmpty && hasFrequency;

  Json toJson(int mosqueId) => {
        'mosque_id': mosqueId,
        'title': title.trim(),
        'description': description.trim().isEmpty ? null : description.trim(),
        'cover_url': coverUrl,
        'goal_amount': goalAmount,
        'ends_at': endsAt.toUtc().toIso8601String(),
        'suggested_amounts': (suggestedAmounts.where((a) => a > 0).toSet().toList()..sort()).take(kCampaignMaxAmounts).toList(),
        'allow_one_time': allowOneTime,
        'allow_monthly': allowMonthly,
        'allow_yearly': allowYearly,
        'show_tax_badge': showTaxBadge,
      };

  MosqueCampaignDraft copyWith({
    String? title,
    String? description,
    String? coverUrl,
    double? goalAmount,
    DateTime? endsAt,
    List<int>? suggestedAmounts,
    bool? allowOneTime,
    bool? allowMonthly,
    bool? allowYearly,
    bool? showTaxBadge,
  }) =>
      MosqueCampaignDraft(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        coverUrl: coverUrl ?? this.coverUrl,
        goalAmount: goalAmount ?? this.goalAmount,
        endsAt: endsAt ?? this.endsAt,
        suggestedAmounts: suggestedAmounts ?? this.suggestedAmounts,
        allowOneTime: allowOneTime ?? this.allowOneTime,
        allowMonthly: allowMonthly ?? this.allowMonthly,
        allowYearly: allowYearly ?? this.allowYearly,
        showTaxBadge: showTaxBadge ?? this.showTaxBadge,
      );

  @override
  List<Object?> get props =>
      [id, title, description, coverUrl, goalAmount, endsAt, suggestedAmounts, allowOneTime, allowMonthly, allowYearly, showTaxBadge];
}

/// `mosque_campaign_updates` — progress posts on a campaign.
class MosqueCampaignUpdate extends Equatable {
  final int id;
  final int campaignId;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;

  const MosqueCampaignUpdate({required this.id, required this.campaignId, required this.body, this.imageUrl, required this.createdAt});

  factory MosqueCampaignUpdate.fromJson(Json json) => MosqueCampaignUpdate(
        id: _int(json['id']),
        campaignId: _int(json['campaign_id']),
        body: json['body'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, campaignId, body, imageUrl, createdAt];
}

/// Non-anonymous recent donor of a campaign (avatars row).
class MosqueCampaignDonor extends Equatable {
  final String userId;
  final String? avatarUrl;
  final String? name;
  const MosqueCampaignDonor({required this.userId, this.avatarUrl, this.name});

  factory MosqueCampaignDonor.fromJson(Json json) =>
      MosqueCampaignDonor(userId: json['user_id'] as String, avatarUrl: json['avatar_url'] as String?, name: json['name'] as String?);

  @override
  List<Object?> get props => [userId, avatarUrl, name];
}

/// `fn_mosque_donation_stats` (admin analytics — devis B5).
class MosqueDonationStats extends Equatable {
  final int year;
  final double totalYear;
  final double totalPrevYear;
  final double supportAmount;
  final double campaignsAmount;
  final int donors;
  final int recurringActive;
  final double avgGift;
  final int monthGifts;
  final double monthAmount;
  final int monthlyDonors;

  const MosqueDonationStats({
    required this.year,
    this.totalYear = 0,
    this.totalPrevYear = 0,
    this.supportAmount = 0,
    this.campaignsAmount = 0,
    this.donors = 0,
    this.recurringActive = 0,
    this.avgGift = 0,
    this.monthGifts = 0,
    this.monthAmount = 0,
    this.monthlyDonors = 0,
  });

  /// Year-over-year growth in percent (null when there is no baseline).
  double? get growthPercent => totalPrevYear <= 0 ? null : ((totalYear - totalPrevYear) / totalPrevYear) * 100;

  factory MosqueDonationStats.fromJson(Json json) => MosqueDonationStats(
        year: _int(json['year']),
        totalYear: _num(json['total_year']),
        totalPrevYear: _num(json['total_prev_year']),
        supportAmount: _num(json['support_amount']),
        campaignsAmount: _num(json['campaigns_amount']),
        donors: _int(json['donors']),
        recurringActive: _int(json['recurring_active']),
        avgGift: _num(json['avg_gift']),
        monthGifts: _int(json['month_gifts']),
        monthAmount: _num(json['month_amount']),
        monthlyDonors: _int(json['monthly_donors']),
      );

  @override
  List<Object?> get props => [year, totalYear, totalPrevYear, supportAmount, campaignsAmount, donors, recurringActive, avgGift, monthGifts, monthAmount, monthlyDonors];
}

/// One row of `fn_mosque_donors` (admin donors list).
class MosqueDonorRow extends Equatable {
  final int transactionId;
  final DateTime createdAt;
  final double amount;
  final String type; // mosque_sadaqa | mosque_campaign | mosque_membership
  final bool isAnonymous;
  final bool isRecurring;
  final String? userId;
  final String? name;
  final String? avatarUrl;
  final String? email;
  final String? campaignTitle;
  final int? receiptId;

  const MosqueDonorRow({
    required this.transactionId,
    required this.createdAt,
    required this.amount,
    required this.type,
    required this.isAnonymous,
    required this.isRecurring,
    this.userId,
    this.name,
    this.avatarUrl,
    this.email,
    this.campaignTitle,
    this.receiptId,
  });

  factory MosqueDonorRow.fromJson(Json json) => MosqueDonorRow(
        transactionId: _int(json['transaction_id']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        amount: _num(json['amount']),
        type: json['type'] as String? ?? 'mosque_sadaqa',
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        isRecurring: json['is_recurring'] as bool? ?? false,
        userId: json['user_id'] as String?,
        name: json['name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        email: json['email'] as String?,
        campaignTitle: json['campaign_title'] as String?,
        receiptId: json['receipt_id'] == null ? null : _int(json['receipt_id']),
      );

  @override
  List<Object?> get props => [transactionId, createdAt, amount, type, isAnonymous, isRecurring, userId, name, avatarUrl, email, campaignTitle, receiptId];
}

/// One row of `fn_my_mosque_donations` (donor history).
class MyMosqueDonation extends Equatable {
  final int transactionId;
  final DateTime createdAt;
  final double amount;
  final String type;
  final TxStatus status;
  final int mosqueId;
  final String mosqueName;
  final String? campaignTitle;
  final int? subscriptionId;
  final int? receiptId;

  const MyMosqueDonation({
    required this.transactionId,
    required this.createdAt,
    required this.amount,
    required this.type,
    required this.status,
    required this.mosqueId,
    required this.mosqueName,
    this.campaignTitle,
    this.subscriptionId,
    this.receiptId,
  });

  bool get isRecurring => subscriptionId != null;

  factory MyMosqueDonation.fromJson(Json json) => MyMosqueDonation(
        transactionId: _int(json['transaction_id']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        amount: _num(json['amount']),
        type: json['type'] as String? ?? 'mosque_sadaqa',
        status: TxStatus.fromString(json['status'] as String? ?? 'pending'),
        mosqueId: _int(json['mosque_id']),
        mosqueName: json['mosque_name'] as String? ?? '',
        campaignTitle: json['campaign_title'] as String?,
        subscriptionId: json['subscription_id'] == null ? null : _int(json['subscription_id']),
        receiptId: json['receipt_id'] == null ? null : _int(json['receipt_id']),
      );

  @override
  List<Object?> get props => [transactionId, createdAt, amount, type, status, mosqueId, mosqueName, campaignTitle, subscriptionId, receiptId];
}

/// A donor's active recurring gift to a mosque (`donation_subscriptions`).
class MyMosqueSubscription extends Equatable {
  final int id;
  final int mosqueId;
  final String? mosqueName;
  final double amount;
  final String currency;
  final DonationFrequency frequency;
  final SubscriptionStatus status;
  final String type; // mosque_sadaqa | mosque_membership
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  const MyMosqueSubscription({
    required this.id,
    required this.mosqueId,
    this.mosqueName,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.status,
    required this.type,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });

  factory MyMosqueSubscription.fromJson(Json json) => MyMosqueSubscription(
        id: _int(json['id']),
        mosqueId: _int(json['mosque_id']),
        mosqueName: (json['mosques'] as Map?)?['name'] as String?,
        amount: _num(json['amount']),
        currency: json['currency'] as String? ?? 'EUR',
        frequency: DonationFrequency.fromInterval(json['interval'] as String?),
        status: SubscriptionStatus.fromString(json['status'] as String?),
        type: json['type'] as String? ?? 'mosque_sadaqa',
        currentPeriodEnd: DateTime.tryParse(json['current_period_end']?.toString() ?? '')?.toLocal(),
        cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, mosqueId, mosqueName, amount, currency, frequency, status, type, currentPeriodEnd, cancelAtPeriodEnd];
}

/// `mosque_receipts` row (+ signed URL when freshly generated).
class MosqueReceipt extends Equatable {
  final int id;
  final int mosqueId;
  final String userId;
  final int? transactionId;
  final int year;
  final String number;
  final double amount;
  final String storagePath;
  final DateTime createdAt;
  final String? url;

  /// `tax_receipt` (the real thing) or `donation_attestation` (neutral proof,
  /// explicitly not a tax document). See docs/TAX_RECEIPTS_MULTI_COUNTRY.md
  final String kind;
  final String currency;
  final String? countryCode;
  final String? templateKey;
  final String? templateVersion;
  final DateTime? revokedAt;

  bool get isTaxReceipt => kind == MosqueReceipt.kindTax;
  bool get isRevoked => revokedAt != null;

  static const kindTax = 'tax_receipt';
  static const kindAttestation = 'donation_attestation';

  const MosqueReceipt({
    required this.id,
    required this.mosqueId,
    required this.userId,
    this.transactionId,
    required this.year,
    required this.number,
    required this.amount,
    required this.storagePath,
    required this.createdAt,
    this.url,
    this.kind = MosqueReceipt.kindTax,
    this.currency = 'EUR',
    this.countryCode,
    this.templateKey,
    this.templateVersion,
    this.revokedAt,
  });

  factory MosqueReceipt.fromJson(Json json) => MosqueReceipt(
        id: _int(json['id']),
        mosqueId: _int(json['mosque_id']),
        userId: json['user_id'] as String? ?? '',
        transactionId: json['transaction_id'] == null ? null : _int(json['transaction_id']),
        year: _int(json['year']),
        number: json['number'] as String? ?? '',
        amount: _num(json['amount']),
        storagePath: json['storage_path'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        kind: json['kind'] as String? ?? MosqueReceipt.kindTax,
        currency: json['currency'] as String? ?? 'EUR',
        countryCode: json['country_code'] as String?,
        templateKey: json['template_key'] as String?,
        templateVersion: json['template_version'] as String?,
        revokedAt: DateTime.tryParse(json['revoked_at']?.toString() ?? '')?.toLocal(),
      );

  @override
  List<Object?> get props => [
        id, mosqueId, userId, transactionId, year, number, amount, storagePath, createdAt, url,
        kind, currency, countryCode, templateKey, templateVersion, revokedAt,
      ];
}

/// Result of `generate-mosque-receipt`.
class GeneratedReceipt {
  const GeneratedReceipt({
    required this.receiptId,
    required this.amount,
    this.number,
    this.url,
    this.kind = MosqueReceipt.kindTax,
    this.currency = 'EUR',
  });
  final int receiptId;
  final double amount;
  final String? number;
  final String? url;
  final String kind;
  final String currency;
}

/// Phase-1 result of `create-mosque-payment-intent` / `create-mosque-subscription`.
class MosqueCreatedPayment {
  const MosqueCreatedPayment({
    required this.clientSecret,
    required this.stripeAccountId,
    required this.amountCharged,
    this.transactionId,
    this.subscriptionId,
    this.customerId,
    this.ephemeralKeySecret,
  });

  final String clientSecret;
  final String stripeAccountId;
  final double amountCharged;
  final int? transactionId;
  final int? subscriptionId;
  final String? customerId;
  final String? ephemeralKeySecret;
}


// ── Tax receipts — country regime, issuer readiness, donor fiscal identity ──
// Mirrors public.tax_regimes + fn_mosque_tax_readiness.
// See docs/TAX_RECEIPTS_MULTI_COUNTRY.md

/// Why a mosque cannot (yet) issue tax receipts. The server is the source of
/// truth: these are the codes `fn_mosque_tax_readiness` returns in `missing`.
enum TaxBlocker {
  mosqueNotApproved,
  legalName,
  addressLine,
  postalCode,
  city,
  legalId,
  signatory,
  unknown;

  static TaxBlocker parse(String raw) {
    if (raw == 'mosque_not_approved') return TaxBlocker.mosqueNotApproved;
    if (raw == 'legal_id_missing') return TaxBlocker.legalId;
    if (raw == 'signatory_missing') return TaxBlocker.signatory;
    if (raw.startsWith('missing_field:')) {
      return switch (raw.substring('missing_field:'.length)) {
        'legal_name' => TaxBlocker.legalName,
        'address_line' => TaxBlocker.addressLine,
        'postal_code' => TaxBlocker.postalCode,
        'city' => TaxBlocker.city,
        _ => TaxBlocker.unknown,
      };
    }
    return TaxBlocker.unknown;
  }
}

/// What the country allows, and what is still missing before the right can be
/// granted. Drives the whole tax settings screen.
class MosqueTaxReadiness extends Equatable {
  const MosqueTaxReadiness({
    this.country = 'FR',
    this.regimeKind = 'none',
    this.supported = false,
    this.enabled = false,
    this.ready = false,
    this.requiresSignature = false,
    this.annualOnly = false,
    this.legalRef,
    this.templateKey,
    this.templateVersion,
    this.minAmount,
    this.blockers = const [],
  });

  final String country;

  /// `receipt` | `reclaim_by_charity` | `none`.
  final String regimeKind;

  /// A validated renderer exists for this country.
  final bool supported;
  final bool enabled;
  final bool ready;
  final bool requiresSignature;
  final bool annualOnly;
  final String? legalRef;
  final String? templateKey;
  final String? templateVersion;
  final double? minAmount;
  final List<TaxBlocker> blockers;

  /// Receipts exist in this country but Nour has not shipped the template yet.
  bool get notYetAvailable => !supported && regimeKind == 'receipt';

  /// The country has no donor-side receipt at all (UK Gift Aid).
  bool get notReceiptBased => regimeKind == 'reclaim_by_charity' || regimeKind == 'none';

  bool get canToggle => supported && regimeKind == 'receipt' && (ready || enabled);

  factory MosqueTaxReadiness.fromJson(Json json) => MosqueTaxReadiness(
        country: json['country'] as String? ?? 'FR',
        regimeKind: json['kind'] as String? ?? 'none',
        supported: json['supported'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? false,
        ready: json['ready'] as bool? ?? false,
        requiresSignature: json['requires_signature'] as bool? ?? false,
        annualOnly: json['annual_only'] as bool? ?? false,
        legalRef: json['legal_ref'] as String?,
        templateKey: json['template_key'] as String?,
        templateVersion: json['template_version'] as String?,
        minAmount: json['min_amount'] == null ? null : _num(json['min_amount']),
        blockers: (json['missing'] as List?)
                ?.map((e) => TaxBlocker.parse(e.toString()))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [
        country, regimeKind, supported, enabled, ready, requiresSignature, annualOnly,
        legalRef, templateKey, templateVersion, minAmount, blockers,
      ];
}

/// Row of `public.donor_tax_profiles`: the donor's name and postal address,
/// mandatory on a French receipt and nowhere else in the app.
class DonorTaxProfile extends Equatable {
  const DonorTaxProfile({
    this.fullName = '',
    this.addressLine = '',
    this.postalCode = '',
    this.city = '',
    this.countryCode = 'FR',
  });

  final String fullName;
  final String addressLine;
  final String postalCode;
  final String city;
  final String countryCode;

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      addressLine.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty &&
      city.trim().isNotEmpty;

  DonorTaxProfile copyWith({
    String? fullName,
    String? addressLine,
    String? postalCode,
    String? city,
    String? countryCode,
  }) =>
      DonorTaxProfile(
        fullName: fullName ?? this.fullName,
        addressLine: addressLine ?? this.addressLine,
        postalCode: postalCode ?? this.postalCode,
        city: city ?? this.city,
        countryCode: countryCode ?? this.countryCode,
      );

  factory DonorTaxProfile.fromJson(Json json) => DonorTaxProfile(
        fullName: json['full_name'] as String? ?? '',
        addressLine: json['address_line'] as String? ?? '',
        postalCode: json['postal_code'] as String? ?? '',
        city: json['city'] as String? ?? '',
        countryCode: json['country_code'] as String? ?? 'FR',
      );

  Json toJson() => {
        'full_name': fullName.trim(),
        'address_line': addressLine.trim(),
        'postal_code': postalCode.trim(),
        'city': city.trim(),
        'country_code': countryCode,
      };

  @override
  List<Object?> get props => [fullName, addressLine, postalCode, city, countryCode];
}

/// One (mosque, year) the signed-in donor gave to — drives the donor-side
/// "get my document" list. Mirrors `fn_my_mosque_donation_years`.
class MosqueDonationYear extends Equatable {
  const MosqueDonationYear({
    required this.mosqueId,
    required this.mosqueName,
    required this.year,
    required this.total,
    this.currency = 'EUR',
    this.gifts = 0,
    this.countryCode = 'FR',
    this.canIssue = false,
    this.regimeKind = 'none',
    this.regimeSupported = false,
  });

  final int mosqueId;
  final String mosqueName;
  final int year;
  final double total;
  final String currency;
  final int gifts;
  final String countryCode;
  final bool canIssue;
  final String regimeKind;
  final bool regimeSupported;

  bool get isClosedYear => year < DateTime.now().year;

  /// A tax receipt is only offered for a closed year, in a supported
  /// receipt-based country, by a mosque that holds the right.
  bool get taxReceiptAvailable =>
      canIssue && regimeSupported && regimeKind == 'receipt' && isClosedYear;

  factory MosqueDonationYear.fromJson(Json json) => MosqueDonationYear(
        mosqueId: _int(json['mosque_id']),
        mosqueName: json['mosque_name'] as String? ?? '',
        year: _int(json['year']),
        total: _num(json['total']),
        currency: json['currency'] as String? ?? 'EUR',
        gifts: _int(json['gifts']),
        countryCode: json['country_code'] as String? ?? 'FR',
        canIssue: json['can_issue'] as bool? ?? false,
        regimeKind: json['regime_kind'] as String? ?? 'none',
        regimeSupported: json['regime_supported'] as bool? ?? false,
      );

  @override
  List<Object?> get props =>
      [mosqueId, mosqueName, year, total, currency, gifts, countryCode, canIssue, regimeKind, regimeSupported];
}

/// Aggregates a French association needs for form 2070-SD.
class MosqueTaxYearSummary extends Equatable {
  const MosqueTaxYearSummary({
    required this.year,
    this.receiptsCount = 0,
    this.donorsCount = 0,
    this.total = 0,
    this.currency = 'EUR',
  });

  final int year;
  final int receiptsCount;
  final int donorsCount;
  final double total;
  final String currency;

  factory MosqueTaxYearSummary.fromJson(Json json) => MosqueTaxYearSummary(
        year: _int(json['year']),
        receiptsCount: _int(json['receipts_count']),
        donorsCount: _int(json['donors_count']),
        total: _num(json['total']),
        currency: json['currency'] as String? ?? 'EUR',
      );

  @override
  List<Object?> get props => [year, receiptsCount, donorsCount, total, currency];
}
