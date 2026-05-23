import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/adhkar_subcategory_model.dart';
import 'adhkar_image_widget.dart';

/// Green "Recommended now" banner shown at the top of the adhkar list when the
/// current local time falls inside a subcategory's recommended window.
class RecommendedAdhkarCardWidget extends StatelessWidget {
  const RecommendedAdhkarCardWidget({
    super.key,
    required this.subcategory,
    required this.label,
    required this.langCode,
    this.onTap,
  });

  final AdhkarSubcategoryModel subcategory;

  /// Localized "Recommended now" caption.
  final String label;
  final String langCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UIAppearAnimation(
      child: UIBgArabicTextCard(
      height: 125,
        onTap: onTap,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        arabicBgText: 'أَسْتَغْفِرُ اللَّهَ',
        child: Column(
          spacing: 6,
          crossAxisAlignment: .start,
          mainAxisAlignment: .center,
          children: [
            Text(
              label,
              style: typo.inter.title.copyWith(
                color: UIColorsToken.textYellow,
              ),
            ),
            Row(
              children: [
                AdhkarImageWidget(imgUrl: subcategory.imgUrl, size: 48),
                const UISpace.horz(16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subcategory.title(langCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.inter.largeTitle.copyWith(
                          color: UIColorsToken.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
