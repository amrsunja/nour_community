import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/ui/widgets/project_cover_carousel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_model.dart';
import 'mosque_format.dart';

/// Header shared by the public profile and the admin editor:
/// cover carousel · logo · name · address (copy) · status · counters ·
/// primary actions · Itinerary / Call / Email tiles · tabs.
class MosqueHeader extends StatelessWidget {
  const MosqueHeader({
    super.key,
    required this.mosque,
    required this.l10n,
    required this.tab,
    required this.onTab,
    required this.isOpen,
    this.showDonationTab = false,
    this.newsBadge = false,
    this.actions,
    this.onBack,
    this.onShare,
    this.onCopiedAddress,
  });

  final MosqueModel mosque;
  final AppLocale l10n;
  final MosqueTab tab;
  final ValueChanged<MosqueTab> onTab;
  final bool isOpen;
  final bool showDonationTab;
  final bool newsBadge;

  /// Row placed under the counters (Follow / Become a member, or Edit).
  final Widget? actions;
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final VoidCallback? onCopiedAddress;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final covers = mosque.coverImages.where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            if (covers.isNotEmpty)
              ProjectCoverCarousel(images: covers, height: 238)
            else
              Container(
                height: 238,
                width: double.infinity,
                color: UIColorsToken.bgPrimary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UISpace.vert(50),
                    UIIcon(Assets.icons.gallery, color: UIColorsToken.textParagraph, size: 28),
                    const SizedBox(height: 6),
                    Text(l10n.mosque_cover_placeholder,
                        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                  ],
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onBack != null) 
                    UIIcon(
                      Assets.icons.chevronLeft,
                      onTap: onBack!,
                      color: UIColorsToken.yellow,
                    ),
                  if (onShare != null) 
                    UIIcon(
                      Assets.icons.share,
                      onTap: onShare!,
                    )
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MosqueLogo(mosque: mosque, size: 60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mosque.name, style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white)),
                        const SizedBox(height: 4),
                        if (mosque.fullAddress.isNotEmpty)
                          UITap(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: mosque.fullAddress));
                              onCopiedAddress?.call();
                            },
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: UIColorsToken.textParagraph),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    mosque.fullAddress,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.copy_rounded, size: 12, color: UIColorsToken.textParagraph),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _StatusPill(open: isOpen, label: isOpen ? l10n.mosque_status_open : l10n.mosque_status_closed),
                  Text('·', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                  _Counter(value: mosque.followersCount, label: l10n.mosque_followers),
                  Text('·', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                  _Counter(value: mosque.membersCount, label: l10n.mosque_members),
                ],
              ),
              if (actions != null) ...[const SizedBox(height: 16), actions!],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      imagePath: Assets.images.illustration39.path,
                      label: l10n.mosque_action_itinerary,
                      enabled: mosque.hasLocation || mosque.fullAddress.isNotEmpty,
                      onTap: () => openItinerary(mosque),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      imagePath: Assets.images.illustration37.path,
                      label: l10n.mosque_action_call,
                      enabled: (mosque.phone ?? '').isNotEmpty,
                      onTap: () => launchUrl(Uri.parse('tel:${mosque.phone}')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      imagePath: Assets.images.illustration38.path,
                      label: l10n.mosque_action_email,
                      enabled: (mosque.email ?? '').isNotEmpty,
                      onTap: () => launchUrl(Uri.parse('mailto:${mosque.email}')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MosqueTabsBar(
                tab: tab,
                onTab: onTab,
                l10n: l10n,
                showDonation: showDonationTab,
                newsBadge: newsBadge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> openItinerary(MosqueModel mosque) async {
    final Uri uri;
    if (mosque.hasLocation) {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${mosque.lat},${mosque.lng}');
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mosque.fullAddress)}');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Segmented tabs Prayers · Information · News (dot) · Donation.
class MosqueTabsBar extends StatelessWidget {
  const MosqueTabsBar({
    super.key,
    required this.tab,
    required this.onTab,
    required this.l10n,
    this.showDonation = false,
    this.newsBadge = false,
  });

  final MosqueTab tab;
  final ValueChanged<MosqueTab> onTab;
  final AppLocale l10n;
  final bool showDonation;
  final bool newsBadge;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final tabs = [
      (MosqueTab.prayers, l10n.mosque_tab_prayers),
      (MosqueTab.information, l10n.mosque_tab_information),
      (MosqueTab.news, l10n.mosque_tab_news),
      if (showDonation) (MosqueTab.donation, l10n.mosque_tab_donation),
    ];
    return Row(
      children: [
        for (final t in tabs)
          Expanded(
            child: UITap(
              onTap: () => onTab(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: tab == t.$1 ? UIColorsToken.bgPriYellow : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.$2,
                        style: theme.typo.inter.bodyMedium.copyWith(
                          color: tab == t.$1 ? UIColorsToken.black : UIColorsToken.white,
                          fontWeight: tab == t.$1 ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (t.$1 == MosqueTab.news && newsBadge && tab != t.$1) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: UIColorsToken.textYellow),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MosqueLogo extends StatelessWidget {
  const MosqueLogo({super.key, required this.mosque, this.size = 48, this.radius = 12});
  final MosqueModel mosque;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final url = mosque.logoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
            : Container(
                color: const Color(0xff1F6FEB),
                alignment: Alignment.center,
                child: Text(
                  mosque.initials,
                  style: theme.typo.inter.title.copyWith(color: UIColorsToken.black, fontSize: size * 0.34),
                ),
              ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.open, required this.label});
  final bool open;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: UIColorsToken.yellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UIColorsToken.yellow.withValues(alpha: 0.2))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: open ? UIColorsToken.greenAccent : UIColorsToken.red),
          ),
          const SizedBox(width: 6),
          Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textYellow)),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
        children: [
          TextSpan(text: MosqueFormat.compact(value), style: const TextStyle(color: UIColorsToken.textYellow, fontWeight: FontWeight.w600)),
          TextSpan(text: ' $label'),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.imagePath, required this.label, required this.onTap, this.enabled = true});
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : .4,
      child: UICard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        onTap: enabled ? onTap : null,
        child: Column(
          children: [
            SizedBox(
              height: 35,
              child: Image.asset(imagePath),
            ),
            const SizedBox(height: 6),
            Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.white)),
          ],
        ),
      ),
    );
  }
}
