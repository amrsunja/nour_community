import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/hadith_model.dart';
import '../state_management/hadith_provider.dart';
import '../widgets/hadith_reader_card_widget.dart';

/// Immersive single-hadith reader: optional recitation playback, like toggle,
/// Arabic + translation, prev / next navigation and a share / transcription /
/// tafsir action bar. Reading progress is persisted on every hadith change, on
/// "I'm done", and on leaving the page.
@RoutePage()
class HadithDetailPage extends HookConsumerWidget {
  const HadithDetailPage({
    super.key,
    required this.collectionId,
    required this.initialHadithId,
  });

  final int collectionId;
  final int initialHadithId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(hadithProvider.notifier);
    final state = ref.watch(hadithProvider);

    // Make sure the collection (+ its hadiths) are available, e.g. when arriving
    // straight from a "Resume" without opening the list first.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await presenter.init();
        await presenter.loadHadiths(collectionId);
      });
      return null;
    }, [collectionId]);

    final hadiths = state.hadithsOf(collectionId);

    final collection =
        state.collections.firstWhereOrNull((c) => c.id == collectionId);

    if (hadiths.isEmpty) {
      return UIGradientLinedScaffold(
        appBar: UIAppBar(title: l10n.hadith_title, onBack: context.pop),
        bgArabicText: collection?.titleAr,
        body: const Center(child: UICircularProgressBar()),
      );
    }

    final total = hadiths.length;
    final initialIndex = hadiths.indexWhere((h) => h.id == initialHadithId);
    final index = useState(initialIndex < 0 ? 0 : initialIndex);
    final current = index.value.clamp(0, total - 1);
    final HadithModel hadith = hadiths[current];

    final showTranscription = useState(false);
    final transcription = hadith.transcription(langCode);
    final hasTranscription = langCode != 'ar' && transcription.isNotEmpty;

    Future<void> save() => presenter.saveProgress(
          collectionId: collectionId,
          hadith: hadith,
        );

    void goTo(int next) {
      index.value = next.clamp(0, total - 1);
      save();
    }

    final reference = hadith.reference(langCode);
    final translation = hadith.translation(langCode);

    Future<void> share() => SharePlus.instance.share(
          ShareParams(
            text: '${hadith.arabicText}\n\n'
                '$translation\n\n'
                '— ${reference.isNotEmpty ? reference : hadith.title(langCode)}',
          ),
        );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) save();
      },
      child: UIGradientLinedScaffold(
        appBar: UIAppBar(title: l10n.hadith_title, onBack: context.pop),
        bgArabicText: collection?.titleAr,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const UISpace.vert(8),
                      HadithReaderCardWidget(
                        title: hadith.title(langCode),
                        reference: reference,
                        arabicText: hadith.arabicText,
                        audioUrl: hadith.audioUrl,
                        isLiked: state.isHadithLiked(hadith.id),
                        likeCount: hadith.likesCount,
                        onLike: () => presenter.toggleLike(hadith),
                        showTranscriptionAction: hasTranscription,
                        showTranscription: showTranscription.value,
                        transcriptionText: transcription,
                        onToggleTranscription: () =>
                            showTranscription.value = !showTranscription.value,
                        onShare: share,
                        translation: translation,
                        tafsirText: hadith.tafsir(langCode),
                      ),
                      const UISpace.vert(24),
                      Text(
                        translation.isEmpty ? '' : '"$translation"',
                        style: typo.inter.display.copyWith(
                          color: UIColorsToken.white,
                          height: 1.35,
                        ),
                      ),
                      const UISpace.vert(12),
                    ],
                  ),
                ),
              ),
              _NavBar(
                doneLabel: l10n.hadith_done,
                canGoPrev: current > 0,
                canGoNext: current < total - 1,
                onPrev: () => goTo(current - 1),
                onNext: () => goTo(current + 1),
                onDone: () async {
                  await save();
                  if (!context.mounted) return;
                  context.pop();
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
