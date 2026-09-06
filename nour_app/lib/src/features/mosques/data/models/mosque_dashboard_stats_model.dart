import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class MosqueCampaignSummary extends Equatable {
  final int id;
  final String title;
  final double goalAmount;
  final double collectedAmount;
  final int donorsCount;
  final DateTime endsAt;

  const MosqueCampaignSummary({
    required this.id,
    required this.title,
    required this.goalAmount,
    required this.collectedAmount,
    required this.donorsCount,
    required this.endsAt,
  });

  double get progress => goalAmount <= 0 ? 0 : (collectedAmount / goalAmount).clamp(0, 1);
  int get daysLeft {
    final d = endsAt.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  factory MosqueCampaignSummary.fromJson(Json json) => MosqueCampaignSummary(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        goalAmount: (json['goal_amount'] as num?)?.toDouble() ?? 0,
        collectedAmount: (json['collected_amount'] as num?)?.toDouble() ?? 0,
        donorsCount: json['donors_count'] as int? ?? 0,
        endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, title, goalAmount, collectedAmount, donorsCount, endsAt];
}

/// Result of `fn_mosque_dashboard_stats`.
class MosqueDashboardStats extends Equatable {
  final int followersTotal;
  final int followers7d;
  final int membersTotal;
  final int members7d;
  final int membersLeft7d;
  final int views30d;
  final int followers30d;
  final List<(DateTime, int)> growthSeries;
  final double? notifOpenRate;
  final int pendingEvents;
  final int campaignsActive;
  final int campaignsEndingSoon;
  final List<MosqueCampaignSummary> campaigns;

  const MosqueDashboardStats({
    this.followersTotal = 0,
    this.followers7d = 0,
    this.membersTotal = 0,
    this.members7d = 0,
    this.membersLeft7d = 0,
    this.views30d = 0,
    this.followers30d = 0,
    this.growthSeries = const [],
    this.notifOpenRate,
    this.pendingEvents = 0,
    this.campaignsActive = 0,
    this.campaignsEndingSoon = 0,
    this.campaigns = const [],
  });

  int get attentionCount => (pendingEvents > 0 ? 1 : 0) + (campaignsEndingSoon > 0 ? 1 : 0);

  /// Growth in % over 30 days (followers gained vs base).
  int get growthPercent {
    final base = followersTotal - followers30d;
    if (base <= 0) return followers30d > 0 ? 100 : 0;
    return ((followers30d / base) * 100).round();
  }

  factory MosqueDashboardStats.fromJson(Json json) => MosqueDashboardStats(
        followersTotal: (json['followers_total'] as num?)?.toInt() ?? 0,
        followers7d: (json['followers_7d'] as num?)?.toInt() ?? 0,
        membersTotal: (json['members_total'] as num?)?.toInt() ?? 0,
        members7d: (json['members_7d'] as num?)?.toInt() ?? 0,
        membersLeft7d: (json['members_left_7d'] as num?)?.toInt() ?? 0,
        views30d: (json['views_30d'] as num?)?.toInt() ?? 0,
        followers30d: (json['followers_30d'] as num?)?.toInt() ?? 0,
        growthSeries: ((json['growth_series'] as List?) ?? const [])
            .map((e) => (DateTime.parse(e['day'] as String), (e['followers'] as num).toInt()))
            .toList(),
        notifOpenRate: (json['notif_open_rate'] as num?)?.toDouble(),
        pendingEvents: (json['pending_events'] as num?)?.toInt() ?? 0,
        campaignsActive: (json['campaigns_active'] as num?)?.toInt() ?? 0,
        campaignsEndingSoon: (json['campaigns_ending_soon'] as num?)?.toInt() ?? 0,
        campaigns: ((json['campaigns'] as List?) ?? const [])
            .map((e) => MosqueCampaignSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [followersTotal, followers7d, membersTotal, members7d, membersLeft7d, views30d, followers30d, growthSeries, notifOpenRate, pendingEvents, campaignsActive, campaignsEndingSoon, campaigns];
}
