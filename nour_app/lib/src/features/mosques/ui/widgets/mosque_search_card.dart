import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/mosque_search_item_model.dart';
import 'mosque_format.dart';

/// Result card of the search sheet (Figma "Search mosques"): logo, name,
/// address · distance, today's 5 times, Chourouk/Jumu'a, "Add to my mosques".
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
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: compact ? 40 : 44,
        height: compact ? 40 : 44,
        child: item.logoUrl != null
            ? CachedNetworkImage(imageUrl: item.logoUrl!, fit: BoxFit.cover)
            : Container(
                color: const Color(0xff1F6FEB),
                alignment: Alignment.center,
                child: Text(item.initials, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
              ),
      ),
    );
    final subtitle = [
      if (item.fullAddress.isNotEmpty) item.fullAddress,
      if (item.distanceKm != null) MosqueFormat.km(item.distanceKm),
    ].join(' · ');

    if (compact) {
      return UICard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            logo,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  Text(
                    [if (item.distanceKm != null) MosqueFormat.km(item.distanceKm), if ((item.city ?? '').isNotEmpty) item.city!].join(' · '),
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

    return UICard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      colors: highlighted ? const [Color(0xff2C3427), Color(0xff1A1A1A)] : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              logo,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                    if (subtitle.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: UIColorsToken.textParagraph),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.hasTimes) ...[
            Row(
              children: [
                for (final s in PrayerSlot.values)
                  Expanded(
                    child: Column(
                      children: [
                        Text(slotShort(l10n, s), style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        const SizedBox(height: 2),
                        Text(MosqueFormat.hhmm(item.times[s]), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: UIColorsToken.bgSecondaryGreen, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${l10n.prayer_times_chourouk} ${MosqueFormat.hhmm(item.sunrise)}',
                        textAlign: TextAlign.center, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textYellow)),
                  ),
                  Container(width: 1, height: 14, color: UIColorsToken.stroke),
                  Expanded(
                    child: Text('${l10n.prayer_times_jumua} ${MosqueFormat.hhmm(item.jumua)}',
                        textAlign: TextAlign.center, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textYellow)),
                  ),
                ],
              ),
            ),
          ] else
            Text(l10n.mosque_prayer_times_not_published, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 12),
          Row(
            children: [
              UITap(
                onTap: () {
                  final uri = item.hasLocation
                      ? Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${item.lat},${item.lng}')
                      : Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(item.fullAddress)}');
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: UIColorsToken.bgSecondaryGreen, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.map_outlined, color: UIColorsToken.textYellow, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isMine
                    ? UIButton.secondary(label: l10n.my_mosques_added, fullWidth: true, isSmall: true, onTap: onAdd)
                    : UIButton.primary(label: l10n.mosque_add_to_my_mosques, fullWidth: true, isSmall: true, onTap: onAdd),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
