import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import 'dua_audio_button_widget.dart';
import 'dua_like_button_widget.dart';

/// The cream "dua card" shown in the immersive reader — the same anatomy as the
/// Hadith / Quran cards (audio + title/reference + like, the Arabic text, an
/// optional transcription, and a share | Aa | tafsir action row). The audio
/// control only appears when the dua ships a recitation URL.
class DuaReaderCardWidget extends StatelessWidget {
  const DuaReaderCardWidget({
    super.key,
    required this.title,
    required this.reference,
    required this.arabicText,
    required this.audioUrl,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
    required this.showTranscriptionAction,
    required this.showTranscription,
    required this.transcriptionText,
    required this.onToggleTranscription,
    required this.onShare,
    required this.translation,
    this.tafsirText = '',
    this.showTafsir = true,
  });

  final String title;

  /// Source reference (e.g. "Sahih Muslim 3302").
  final String reference;
  final String arabicText;

  /// Recitation URL, or `null` when the dua has no audio.
  final String? audioUrl;

  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;

  /// Whether the "Aa" transcription toggle is shown (hidden for Arabic).
  final bool showTranscriptionAction;
  final bool showTranscription;
  final String transcriptionText;
  final VoidCallback? onToggleTranscription;
  final VoidCallback onShare;

  /// Localized meaning + tafsir used by the sheet this card opens itself.
  final String translation;
  final String tafsirText;
  final bool showTafsir;

  static const _ink = UIColorsToken.white;
  bool get _hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UICard(
      padding: const EdgeInsets.all(20),
      shadows: [],
      begin: .centerLeft,
      end: .centerRight,
      colors: [
        Color(0xff45513F),
        Color(0xff2B3326),
      ],
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: _hasAudio
                    ? DuaAudioButtonWidget(
                        audioUrl: audioUrl!,
                        title: title,
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: typo.inter.title.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reference.isNotEmpty) ...[
                      const UISpace.vert(2),
                      Text(
                        reference,
                        textAlign: TextAlign.center,
                        style: typo.inter.bodySmall
                            .copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                child: DuaLikeButtonWidget(
                  isLiked: isLiked,
                  count: likeCount,
                  onTap: onLike,
                ),
              ),
            ],
          ),
          const UISpace.vert(20),
          Text(
            arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: typo.inter.bodyLarge.copyWith(
              color: UIColorsToken.white,
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

  /// Bottom sheet showing the dua explanation (tafsir) — falls back to the
  /// translation when no dedicated tafsir is set.
  void _openTafsir(BuildContext context) {
    final l10n = AppLocale.of(context);
    final typo = UITheme.of(context).typo;
    final body = tafsirText.isNotEmpty ? tafsirText : translation;

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
                  l10n.dua_explanation_title,
                  style:
                      typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
                ),
                if (reference.isNotEmpty) ...[
                  const UISpace.vert(4),
                  Text(
                    reference,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textYellow),
                  ),
                ],
                const UISpace.vert(16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      body,
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
