import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_post_model.dart';
import 'mosque_format.dart';
import 'mosque_information_tab.dart';

/// One post of the News feed (announcement / urgent / event / volunteering /
/// highlight / janaza) — Figma "Mosquée profile - News".
class MosquePostCard extends StatelessWidget {
  const MosquePostCard({
    super.key,
    required this.post,
    required this.l10n,
    this.onAttend,
    this.onApply,
    this.onSayDua,
    this.onShare,
    this.onAddToCalendar,
    this.onMenu,
    this.adminStats = false,
  });

  final MosquePostModel post;
  final AppLocale l10n;
  final VoidCallback? onAttend;
  final VoidCallback? onApply;
  final VoidCallback? onSayDua;
  final VoidCallback? onShare;
  final VoidCallback? onAddToCalendar;
  final VoidCallback? onMenu;
  /// Admin feed: show views / reactions / notified instead of CTAs.
  final bool adminStats;

  static (String, Color) badge(AppLocale l10n, MosquePostModel p) {
    if (p.isUrgent) return (l10n.mosque_post_urgent, UIColorsToken.red);
    return switch (p.type) {
      MosquePostType.announcement => (l10n.mosque_post_type_announcement, UIColorsToken.bgTertiaryGreen),
      MosquePostType.event => (l10n.mosque_post_type_event, const Color(0xff1F6FEB)),
      MosquePostType.volunteering => (l10n.mosque_post_type_volunteering, const Color(0xff1F8A5B)),
      MosquePostType.highlight => (l10n.mosque_post_type_highlight, const Color(0xff7C4DFF)),
      MosquePostType.janaza => (l10n.mosque_post_type_janaza, const Color(0xff3A4A6B)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final (label, color) = badge(l10n, post);
    final showBadge = post.isUrgent || post.type != MosquePostType.announcement;

    return UICard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                  child: Text(label, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
                ),
              const Spacer(),
              Text(MosqueFormat.timeAgo(post.publishedAt, l10n),
                  style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
              if (onMenu != null)
                UITap(
                  onTap: onMenu,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.more_vert, size: 18, color: UIColorsToken.textParagraph),
                  ),
                ),
            ],
          ),
          if (post.coverUrl != null && post.isHighlight) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: CachedNetworkImage(imageUrl: post.coverUrl!, fit: BoxFit.cover),
              ),
            ),
          ],
          if (post.isJanaza) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(color: UIColorsToken.black, borderRadius: BorderRadius.circular(10)),
              child: Text(
                'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: theme.typo.inter.display.copyWith(color: UIColorsToken.white),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (post.isEvent && post.eventDate != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: UIColorsToken.textYellow),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(MosqueFormat.monthShort(post.eventDate!, lang),
                          style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textYellow)),
                      Text('${post.eventDate!.day}', style: theme.typo.inter.title.copyWith(color: UIColorsToken.textYellow)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _TitleBody(post: post, l10n: l10n, lang: lang)),
              ],
            )
          else
            _TitleBody(post: post, l10n: l10n, lang: lang),
          if (!adminStats) ...[
            const SizedBox(height: 12),
            _Actions(post: post, l10n: l10n, onAttend: onAttend, onApply: onApply, onSayDua: onSayDua, onShare: onShare, onAddToCalendar: onAddToCalendar),
          ] else ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _Stat(Icons.remove_red_eye_outlined, MosqueFormat.compact(post.viewsCount)),
                const SizedBox(width: 12),
                if (post.isEvent)
                  _Stat(Icons.people_outline, l10n.mosque_post_attending(post.attendeesCount))
                else if (post.isVolunteering)
                  _Stat(Icons.people_outline, l10n.mosque_post_volunteers(post.applicantsCount))
                else if (post.isJanaza)
                  _Stat(Icons.favorite_border, l10n.mosque_post_duas(post.duasCount)),
                const SizedBox(width: 12),
                if (post.notifiedAt != null) _Stat(Icons.notifications_none, l10n.mosque_post_notified_all),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleBody extends StatelessWidget {
  const _TitleBody({required this.post, required this.l10n, required this.lang});
  final MosquePostModel post;
  final AppLocale l10n;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final metas = <(IconData, String)>[
      if (post.isVolunteering && post.volunteersNeeded != null) (Icons.people_outline, l10n.mosque_post_volunteers(post.volunteersNeeded!)),
      if ((post.isVolunteering || post.isEvent) && post.eventDate != null && !post.isEvent) (Icons.calendar_today_outlined, MosqueFormat.dayMonth(post.eventDate!, lang)),
      if (post.eventTime != null && !post.isJanaza) (Icons.access_time, MosqueFormat.hhmm(post.eventTime)),
      if (post.isEvent && (post.location ?? '').isNotEmpty) (Icons.location_on_outlined, post.location!),
      if (post.isEvent && (post.language ?? '').isNotEmpty) (Icons.language, MosqueInformationTab.languageName(post.language!)),
      if (post.isJanaza && post.afterPrayer != null)
        (Icons.access_time, l10n.mosque_post_after_prayer(_slotName(l10n, post), MosqueFormat.hhmm(post.eventTime))),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
        if ((post.body ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(post.body!, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
        ],
        if (metas.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final m in metas)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(m.$1, size: 13, color: UIColorsToken.textParagraph),
                    const SizedBox(width: 4),
                    Text(m.$2, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }

  static String _slotName(AppLocale l10n, MosquePostModel p) => switch (p.afterPrayer!.name) {
        'fajr' => l10n.notifications_prayer_fajr,
        'dhuhr' => l10n.notifications_prayer_dhuhr,
        'asr' => l10n.notifications_prayer_asr,
        'maghrib' => l10n.notifications_prayer_maghrib,
        _ => l10n.notifications_prayer_isha,
      };
}

class _Actions extends StatelessWidget {
  const _Actions({required this.post, required this.l10n, this.onAttend, this.onApply, this.onSayDua, this.onShare, this.onAddToCalendar});
  final MosquePostModel post;
  final AppLocale l10n;
  final VoidCallback? onAttend;
  final VoidCallback? onApply;
  final VoidCallback? onSayDua;
  final VoidCallback? onShare;
  final VoidCallback? onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    Widget share() => Expanded(
          child: UIButton.secondary(label: l10n.mosque_post_share, fullWidth: true, isSmall: true, onTap: onShare),
        );

    switch (post.type) {
      case MosquePostType.event:
        return Row(
          children: [
            Expanded(
              child: Text(l10n.mosque_post_attending(post.attendeesCount),
                  style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            ),
            if (onAddToCalendar != null)
              UITap(
                onTap: onAddToCalendar,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(border: Border.all(color: UIColorsToken.textYellow), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.event_available_outlined, color: UIColorsToken.textYellow, size: 20),
                ),
              ),
            if (post.attending)
              UIButton.secondary(label: l10n.mosque_post_attending_cta_done, isSmall: true, onTap: onAttend)
            else
              UIButton.primary(label: l10n.mosque_post_attend_cta, isSmall: true, onTap: onAttend),
          ],
        );
      case MosquePostType.volunteering:
        return Row(
          children: [
            share(),
            const SizedBox(width: 10),
            Expanded(
              child: post.applied
                  ? UIButton.secondary(label: l10n.mosque_post_applied, fullWidth: true, isSmall: true)
                  : UIButton.primary(label: l10n.mosque_post_apply, fullWidth: true, isSmall: true, onTap: onApply),
            ),
          ],
        );
      case MosquePostType.janaza:
        return Row(
          children: [
            Expanded(
              child: Text(l10n.mosque_post_duas(post.duasCount),
                  style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            ),
            post.duaSaid
                ? UIButton.secondary(label: l10n.mosque_post_dua_said, isSmall: true)
                : UIButton.secondary(label: l10n.mosque_post_say_dua, isSmall: true, onTap: onSayDua),
          ],
        );
      case MosquePostType.announcement:
      case MosquePostType.highlight:
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: UIButton.secondary(label: l10n.mosque_post_share, isSmall: true, onTap: onShare),
        );
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: UIColorsToken.textParagraph),
        const SizedBox(width: 4),
        Text(text, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
      ],
    );
  }
}
