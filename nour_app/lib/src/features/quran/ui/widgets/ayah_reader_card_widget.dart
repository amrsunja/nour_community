import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import 'ayah_audio_button_widget.dart';
import 'ayah_like_button_widget.dart';

/// The cream "ayah card" shown in the immersive reader and the Daily Ayah page:
/// audio button + surah label/position + like, the Arabic verse, an optional
/// transliteration, and a share | Aa | tafsir action row.
class AyahReaderCardWidget extends StatelessWidget {
  const AyahReaderCardWidget({
    super.key,
    required this.surahLabel,
    required this.position,
    required this.arabicText,
    required this.audioUrl,
    required this.reciterName,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
    required this.showTranscriptionAction,
    required this.showTranscription,
    required this.transcriptionText,
    required this.onToggleTranscription,
    required this.onShare,
    required this.translation,
    required this.reference,
    this.showTafsir = true,
    this.onListen,
  });

  final String surahLabel;
  final String position;
  final String arabicText;
  final String audioUrl;
  final String reciterName;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;

  /// Whether the "Aa" transliteration toggle is shown (hidden for Arabic).
  final bool showTranscriptionAction;
  final bool showTranscription;
  final String transcriptionText;
  final VoidCallback? onToggleTranscription;
  final VoidCallback onShare;

  /// Localized meaning + reference (e.g. `Al-Baqara (2:14)`) used by the tafsir
  /// sheet that this card opens itself.
  final String translation;
  final String reference;

  /// Whether the tafsir action (and its sheet) is available.
  final bool showTafsir;

  /// Fired when recitation playback starts. Optional (analytics hook).
  final VoidCallback? onListen;

  static const _ink = UIColorsToken.black;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF6EFDD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AyahAudioButtonWidget(
                audioUrl: audioUrl,
                title: surahLabel,
                artist: reciterName,
                onListen: onListen,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      surahLabel,
                      textAlign: TextAlign.center,
                      style: typo.inter.title.copyWith(
                        color: UIColorsToken.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const UISpace.vert(2),
                    Text(
                      position,
                      style: typo.inter.bodySmall.copyWith(
                        color: UIColorsToken.black,
                      ),
                    ),
                  ],
                ),
              ),
              AyahLikeButtonWidget(
                isLiked: isLiked,
                count: likeCount,
                onTap: onLike,
              ),
            ],
          ),
          const UISpace.vert(20),
          Text(
            arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: typo.inter.bodyLarge.copyWith(
              color: UIColorsToken.black,
              height: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showTranscriptionAction && showTranscription) ...[
            const UISpace.vert(12),
            UIAppearAnimation(
              child: Text(
                transcriptionText,
                textAlign: TextAlign.center,
                style: typo.inter.bodyMedium.copyWith(
                  color: _ink,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const UISpace.vert(16),

          // Action row: share | transcription toggle | tafsir.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UIIcon(
                UIIconsToken.icons.share,
                color: _ink,
                onTap: onShare,
              ),
              Row(
                children: [
                  if (showTranscriptionAction) ...[
                    UIIcon(
                      UIIconsToken.icons.aa,
                      color: showTranscription ? UIColorsToken.yellow : _ink,
                      onTap: onToggleTranscription,
                    ),
                    const UISpace.horz(16),
                  ],
                  if (showTafsir)
                    UIIcon(
                      UIIconsToken.icons.tafsir,
                      color: _ink,
                      size: 22,
                      onTap: () => _openTafsir(context),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom sheet showing the verse meaning + a localized note. Built to slot a
  /// real tafsir data source in later (content already follows the app locale).
  void _openTafsir(BuildContext context) {
    final l10n = AppLocale.of(context);
    final typo = UITheme.of(context).typo;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: UIColorsToken.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.6,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: UIColorsToken.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const UISpace.vert(16),
                Text(
                  l10n.quran_tafsir_title,
                  style:
                      typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
                ),
                const UISpace.vert(4),
                Text(
                  reference,
                  style: typo.inter.bodySmall
                      .copyWith(color: UIColorsToken.textYellow),
                ),
                const UISpace.vert(16),
                Text(
                  l10n.quran_tafsir_note,
                  style: typo.inter.bodyMedium.copyWith(
                    color: UIColorsToken.textParagraph,
                  ),
                ),
                const UISpace.vert(12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      translation,
                      style: typo.inter.body.copyWith(
                        color: UIColorsToken.white,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
