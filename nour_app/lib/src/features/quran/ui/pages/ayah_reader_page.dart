import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';
import 'package:nour/src/core/utils/share_services.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

import '../state_management/quran_provider.dart';
import '../widgets/ayah_reader_card_widget.dart';

/// Immersive single-ayah reader: recitation playback (selected reciter), like
/// toggle, Arabic + translation, prev / next navigation, plus a share /
/// transcription / tafsir action bar. Reading progress is persisted on every
/// ayah change, on "I'm done", and on leaving the page.
@RoutePage()
class AyahReaderPage extends HookConsumerWidget {
  const AyahReaderPage({
    super.key,
    @PathParam('surahId') required this.surahNumber,
    @PathParam('ayahId') this.initialAyah = 1,
    @QueryParam('recordProgress') this.recordProgress = true,
  });

  final int surahNumber;
  final int initialAyah;

  /// When false (e.g. opened from Favourites), reading position is never
  /// persisted — neither on navigation nor on leaving the page.
  final bool recordProgress;

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
      () => presenter.getAyah(surahNumber, current, langCode: langCode),
      [surahNumber, current, langCode],
    );

    final showTranscription = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.loadSurahLikes(surahNumber);
        presenter.loadSurahTransliteration(surahNumber, langCode: langCode);
      });
      return null;
    }, [surahNumber, langCode]);

    Future<void> save() async {
      if (!recordProgress) return;
      await presenter.saveProgress(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber.value,
      );
    }

    void goTo(int next) {
      ayahNumber.value = next.clamp(1, total);
      save();
    }

    final surahName = QuranTool.localizedSurahName(surah, langCode);
    final surahLabel = '${surah.number}. $surahName';
    final reference = '$surahName (${surah.number}:$current)';
    final audioUrl =
        presenter.ayahAudioUrl(surahNumber, current, reciter: reciter);

    // Transliteration (lazily fetched into state; null until loaded / on error).
    final transliteration = state.transliterationOf(surahNumber, current);

    Future<void> share() => ShareServices.shareAyah(
          surahName: surahName,
          surahNumber: surahNumber,
          ayahNumber: current,
          arabicText: ayah.arabicText,
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
              AyahReaderCardWidget(
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
                translation: ayah.translation,
                reference: reference,
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
