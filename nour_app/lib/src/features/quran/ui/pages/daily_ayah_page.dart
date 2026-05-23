import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state_management/quran_provider.dart';
import '../widgets/ayah_reader_card_widget.dart';

/// "Daily Ayah" quick action: a deterministic verse of the day shown in the
/// same cream ayah card as the reader. The footer is an expanded "I'm done"
/// button plus an ajr box (the earnable ajr on top of the all-time ayah ajr
/// total). Tapping "I'm done" logs the ajr (profile + ajr_log, server-side
/// idempotent per day) and closes the page.
@RoutePage()
class DailyAyahPage extends HookConsumerWidget {
  const DailyAyahPage({super.key});

  /// Arabic app-bar title ("Daily ayah") — shown regardless of app locale.
  static const _arabicTitle = 'آية اليوم';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(quranProvider.notifier);
    final state = ref.watch(quranProvider);

    final reciter = ref.watch(
          settingsProvider.select((s) => s.data?.favoriteReciter),
        ) ??
        ReciterType.defaultReciter;

    final ayah = useMemoized(() => presenter.getDailyAyah());
    final surah = useMemoized(
      () => presenter.getSurah(ayah.surahNumber),
      [ayah.surahNumber],
    );

    final showTranscription = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.loadDailyAyahStatus();
        presenter.loadSurahLikes(ayah.surahNumber);
        presenter.loadSurahTransliteration(ayah.surahNumber, langCode: langCode);
      });
      return null;
    }, [ayah.surahNumber, langCode]);

    final surahLabel = '${surah.number}. ${surah.nameEnglish}';
    final reference =
        '${surah.nameEnglish} (${surah.number}:${ayah.ayahNumber})';
    final audioUrl = presenter.ayahAudioUrl(
      ayah.surahNumber,
      ayah.ayahNumber,
      reciter: reciter,
    );
    final transliteration =
        state.transliterationOf(ayah.surahNumber, ayah.ayahNumber);

    Future<void> share() => SharePlus.instance.share(
          ShareParams(
            text: '${ayah.arabicText}\n\n'
                '${ayah.translation}\n\n'
                '— $reference',
          ),
        );

    Future<void> onDone() async {
      await presenter.completeDailyAyah();
      if (context.mounted) context.pop();
    }

    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: l10n.tools_daily_ayah, onBack: context.pop),
      bgArabicText: surah.nameArabic,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const UISpace.vert(8),
            AyahReaderCardWidget(
              surahLabel: surahLabel,
              position: '${ayah.ayahNumber}/${surah.versesCount}',
              arabicText: ayah.arabicText,
              audioUrl: audioUrl,
              reciterName: reciter.displayName,
              isLiked: state.isAyahLiked(ayah.surahNumber, ayah.ayahNumber),
              likeCount: state.ayahLikeCount(ayah.surahNumber, ayah.ayahNumber),
              onLike: () => presenter.toggleLike(
                surahNumber: ayah.surahNumber,
                ayahNumber: ayah.ayahNumber,
              ),
              showTranscriptionAction: langCode != 'ar',
              showTranscription: showTranscription.value,
              transcriptionText:
                  transliteration ?? l10n.quran_transcription_unavailable,
              onToggleTranscription: () =>
                  showTranscription.value = !showTranscription.value,
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
            Column(
              crossAxisAlignment: .end,
              children: [
                if (!state.dailyAyahDoneToday)
                  Text(
                    '+${state.dailyAyahEarnableAjr}',
                    style: typo.inter.title,
                  ),
                Row(
                  children: [
                    Expanded(
                      child: UIButton.primary(
                        label: l10n.quran_done,
                        isBusy: state.isLoadingDailyAyah,
                        onTap: state.dailyAyahDoneToday ? () {
                          context.pop();
                        } : onDone,
                      ),
                    ),
                    const UISpace.horz(12),
                    _AjrBox(
                      total: state.dailyAyahTotalAjr,
                      label: l10n.dhikr_ajr_earned,
                    ),
                  ],
                ),
              ],
            ),
            const UISpace.vert(12),
          ],
        ),
      ),
    );
  }
}

/// Footer ajr summary: the earnable "+N" on top of the all-time ayah ajr total.
class _AjrBox extends StatelessWidget {
  const _AjrBox({
    required this.total,
    required this.label,
  });

  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
    height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$total',
            style: typo.inter.title.copyWith(
              color: UIColorsToken.textYellow,
              fontWeight: FontWeight.w700,
            ),
          ),
          UIGlowingBlock(
            shadow: UIShadowToken.smallTexts,
            child: Text(
              label,
              style: typo.inter.bodySmall.copyWith(
                color: UIColorsToken.textYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
