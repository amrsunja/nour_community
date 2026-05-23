import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/hadith_model.dart';

/// A single hadith row in the collection-detail list: a star badge holding the
/// hadith's order number, the localized title, and a short quoted preview.
/// Tapping the row opens the immersive reader at this hadith.
class HadithCardWidget extends StatelessWidget {
  const HadithCardWidget({
    super.key,
    required this.hadith,
    required this.number,
    this.isLiked = false,
    this.isCurrent = false,
    this.onTap,
  });

  final HadithModel hadith;

  /// 1-based order shown in the star badge.
  final int number;

  final bool isLiked;

  /// Subtle highlight for the hadith matching the saved reading position.
  final bool isCurrent;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final langCode = Localizations.localeOf(context).languageCode;

    final preview = hadith.description(langCode);

    return UIGradientCard(
      onTap: onTap,
      selected: isCurrent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StarBadge(number: number),
          const UISpace.horz(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hadith.title(langCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            typo.inter.title.copyWith(color: UIColorsToken.white),
                      ),
                    ),
                    if (isLiked)
                      const Icon(Icons.favorite,
                          size: 16, color: UIColorsToken.textYellow),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const UISpace.vert(4),
                  Text(
                    '“$preview”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.bodyMedium.copyWith(
                      color: UIColorsToken.yellow.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          UIGlowingBlock(
            shadow: UIShadowToken.illustration,
            child: Image.asset(Assets.images.star.path),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              number.toString().padLeft(2, '0'),
              style: typo.inter.bodySmall.copyWith(
                color: UIColorsToken.textYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
