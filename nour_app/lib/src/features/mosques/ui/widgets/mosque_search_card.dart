import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/mosque_search_item_model.dart';
import 'mosque_format.dart';

/// Result card of the search sheet (Figma "Search mosques"): logo, name,
/// address · distance, today's 5 times (`--:--` when unpublished),
/// Chourouk/Jumu'a, itinerary + "Add to my mosques".
class MosqueSearchCard extends StatelessWidget {
  const MosqueSearchCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.onTap,
    required this.onAdd,
    this.isMine = false,
    this.highlighted = false,
    this.compact = false,
  });

  static const double _logoSize = 48;
  static const double _mapButtonSize = 48;

  final MosqueSearchItemModel item;
  final AppLocale l10n;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isMine;
  final bool highlighted;

  /// Onboarding variant: one line, ⊕ / ✓ at the right, no times.
  final bool compact;

  static String slotShort(AppLocale l10n, PrayerSlot s) => switch (s) {
        PrayerSlot.fajr => l10n.notifications_prayer_fajr,
        PrayerSlot.dhuhr => l10n.notifications_prayer_dhuhr,
        PrayerSlot.asr => l10n.notifications_prayer_asr,
        PrayerSlot.maghrib => l10n.notifications_prayer_maghrib,
        PrayerSlot.isha => l10n.notifications_prayer_isha,
      };

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final size = compact ? 40.0 : _logoSize;
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: item.logoUrl != null
            ? CachedNetworkImage(
                imageUrl: item.logoUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _logoFallback(theme),
                placeholder: (_, __) => _logoFallback(theme),
              )
            : _logoFallback(theme),
      ),
    );

    if (compact) {
      return UICard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        disableBorder: true,
        child: Row(
          children: [
            logo,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  Text(
                    [
                      if (item.distanceKm != null) MosqueFormat.km(item.distanceKm),
                      if ((item.city ?? '').isNotEmpty) item.city!,
                    ].join(' · '),
                    style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
            UITap(
              onTap: onAdd,
              child: Icon(
                isMine ? Icons.check_circle : Icons.add_circle_outline,
                color: isMine ? UIColorsToken.pastelGreen : UIColorsToken.textYellow,
                size: 26,
              ),
            ),
          ],
        ),
      );
    }

    final subtitle = [
      if (item.fullAddress.isNotEmpty) item.fullAddress,
      if (item.distanceKm != null) MosqueFormat.km(item.distanceKm),
    ].join(' · ');

    return UICard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      colors: highlighted ? const [Color(0xff2C3427), Color(0xff1A1A1A)] : null,
      disableBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              logo,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typo.inter.titleMedium.copyWith(color: UIColorsToken.white),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: UIIconsToken.toIcon(
                              UIIconsToken.icons.location,
                              color: UIColorsToken.textParagraph,
                              size: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Today's 5 prayers — always rendered; `--:--` when not published.
          Padding(
            padding: const EdgeInsets.only(left: 45),
            child: Row(
              children: [
                for (final s in PrayerSlot.values)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          slotShort(l10n, s),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MosqueFormat.hhmm(item.hasTimes ? item.times[s] : null),
                          style: theme.typo.inter.title.copyWith(color: UIColorsToken.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: UIColorsToken.yellow.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.prayer_times_chourouk} ${MosqueFormat.hhmm(item.hasTimes ? item.sunrise : null)}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
                    ),
                  ),
                  Container(width: 1, height: 16, color: UIColorsToken.textYellow.withValues(alpha: 0.3)),
                  Expanded(
                    child: Text(
                      '${l10n.prayer_times_jumua} ${MosqueFormat.hhmm(item.hasTimes ? item.jumua : null)}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 12,
            children: [
              UITap(
                onTap: _openItinerary,
                child: Container(
                  width: _mapButtonSize,
                  height: _mapButtonSize,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UIColorsToken.bgPrimary.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(Assets.images.illustration39.path, fit: BoxFit.contain),
                ),
              ),
              Expanded(
                child: isMine
                    ? UIButton.secondary(label: l10n.my_mosques_added, fullWidth: true, onTap: onAdd)
                    : UIButton.primary(label: l10n.mosque_add_to_my_mosques, fullWidth: true, onTap: onAdd),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logoFallback(UIThemeData theme) => Container(
        color: UIColorsToken.bgSecondaryGreen,
        alignment: Alignment.center,
        child: Text(
          item.initials,
          style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow),
        ),
      );

  void _openItinerary() {
    final uri = item.hasLocation
        ? Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${item.lat},${item.lng}')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(item.fullAddress)}');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
