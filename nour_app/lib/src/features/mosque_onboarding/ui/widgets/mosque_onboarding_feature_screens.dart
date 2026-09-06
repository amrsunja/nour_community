import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../state_management/mosque_onboarding_provider.dart';
import 'mosque_onboarding_scaffold.dart';

/// "Made for mosque announcements" — 4 post-type tiles (Figma Onboarding 24).
class MosqueOnboardingAnnouncementsScreen extends ConsumerWidget {
  const MosqueOnboardingAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);

    final tiles = [
      _Tile(l10n.mosque_post_type_event, l10n.mosque_post_type_event_hint, Icons.event, const Color(0xff1F6FEB)),
      _Tile(l10n.mosque_post_type_volunteering, l10n.mosque_post_type_volunteering_hint, Icons.volunteer_activism_outlined, const Color(0xff1F8A5B)),
      _Tile(l10n.mosque_post_type_highlight, l10n.mosque_post_type_highlight_hint, Icons.photo_outlined, const Color(0xff7C4DFF)),
      _Tile(l10n.mosque_post_type_janaza, l10n.mosque_post_type_janaza_hint, Icons.nights_stay_outlined, const Color(0xff3A4A6B)),
    ];

    return MosqueOnboardingStepScaffold(
      centered: true,
      children: [
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          beginScale: 0.9,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [for (final t in tiles) t],
          ),
        ),
        const SizedBox(height: 40),
        MosqueOnboardingHeadline(
          title: l10n.mosque_onboarding_feature_1_title,
          description: l10n.mosque_onboarding_feature_1_description,
        ),
      ],
      bottom: UIButton.primary(
        label: l10n.common_continue,
        fullWidth: true,
        onTap: presenter.next,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.title, this.subtitle, this.icon, this.color);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: UIColorsToken.white, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.white.withValues(alpha: .8))),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Raise funds the trusted way" (Figma Onboarding 16).
class MosqueOnboardingFundsScreen extends ConsumerWidget {
  const MosqueOnboardingFundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = UITheme.of(context);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);

    return MosqueOnboardingStepScaffold(
      centered: true,
      children: [
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          beginScale: 0.9,
          child: Transform.rotate(
            angle: -0.08,
            child: UICard(
              padding: const EdgeInsets.all(20),
              colors: const [Color(0xff2C3427), Color(0xff1A1A1A)],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('€103,570', style: theme.typo.inter.hero.copyWith(color: UIColorsToken.white)),
                  Text(l10n.mosque_admin_total_raised_year,
                      style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: UIProgressLine(current: 42, total: 100, fillColor: UIColorsToken.textParagraph)),
                      const SizedBox(width: 6),
                      Expanded(child: UIProgressLine(current: 100, total: 100, fillColor: UIColorsToken.textYellow)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Stat('1,583', l10n.mosque_admin_donors),
                      _Stat('87', l10n.mosque_admin_recurring),
                      _Stat('65€', l10n.mosque_admin_avg_gift),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        MosqueOnboardingHeadline(
          title: l10n.mosque_onboarding_feature_2_title,
          description: l10n.mosque_onboarding_feature_2_description,
        ),
      ],
      bottom: UIButton.primary(label: l10n.common_continue, fullWidth: true, onTap: presenter.next),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
        Text(label, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
      ],
    );
  }
}

/// "A calendar that reflects your imam" (Figma Onboarding 28).
class MosqueOnboardingCalendarScreen extends ConsumerWidget {
  const MosqueOnboardingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = UITheme.of(context);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);

    return MosqueOnboardingStepScaffold(
      centered: true,
      children: [
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          beginScale: 0.9,
          child: Center(
            child: SizedBox(
              width: 260,
              child: UICard(
                padding: EdgeInsets.zero,
                color: UIColorsToken.black80,
                disableBorder: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Assets.images.prayerTimeIsha.image(fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.notifications_prayer_isha,
                                style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('22:34', style: theme.typo.inter.hero.copyWith(color: UIColorsToken.white)),
                                const SizedBox(width: 6),
                                Text('+10', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                              ],
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        MosqueOnboardingHeadline(
          title: l10n.mosque_onboarding_feature_3_title,
          description: l10n.mosque_onboarding_feature_3_description,
        ),
      ],
      bottom: UIButton.primary(label: l10n.common_continue, fullWidth: true, onTap: presenter.next),
    );
  }
}
