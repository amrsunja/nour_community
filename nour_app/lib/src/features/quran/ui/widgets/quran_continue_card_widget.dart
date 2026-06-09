import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';

/// "Continue reading" card on the Quran tab: surah name, the current verse
/// position, a progress line, and a full-width Resume button. Tapping Resume
/// reopens the ayah reader at the saved position.
class QuranContinueCardWidget extends StatelessWidget {
  const QuranContinueCardWidget({
    super.key,
    required this.surah,
    required this.ayahNumber,
    this.onResume,
  });

  final SurahInfo surah;
  final int ayahNumber;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final total = surah.versesCount;

    return UIBgArabicTextCard(
      arabicBgText: surah.nameArabic,
      height: 190,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            QuranTool.localizedSurahName(surah, langCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
          ),
          const UISpace.vert(6),
          Text(
            '${l10n.quran_verse} $ayahNumber / $total',
            style: typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.textYellow
            ),
          ),
          const UISpace.vert(10),
          Row(
            children: [
              Expanded(
                child: UIProgressLine(current: ayahNumber.toDouble(), total: total.toDouble()),
              ),
              const UISpace.horz(12),
              Text(
                '$ayahNumber/$total',
                style: typo.inter.bodySmall.copyWith(color: UIColorsToken.white),
              ),
            ],
          ),
          const Spacer(),
          UIButton.primary(
            label: l10n.quran_resume,
            fullWidth: true,
            onTap: onResume,
          ),
        ],
      ),
    );
  }
}
