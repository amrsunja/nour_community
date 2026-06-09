import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/dhikr/ui/state_management/dhikr_provider.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/impact/ui/state_management/impact_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_project_card_widget.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/tools/ui/state_management/prayer_times_provider.dart';
import 'package:nour/src/features/tools/ui/widgets/next_prayer_widget.dart';

@RoutePage()
class DashboardPage extends HookConsumerWidget {
  const DashboardPage({super.key});

  /// Builds Mon→Sun day states for the current week from the authoritative
  /// streak: a day is [validated] when its calendar date falls inside the
  /// streak window `[lastStreakDate - (streak-1) … lastStreakDate]`. Past
  /// days outside that window are [missed], future days [upcoming]. Today is
  /// [validated] if already counted, otherwise [actual].
  List<UIStreakDayState> _weekStates(int streak, DateTime? lastStreakDate) {
    final today = DateUtils.dateOnly(DateTime.now());
    final todayIdx = today.weekday - 1; // 0 = Monday
    final weekStart = DateUtils.addDaysToDate(today, -todayIdx);

    // Normalize to UTC midnight so day diffs are exact (DST-safe).
    final last = lastStreakDate == null
        ? null
        : DateTime.utc(
            lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);

    bool isValidated(DateTime day) {
      if (last == null || streak <= 0) return false;
      final d = DateTime.utc(day.year, day.month, day.day);
      if (d.isAfter(last)) return false;
      return last.difference(d).inDays < streak;
    }

    return List.generate(7, (i) {
      if (i > todayIdx) return UIStreakDayState.upcoming;
      final day = DateUtils.addDaysToDate(weekStart, i);
      final validated = isValidated(day);
      if (i == todayIdx) {
        return validated ? UIStreakDayState.validated : UIStreakDayState.actual;
      }
      return validated ? UIStreakDayState.validated : UIStreakDayState.missed;
    });
  }

  static AssetGenImage _slotImage(PrayerSlot slot) {
    final images = Assets.images;
    switch (slot) {
      case PrayerSlot.fajr:
        return images.prayerTimeFajr;
      case PrayerSlot.dhuhr:
        return images.prayerTimeDuhr;
      case PrayerSlot.asr:
        return images.prayerTimeAsr;
      case PrayerSlot.maghrib:
        return images.prayerTimeMaghrib;
      case PrayerSlot.isha:
        return images.prayerTimeIsha;
    }
  }

  static String _slotTitle(AppLocale l10n, PrayerSlot slot) {
    switch (slot) {
      case PrayerSlot.fajr:
        return l10n.notifications_prayer_fajr;
      case PrayerSlot.dhuhr:
        return l10n.notifications_prayer_dhuhr;
      case PrayerSlot.asr:
        return l10n.notifications_prayer_asr;
      case PrayerSlot.maghrib:
        return l10n.notifications_prayer_maghrib;
      case PrayerSlot.isha:
        return l10n.notifications_prayer_isha;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final analytics = ref.read(analyticsRepoProvider);
    final dhikrState = ref.watch(dhikrProvider);
    final profile = ref.watch(profileProvider).profile;
    final streak = profile?.currentStreak ?? 0;
    final dhikrsCount = dhikrState.dhikrs
        .fold(0, (count, d) => count + dhikrState.currentCountOf(d.id));
    final dhikrGoal = 33;

    final prayerState = ref.watch(prayerTimesProvider);
    // Top 3 impact projects for the dashboard carousel; the rest live behind
    // "See all projects" on the Impact tab.
    final impactProjects =
        ref.watch(impactProvider).projects.take(3).toList();
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(prayerTimesProvider.notifier).init();
        // App-lifetime provider; init() is a no-op once the Impact tab loaded.
        ref.read(impactProvider.notifier).init();
      });
      return null;
    }, const []);

    // Re-sync when returning from background: Dart timers don't fire while the
    // app is suspended, so a prayer may have elapsed off-screen.
    final lifecycle = useAppLifecycleState();
    useEffect(() {
      if (lifecycle == AppLifecycleState.resumed) {
        ref.read(prayerTimesProvider.notifier).refresh();
      }
      return null;
    }, [lifecycle]);

    return Scaffold(
      appBar: UIProfileAppBar(
        name: profile?.name ?? l10n.profile_guest,
        avatarUrl: profile?.avatar,
        greeting: l10n.common_assalamu_alaykum,
        onAvatarTap: () => ref.read(navigationServicesProvider).toProfile(),
        trailing: UIStreakCard(current: streak, total: 7),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIStreakWeek(
                states: _weekStates(streak, profile?.lastStreakDate),
                streakCount: streak,
              ),
              const UISpace.vert(16),
              UIAppearAnimation(
                child: UiRepeatShimerAnimation(
                  child: UIDailyAjrCard(
                    title: l10n.dashboard_daily_dhikr_goal,
                    subtitle: l10n.dashboard_dhikr_goal_progress(dhikrsCount, dhikrGoal),
                    currentCount: dhikrsCount,
                    totalCount: dhikrGoal,
                    buttonTitle: l10n.dashboard_start_dhikr,
                    onTap: () {
                      AppVibrations.buttonClick();
                      analytics.trackFeatureOpen('dhikr', source: 'dashboard');
                      ref.read(navigationServicesProvider).toDhikrsList();
                    },
                  ),
                ),
              ),

              // ---------------- Quick actions ----------------
              const UISpace.vert(24),
              _SectionHeader(title: l10n.dashboard_quick_actions),
              const UISpace.vert(12),
              UIAppearAnimation(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        asset: Assets.images.illustration12,
                        label: l10n.tools_daily_ayah,
                        points: 5,
                        onTap: () {
                          analytics.trackDailyVerseView();
                          nav.toDailyAyah();
                        },
                      ),
                    ),
                    const UISpace.horz(12),
                    Expanded(
                      child: _QuickActionCard(
                        asset: Assets.images.illustration19,
                        label: l10n.tools_daily_dua,
                        points: 5,
                        onTap: () {
                          analytics.trackDailyDuaRecite(period: 'daily');
                          nav.toDailyDua();
                        },
                      ),
                    ),
                    const UISpace.horz(12),
                    Expanded(
                      child: _QuickActionCard(
                        asset: Assets.images.illustration14,
                        label: l10n.tools_daily_quiz,
                        points: 10,
                        onTap: () {
                          analytics.trackFeatureOpen('quiz', source: 'dashboard');
                          nav.toQuiz();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- Next prayer ----------------
              const UISpace.vert(24),
              if (prayerState.nextSlot != null &&
                  prayerState.nextTime != null)
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 150),
                  child: NextPrayerWidget(
                    nextPrayerLabel: l10n.dashboard_next_prayer,
                    viewAllLabel: l10n.dashboard_view_all,
                    prayerName: _slotTitle(l10n, prayerState.nextSlot!),
                    countdownTarget: prayerState.nextTime!,
                    backgroundImage: _slotImage(prayerState.nextSlot!),
                    onViewAll: nav.toPrayerTimes,
                  ),
                ),

              // ---------------- Quick tools ----------------
              const UISpace.vert(24),
              _SectionHeader(
                title: l10n.dashboard_quick_tools,
                actionLabel: l10n.dashboard_see_all,
                // Tools is tab index 3 in the home AutoTabsRouter.
                onAction: () => context.tabsRouter.setActiveIndex(3),
              ),
              const UISpace.vert(12),
              UIAppearAnimation(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickToolCard(
                        asset: Assets.images.illustration15,
                        label: l10n.tools_qibla_finder,
                        onTap: nav.toQiblaFinder,
                      ),
                    ),
                    const UISpace.horz(12),
                    Expanded(
                      child: _QuickToolCard(
                        asset: Assets.images.illustration16,
                        label: l10n.tools_prayer_times,
                        onTap: nav.toPrayerTimes,
                      ),
                    ),
                    const UISpace.horz(12),
                    Expanded(
                      child: _QuickToolCard(
                        asset: Assets.images.illustration18,
                        label: l10n.tools_hijri_calendar,
                        onTap: nav.toHijriCalendar,
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- Nour impact ----------------
              if (impactProjects.isNotEmpty) ...[
                const UISpace.vert(24),
                _SectionHeader(
                  title: l10n.dashboard_impact_projects,
                  actionLabel: l10n.dashboard_see_all_projects,
                  // Impact is tab index 2 in the home AutoTabsRouter.
                  onAction: () => context.tabsRouter.setActiveIndex(2),
                ),
                const UISpace.vert(12),
                UIAppearAnimation(
                  delay: const Duration(milliseconds: 250),
                  child: _ImpactProjectsCarousel(
                    projects: impactProjects,
                    onProjectTap: (project) =>
                        nav.toImpactProjectDetail(projectId: project.id),
                  ),
                ),
              ],

              UISpace.vert(100)
            ],
          ),
        ),
      ),
    );
  }
}

/// Section title row with an optional trailing text action ("View all" / "See all").
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.typo.inter.title.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (actionLabel != null)
          UITap(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: theme.typo.inter.bodyMedium.copyWith(
                color: UIColorsToken.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// Quick-action tile: label top-left, points pill top-right, glowing
/// illustration filling the body.
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.asset,
    required this.label,
    required this.points,
    this.onTap,
  });

  final AssetGenImage asset;
  final String label;
  final int points;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UICard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      color: UIColorsToken.black80,
      disableBorder: true,
      borderRadius: 10,
      shadows: [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.bodyMedium.copyWith(
                    color: UIColorsToken.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _PointsBadge(points: points),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.5,
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: UIGlowingBlock(
                  shadow: UIShadowToken.texts,
                  child: asset.image(
                    height: 56,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: UIColorsToken.bgTertiaryGreen,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '+$points',
        style: theme.typo.inter.bodySmall.copyWith(
          color: UIColorsToken.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Horizontal, swipeable carousel of the top impact projects. Each page is an
/// [ImpactProjectCardWidget] with a peek of the next card; a page-dots slider
/// sits underneath.
class _ImpactProjectsCarousel extends HookWidget {
  const _ImpactProjectsCarousel({
    required this.projects,
    required this.onProjectTap,
  });

  final List<ImpactProjectModel> projects;
  final ValueChanged<ImpactProjectModel> onProjectTap;

  static const double _cardHeight = 230;

  @override
  Widget build(BuildContext context) {
    final controller = usePageController(viewportFraction: 0.88);
    final pageIndex = useState(0);

    useEffect(() {
      void listener() {
        final page = controller.page?.round() ?? 0;
        if (page != pageIndex.value) pageIndex.value = page;
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Column(
      children: [
        SizedBox(
          height: _cardHeight,
          child: PageView.builder(
            controller: controller,
            padEnds: false,
            itemCount: projects.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.only(
                  right: i == projects.length - 1 ? 0 : 12,
                ),
                child: ImpactProjectCardWidget(
                  project: projects[i],
                  onTap: () => onProjectTap(projects[i]),
                ),
              );
            },
          ),
        ),
        if (projects.length > 1) ...[
          const UISpace.vert(12),
          _CarouselDots(count: projects.length, activeIndex: pageIndex.value),
        ],
      ],
    );
  }
}

/// Page-position slider: the active page is a white pill, the others dimmed
/// dots.
class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? UIColorsToken.white
                : UIColorsToken.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

/// Compact tool tile: centered glowing icon with a label beneath.
class _QuickToolCard extends StatelessWidget {
  const _QuickToolCard({
    required this.asset,
    required this.label,
    this.onTap,
  });

  final AssetGenImage asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UICard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      color: UIColorsToken.black80,
      disableBorder: true,
      shadows: [],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UIGlowingBlock(
            shadow: UIShadowToken.texts,
            child: asset.image(
              height: 44,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.white,
            ),
          ),
        ],
      ),
    );
  }
}
