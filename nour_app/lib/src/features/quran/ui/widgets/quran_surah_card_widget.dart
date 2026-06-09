import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';

/// A single surah row in the "All Surahs" list: a star badge holding the
/// surah number, the English name + verse count / revelation place, and the
/// Arabic name on the trailing edge.
class QuranSurahCardWidget extends StatelessWidget {
  const QuranSurahCardWidget({
    super.key,
    required this.surah,
    this.highlighted = false,
    this.onTap,
  });

  final SurahInfo surah;

  /// Subtle highlight for the surah that matches the current reading position.
  final bool highlighted;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final place = surah.isMakki ? l10n.quran_meccan : l10n.quran_medinan;

    return UIGradientCard(
      onTap: onTap,
      selected: highlighted,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          _StarBadge(number: surah.number),
          const UISpace.horz(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  QuranTool.localizedSurahName(surah, langCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.title.copyWith(color: UIColorsToken.white),
                ),
                const UISpace.vert(4),
                Text(
                  '${surah.versesCount} ${l10n.quran_verses}  |  $place',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.bodySmall.copyWith(
                    color: UIColorsToken.yellow.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const UISpace.horz(12),
          Text(
            surah.nameArabic,
            textDirection: TextDirection.rtl,
            style: typo.inter.title.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w700,
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
            child: Image.asset(
              Assets.images.star.path,
            ),
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
