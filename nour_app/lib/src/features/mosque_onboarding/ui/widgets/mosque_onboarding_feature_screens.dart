import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

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
      _Tile(l10n.mosque_post_type_event, l10n.mosque_post_type_event_hint, UIIconsToken.icons.calendar, const Color(0xff1F6FEB)),
      _Tile(l10n.mosque_post_type_volunteering, l10n.mosque_post_type_volunteering_hint, UIIconsToken.icons.hand, const Color(0xff1F8A5B)),
      _Tile(l10n.mosque_post_type_highlight, l10n.mosque_post_type_highlight_hint, UIIconsToken.icons.gallery, const Color(0xff7C4DFF)),
      _Tile(l10n.mosque_post_type_janaza, l10n.mosque_post_type_janaza_hint, UIIconsToken.icons.janaza, const Color(0xff3A4A6B)),
    ];

    return MosqueOnboardingStepScaffold(
      centered: true,
      bottom: UIButton.primary(
        label: l10n.common_continue,
        fullWidth: true,
        onTap: presenter.next,
      ),
      children: [
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          beginScale: 0.9,
          child: GridView.count(
          padding: EdgeInsetsGeometry.only(
            left: kPageHorzPadding,
            right: kPageHorzPadding,
            top: 60
          ),
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [for (final t in tiles) t],
          ),
        ),
        const SizedBox(height: 40),
        MosqueOnboardingHeadline(
          title: l10n.mosque_onboarding_feature_1_title,
          description: l10n.mosque_onboarding_feature_1_description,
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.title, this.subtitle, this.icon, this.color);
  final String title;
  final String subtitle;
  final String icon;
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
          UIIcon(icon, color: UIColorsToken.white, size: 22),
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

/// "Raise funds the trusted way" (Figma Onboarding 16): three
/// [UIMosqueDonationInformationCard]s fanned out in a stack over a soft green
/// glow. Demo figures only.
class MosqueOnboardingFundsScreen extends ConsumerWidget {
  const MosqueOnboardingFundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);

    final card = UIMosqueDonationInformationCard(
      total: '€103,570',
      totalLabel: l10n.mosque_admin_total_raised_year,
      growthLabel: l10n.mosque_donation_card_growth('+24%', '2025'),
      supportAmount: '43,500€',
      supportLabel: l10n.mosque_donation_card_support,
      campaignsAmount: '60,070€',
      campaignsLabel: l10n.mosque_admin_stat_campaigns,
      supportRatio: 0.42,
      stats: [
        UIMosqueDonationStat(value: '1,583', label: l10n.mosque_admin_donors),
        UIMosqueDonationStat(value: '87', label: l10n.mosque_admin_recurring),
        UIMosqueDonationStat(value: '65€', label: l10n.mosque_admin_avg_gift),
      ],
    );

    return MosqueOnboardingStepScaffold(
      centered: true,
      bottom: UIButton.primary(label: l10n.common_continue, fullWidth: true, onTap: presenter.next),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: kPageHorzPadding,
            right: kPageHorzPadding,
            top: 60
          ),
          child: _FundsCardsStack(card: card),
        ),
        const SizedBox(height: 40),
        MosqueOnboardingHeadline(
          title: l10n.mosque_onboarding_feature_2_title,
          description: l10n.mosque_onboarding_feature_2_description,
        ),
      ],
    );
  }
}

/// Fan of three identical cards: two dimmed copies peek out behind the front
/// one (top-right / bottom-right), the whole stack tilted to the left.
class _FundsCardsStack extends StatelessWidget {
  const _FundsCardsStack({required this.card});

  final Widget card;

  // (angle rad, dx, dy, opacity, delay ms) — back → front.
  static const _layers = <(double, double, double, double, int)>[
    (-0.03, 14, 18, 0.45, 100),
    (-0.10, 6, 8, 0.70, 220),
    (-0.14, 0, 0, 1.0, 340),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (final (angle, dx, dy, opacity, delay) in _layers)
            UIAppearAnimation(
              delay: Duration(milliseconds: delay),
              duration: const Duration(milliseconds: 800),
              offsetY: 32,
              beginScale: 0.9,
              child: Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.rotate(
                  angle: angle,
                  child: Opacity(opacity: opacity, child: card),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "A calendar that reflects your imam" (Figma Onboarding 28).
class MosqueOnboardingCalendarScreen extends ConsumerWidget {
  const MosqueOnboardingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);

    return MosqueOnboardingStepScaffold(
      centered: true,
      bottom: UIButton.primary(label: l10n.common_continue, fullWidth: true, onTap: presenter.next),
      children: [
        UISpace.vert(60),
        Stack(
          children: [
            Opacity(
            opacity: 0.3,
              child: Transform.translate(
                offset: Offset(20, 20),
                child: PrayerTimeOverviewWidget(
                  prayerName: l10n.notifications_prayer_asr,
                  image: Assets.images.prayerTimeAsr,
                )
              ),
            ),
            Opacity(
            opacity: 0.7,
              child: Transform.translate(
                offset: Offset(10, 10),
                child: PrayerTimeOverviewWidget(
                  prayerName: l10n.notifications_prayer_maghrib,
                  image: Assets.images.prayerTimeMaghrib,
                )
              ),
            ),
            PrayerTimeOverviewWidget(
              prayerName: l10n.notifications_prayer_isha,
              image: Assets.images.prayerTimeIsha,
            ),
          ],
        ),
        const SizedBox(height: 48),
        MosqueOnboardingHeadline(
          title: l10n.mosque_onboarding_feature_3_title,
          description: l10n.mosque_onboarding_feature_3_description,
        ),
      ],
    );
  }
}

class PrayerTimeOverviewWidget extends StatelessWidget {
  const PrayerTimeOverviewWidget({
    super.key,
    required this.prayerName,
    required this.image
  });

  final String prayerName;
  final AssetGenImage image;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UIAppearAnimation(
      delay: const Duration(milliseconds: 100),
      beginScale: 0.9,
      child: Center(
        child: SizedBox(
          width: 190,
          child: UICard(
            padding: EdgeInsets.zero,
            color: UIColorsToken.black80,
            disableBorder: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: image.image(fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prayerName,
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
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
