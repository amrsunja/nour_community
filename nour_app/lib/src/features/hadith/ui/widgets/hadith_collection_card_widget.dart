import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/hadith_collection_model.dart';

/// A hadith-collection card on the Source tab (Hadith section), mirroring the
/// Quran "Continue reading" card.
///
/// Two flavours, driven by whether the user has a last-read hadith:
///  * in progress — title + subtitle, a [UIProgressLine] with `read/total`
///    (rendered only when the total is known) and a full-width "Resume" button
///    that reopens the reader at the last saved hadith.
///  * fresh — title + subtitle only.
///
/// Tapping the whole card opens the collection detail in both cases via [onTap].
class HadithCollectionCardWidget extends StatelessWidget {
  const HadithCollectionCardWidget({
    super.key,
    required this.collection,
    this.readCount = 0,
    this.onTap,
    this.onResume,
  });

  final HadithCollectionModel collection;

  /// 1-based position of the last-read hadith (0 = not started).
  final int readCount;

  /// Opens the collection detail (list of hadiths).
  final VoidCallback? onTap;

  /// Opens the reader at the last saved hadith. Only wired when there is
  /// progress to resume.
  final VoidCallback? onResume;

  /// There is a last-read hadith to resume. Independent of the (best-effort)
  /// total count so a failed count never hides the Resume button.
  bool get _inProgress => readCount > 0 && onResume != null;

  /// The total is only shown when the count query succeeded and is consistent.
  bool get _hasTotal => collection.totalHadiths >= readCount && collection.totalHadiths > 0;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final total = collection.totalHadiths;

    return UIBgArabicTextCard(
      onTap: onTap,
      arabicBgText: collection.titleAr,
      height: _inProgress ? 190 : 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            collection.title(langCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
          ),
          const UISpace.vert(6),
          Text(
            collection.description(langCode),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow),
          ),
          if (_inProgress) ...[
            const UISpace.vert(14),
            if (_hasTotal)
              Row(
                children: [
                  Expanded(
                    child: UIProgressLine(
                      current: readCount.toDouble(),
                      total: total.toDouble(),
                    ),
                  ),
                  const UISpace.horz(12),
                  Text(
                    '$readCount/$total',
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textYellow),
                  ),
                ],
              ),
            if (_hasTotal) const UISpace.vert(16),
            UIButton.primary(
              label: l10n.hadith_resume,
              fullWidth: true,
              onTap: onResume,
            ),
          ],
        ],
      ),
    );
  }
}
