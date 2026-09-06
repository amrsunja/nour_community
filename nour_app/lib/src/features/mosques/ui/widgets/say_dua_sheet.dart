import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// "Say a dua" bottom sheet for janaza posts (Figma 1180:6503).
/// Returns `true` when the user tapped "I'm done".
class SayDuaSheet extends StatelessWidget {
  const SayDuaSheet({super.key, required this.l10n});

  final AppLocale l10n;

  static const arabic = 'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ';
  static const transliteration = 'Allahumma-ghfir lahu warhamhu wa ʿafihi waʿfu ʿanhu';

  static Future<bool> show(BuildContext context, {required AppLocale l10n}) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SayDuaSheet(l10n: l10n),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: UIColorsToken.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 72, height: 5, decoration: BoxDecoration(color: UIColorsToken.white, borderRadius: BorderRadius.circular(3))),
          ),
          const SizedBox(height: 20),
          Text(l10n.mosque_post_say_dua, textAlign: TextAlign.center, style: theme.typo.inter.display.copyWith(color: UIColorsToken.white)),
          const SizedBox(height: 4),
          Text(l10n.mosque_dua_recite, textAlign: TextAlign.center, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 20),
          UICard(
            padding: const EdgeInsets.all(16),
            colors: const [Color(0xff2C3427), Color(0xff1A1A1A)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white, height: 1.8),
                ),
                const SizedBox(height: 12),
                Text(transliteration, textAlign: TextAlign.center, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                const SizedBox(height: 6),
                Text(l10n.mosque_dua_translation, textAlign: TextAlign.center, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          UIButton.primary(label: l10n.mosque_dua_done, fullWidth: true, onTap: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
  }
}
