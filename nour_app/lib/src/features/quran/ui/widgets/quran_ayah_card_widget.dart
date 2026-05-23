import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/ayah_model.dart';

/// A single ayah row in the surah-detail list: a numbered badge, the Arabic
/// text (right-aligned) and its translation. Optionally shows a small "liked"
/// heart. Tapping the row opens the immersive reader at this ayah.
class QuranAyahCardWidget extends StatelessWidget {
  const QuranAyahCardWidget({
    super.key,
    required this.ayah,
    this.isLiked = false,
    this.onTap,
  });

  final AyahModel ayah;
  final bool isLiked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UICard(
      onTap: onTap,
      colors: const [UIColorsToken.bgSurface, UIColorsToken.bgSurface],
      disableBorder: true,
      shadows: const [],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _AyahNumberBadge(number: ayah.ayahNumber),
              const Spacer(),
              if (isLiked)
                const Icon(Icons.favorite, size: 16, color: UIColorsToken.textYellow),
            ],
          ),
          const UISpace.vert(12),
          Text(
            ayah.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: typo.inter.bodyLarge.copyWith(
              color: UIColorsToken.white,
              height: 1.9,
            ),
          ),
          const UISpace.vert(10),
          Text(
            ayah.translation,
            style: typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.textParagraph,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahNumberBadge extends StatelessWidget {
  const _AyahNumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: UIColorsToken.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$number',
        style: typo.inter.bodySmall.copyWith(
          color: UIColorsToken.textYellow,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
