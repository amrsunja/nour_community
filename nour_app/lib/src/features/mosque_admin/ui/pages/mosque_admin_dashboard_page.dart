import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_dashboard_stats_model.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_header.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_post_card.dart';

import '../state_management/mosque_admin_dashboard_provider.dart';

/// Admin Dashboard tab (Figma "Dashboard - Nour mosques").
@RoutePage()
class MosqueAdminDashboardPage extends HookConsumerWidget {
  const MosqueAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final mosque = ref.watch(myMosqueProvider).mosque;
    final presenter = ref.read(mosqueAdminDashboardProvider.notifier);
    final state = ref.watch(mosqueAdminDashboardProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.load());
      return null;
    }, const []);

    final stats = state.stats ?? const MosqueDashboardStats();
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: UIColorsToken.textYellow,
          onRefresh: presenter.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    UITap(
                      onTap: () => context.router.push(ProfileRoute()),
                      child: mosque == null ? const SizedBox(width: 44) : MosqueLogo(mosque: mosque, size: 44, radius: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.common_assalamu_alaykum, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                          Text(mosque?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                        ],
                      ),
                    ),
                    UITap(
                      onTap: () => context.router.push(const MosqueAdminNotificationsRoute()),
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.notifications_none, color: UIColorsToken.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stats.attentionCount > 0)
                  UITap(
                    onTap: () => context.tabsRouter.setActiveIndex(2),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: UIColorsToken.red.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: UIColorsToken.red.withValues(alpha: .5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: UIColorsToken.red, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.mosque_admin_attention(stats.attentionCount), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                                Text(
                                  [
                                    if (stats.pendingEvents > 0) l10n.mosque_admin_pending_events(stats.pendingEvents),
                                    if (stats.campaignsEndingSoon > 0) l10n.mosque_admin_campaigns_ending(stats.campaignsEndingSoon),
                                  ].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: UIColorsToken.red, size: 18),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.mosque_admin_tab_community),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.favorite_border,
                        label: l10n.mosque_followers_title,
                        value: MosqueFormat.compact(stats.followersTotal),
                        delta: stats.followers7d,
                        caption: l10n.mosque_admin_last_7_days,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.workspace_premium_outlined,
                        label: l10n.mosque_members_title,
                        value: MosqueFormat.compact(stats.membersTotal),
                        delta: stats.members7d - stats.membersLeft7d,
                        caption: l10n.mosque_admin_last_7_days,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                UICard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.show_chart, size: 16, color: UIColorsToken.textParagraph),
                          const SizedBox(width: 6),
                          Text(l10n.mosque_admin_growth, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                          const SizedBox(width: 8),
                          _Delta(value: stats.growthPercent, suffix: '%'),
                          const Spacer(),
                          Text(l10n.mosque_admin_last_30_days, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: CustomPaint(
                          size: const Size(double.infinity, 110),
                          painter: _GrowthPainter(series: stats.growthSeries, base: stats.followersTotal - stats.followers30d),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d', lang).format(DateTime.now().subtract(const Duration(days: 30))),
                              style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                          Text(l10n.mosque_admin_today, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        ],
                      ),
                      if (stats.notifOpenRate != null) ...[
                        const SizedBox(height: 8),
                        Text(l10n.mosque_admin_open_rate(stats.notifOpenRate!.toStringAsFixed(0)),
                            style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                      ],
                    ],
                  ),
                ),
                if (stats.campaignsActive > 0) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _SectionTitle(l10n.mosque_admin_fundraising),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: UIColorsToken.bgTertiaryGreen, borderRadius: BorderRadius.circular(6)),
                        child: Text('${stats.campaignsActive}', style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  UICard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        for (final c in stats.campaigns)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(c.title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white))),
                                    Text('${(c.progress * 100).round()}%', style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow)),
                                    const SizedBox(width: 6),
                                    Text(l10n.mosque_campaign_days_left_short(c.daysLeft),
                                        style: theme.typo.inter.smallCaption.copyWith(color: c.daysLeft <= 2 ? UIColorsToken.red : UIColorsToken.textParagraph)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                UIProgressLine(current: c.collectedAmount, total: c.goalAmount, fillColor: UIColorsToken.textYellow),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionTitle(l10n.mosque_admin_recent_posts),
                const SizedBox(height: 12),
                if (state.recentPosts.isEmpty)
                  UICard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l10n.mosque_admin_no_posts, textAlign: TextAlign.center, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
                        const SizedBox(height: 12),
                        UIButton.primary(label: l10n.mosque_admin_create_post, fullWidth: true, onTap: () => context.router.push(const MosqueAdminCreatePostRoute())),
                      ],
                    ),
                  )
                else
                  for (final p in state.recentPosts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MosquePostCard(post: p, l10n: l10n, adminStats: true),
                    ),
                const SizedBox(height: 4),
                //UIButton.textual(label: l10n.mosque_admin_view_mosque, fullWidth: true, onTap: () => nav.toMosqueProfile(mosqueId: mosque?.id ?? 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: UITheme.of(context).typo.inter.title.copyWith(color: UIColorsToken.white));
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.delta, required this.caption});
  final IconData icon;
  final String label;
  final String value;
  final int delta;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UICard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: UIColorsToken.textParagraph),
              const SizedBox(width: 6),
              Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(value, style: theme.typo.inter.display.copyWith(color: UIColorsToken.white)),
              const SizedBox(width: 8),
              _Delta(value: delta),
            ],
          ),
          Text(caption, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.value, this.suffix = ''});
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final up = value >= 0;
    final color = up ? UIColorsToken.pastelGreen : UIColorsToken.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.north_east : Icons.south_east, size: 10, color: color),
          const SizedBox(width: 2),
          Text('${up ? '+' : ''}$value$suffix', style: theme.typo.inter.smallCaption.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Cumulative followers over the last 30 days, gold line + soft fill.
class _GrowthPainter extends CustomPainter {
  _GrowthPainter({required this.series, required this.base});
  final List<(DateTime, int)> series;
  final int base;

  @override
  void paint(Canvas canvas, Size size) {
    final today = DateTime.now();
    final points = <double>[];
    var acc = base < 0 ? 0 : base;
    final byDay = {for (final s in series) DateTime(s.$1.year, s.$1.month, s.$1.day): s.$2};
    for (var i = 30; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      acc += byDay[DateTime(d.year, d.month, d.day)] ?? 0;
      points.add(acc.toDouble());
    }
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - ((points[i] - minV) / range) * (size.height - 8) - 4;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [UIColorsToken.textYellow.withValues(alpha: .35), UIColorsToken.textYellow.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = UIColorsToken.textYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _GrowthPainter old) => old.series != series || old.base != base;
}
