import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state_management/quran_provider.dart';
import '../widgets/ayah_audio_button_widget.dart';
import '../widgets/ayah_like_button_widget.dart';

/// Immersive single-ayah reader: recitation playback (selected reciter), like
/// toggle, Arabic + translation, prev / next navigation, plus a share /
/// transcription / tafsir action bar. Reading progress is persisted on every
/// ayah change, on "I'm done", and on leaving the page.
@RoutePage()
class AyahReaderPage extends HookConsumerWidget {
  const AyahReaderPage({
    super.key,
    required this.surahNumber,
    this.initialAyah = 1,
  });

  final int surahNumber;
  final int initialAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(quranProvider.notifier);
    final state = ref.watch(quranProvider);

    final reciter = ref.watch(
          settingsProvider.select((s) => s.data?.favoriteReciter),
        ) ??
        ReciterType.defaultReciter;

    final surah = useMemoized(() => presenter.getSurah(surahNumber), [surahNumber]);
    final total = surah.versesCount;

    final ayahNumber = useState(initialAyah.clamp(1, total));
    final current = ayahNumber.value;
    final ayah = useMemoized(
      () => presenter.getAyah(surahNumber, current),
      [surahNumber, current],
    );

    final showTranscription = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.loadSurahLikes(surahNumber);
        presenter.loadSurahTransliteration(surahNumber, langCode: langCode);
      });
      return null;
    }, [surahNumber, langCode]);

    Future<void> save() => presenter.saveProgress(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber.value,
    );

    void goTo(int next) {
      ayahNumber.value = next.clamp(1, total);
      save();
    }

    final surahLabel = '${surah.number}. ${surah.nameEnglish}';
    final reference = '${surah.nameEnglish} (${surah.number}:$current)';
    final audioUrl =
        presenter.ayahAudioUrl(surahNumber, current, reciter: reciter);

    // Transliteration (lazily fetched into state; null until loaded / on error).
    final transliteration = state.transliterationOf(surahNumber, current);

    Future<void> share() => SharePlus.instance.share(
          ShareParams(
            text: '${ayah.arabicText}\n\n'
                '${ayah.translation}\n\n'
                '— $reference',
          ),
        );

    void openTafsir() => _showTafsirSheet(
          context,
          l10n: l10n,
          typo: typo,
          reference: reference,
          translation: ayah.translation,
        );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) save();
      },
      child: UIGradientLinedScaffold(
        appBar: UIAppBar(title: l10n.quran_title, onBack: context.pop),
        bgArabicText: surah.nameArabic,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const UISpace.vert(8),
              _AyahCard(
                surahLabel: surahLabel,
                position: '$current/$total',
                arabicText: ayah.arabicText,
                audioUrl: audioUrl,
                reciterName: reciter.displayName,
                isLiked: state.isAyahLiked(surahNumber, current),
                likeCount: state.ayahLikeCount(surahNumber, current),
                onLike: () => presenter.toggleLike(
                  surahNumber: surahNumber,
                  ayahNumber: current,
                ),
                // Arabic readers don't need a Latin transliteration.
                showTranscriptionAction: langCode != 'ar',
                showTranscription: showTranscription.value,
                transcriptionText: transliteration ?? l10n.quran_transcription_unavailable,
                onToggleTranscription: () => showTranscription.value = !showTranscription.value,
                onShare: share,
                onTafsir: openTafsir,
              ),
              const UISpace.vert(24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '"${ayah.translation}"',
                    style: typo.inter.display.copyWith(
                      color: UIColorsToken.white,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const UISpace.vert(12),
              _NavBar(
                doneLabel: l10n.quran_done,
                canGoPrev: current > 1,
                canGoNext: current < total,
                onPrev: () => goTo(current - 1),
                onNext: () => goTo(current + 1),
                onDone: () async {
                  await save();

                  nav.toHome();

                  /*
                  if (current < total) {
                    goTo(current + 1);
                  } else if (context.mounted) {
                    context.pop();
                  }
                  */
                },
              ),
              const UISpace.vert(12),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom sheet showing the verse meaning + a localized note. Built to slot a
  /// real tafsir data source in later (content already follows the app locale).
  void _showTafsirSheet(
    BuildContext context, {
    required AppLocale l10n,
    required UITypographyToken typo,
    required String reference,
    required String translation,
  }) {
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
                style: typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
              ),
              const UISpace.vert(4),
              Text(
                reference,
                style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow),
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

class _AyahCard extends StatelessWidget {
  const _AyahCard({
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
    required this.onTafsir,
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
  final VoidCallback? onTafsir;

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
                  if (onTafsir != null)
                    UIIcon(
                      UIIconsToken.icons.tafsir,
                      color: _ink,
                      size: 22,
                      onTap: onTafsir,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.doneLabel,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
    required this.onDone,
  });

  final String doneLabel;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ArrowButton(
          icon: Icons.arrow_back_rounded,
          enabled: canGoPrev,
          onTap: onPrev,
        ),
        const UISpace.horz(12),
        Expanded(
          child: UIButton.primary(
            label: doneLabel,
            fullWidth: true,
            onTap: onDone,
          ),
        ),
        const UISpace.horz(12),
        _ArrowButton(
          icon: Icons.arrow_forward_rounded,
          enabled: canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: UITap(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 56,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: UIColorsToken.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: UIColorsToken.stroke),
          ),
          child: Icon(icon, color: UIColorsToken.white, size: 22),
        ),
      ),
    );
  }
}
