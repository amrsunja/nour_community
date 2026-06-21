import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Temporary placeholder for the not-yet-implemented Hadith source.
class HadithPlaceholderWidget extends StatelessWidget {
  const HadithPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, size: 48, color: UIColorsToken.textYellow),
            const UISpace.vert(16),
            Text(
              l10n.source_hadith_coming_soon,
              textAlign: TextAlign.center,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(6),
            Text(
              l10n.source_hadith_coming_soon_sub,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
        ),
      ),
    );
  }
}
