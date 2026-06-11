import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/adhkar_subcategory_model.dart';
import 'adhkar_image_widget.dart';

/// List-row card for a single adhkar subcategory: leading illustration,
/// localized title and a trailing count badge. Plays a [UIAppearAnimation]
/// entrance; stagger siblings via [delay].
class AdhkarSubcategoryCardWidget extends StatelessWidget {
  const AdhkarSubcategoryCardWidget({
    super.key,
    required this.subcategory,
    required this.langCode,
    this.onTap,
    this.delay = Duration.zero,
  });

  final AdhkarSubcategoryModel subcategory;
  final String langCode;
  final VoidCallback? onTap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UIAppearAnimation(
      delay: delay,
      child: UICard(
        onTap: onTap,
        color: UIColorsToken.black80,
        shadows: [],
        disableBorder: true,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            UIGlowingBlock(
              shadow: UIShadowToken.smallTexts,
              child: AdhkarImageWidget(imgUrl: subcategory.imgUrl, size: 40)),
            const UISpace.horz(14),
            Expanded(
              child: Text(
                subcategory.title(langCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.inter.title.copyWith(color: UIColorsToken.white),
              ),
            ),
            const UISpace.horz(10),
            _CountBadge(count: subcategory.adhkarsCount),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: UIColorsToken.bgTertiaryGreen,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count',
        style: typo.inter.caption,
      ),
    );
  }
}
