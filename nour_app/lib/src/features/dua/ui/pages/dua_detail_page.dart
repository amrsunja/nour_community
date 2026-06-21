import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/share_services.dart';

import '../../data/models/dua_model.dart';
import '../state_management/dua_provider.dart';
import '../widgets/dua_reader_card_widget.dart';
import '../widgets/dua_when_box_widget.dart';

/// Immersive single-dua reader: optional recitation playback, like toggle,
/// Arabic + translation, the "When to recite" guidance, prev / next navigation
/// and a share / transcription / tafsir action bar. Reading progress is
/// persisted on every dua change, on "I'm done", and on leaving the page.
@RoutePage()
class DuaDetailPage extends HookConsumerWidget {
  const DuaDetailPage({
    super.key,
    @PathParam('id') required this.initialDuaId,
    @QueryParam('recordProgress') this.recordProgress = true,
  });

  final int initialDuaId;

  /// When false (e.g. opened from Favourites), reading position is never
  /// persisted — neither on navigation nor on leaving the page.
  final bool recordProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(duaProvider.notifier);
    final state = ref.watch(duaProvider);

    // Make sure the library is loaded, e.g. when arriving straight from a
    // "Resume" / Daily Dua without opening the list first.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    final duas = state.library;

    if (duas.isEmpty) {
      return UIGradientLinedScaffold(
        appBar: UIAppBar(title: l10n.dua_title, onBack: context.pop),
        body: const Center(child: UICircularProgressBar()),
      );
    }

    final total = duas.length;
    final initialIndex = duas.indexWhere((d) => d.id == initialDuaId);
    final index = useState(initialIndex < 0 ? 0 : initialIndex);
    final current = index.value.clamp(0, total - 1);
    final DuaModel dua = duas[current];

    final showTranscription = useState(false);
    final transcription = dua.transcription(langCode);
    final hasTranscription = langCode != 'ar' && transcription.isNotEmpty;

    Future<void> save() async {
      if (!recordProgress) return;
      await presenter.saveProgress(dua);
    }

    void goTo(int next) {
      index.value = next.clamp(0, total - 1);
      save();
    }

    final reference = dua.reference(langCode);
    final translation = dua.translation(langCode);
    final whenText = dua.when(langCode);

    Future<void> share() => ShareServices.shareDua(
          title: dua.title(langCode),
          arabicText: dua.arabicText,
          translation: translation,
          reference: reference,
          duaId: dua.id,
        );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) save();
      },
      child: UIGradientLinedScaffold(
        appBar: UIAppBar(title: l10n.dua_title, onBack: context.pop),
        bgArabicText: dua.titleAr.isNotEmpty ? dua.titleAr : null,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const UISpace.vert(8),
                      DuaReaderCardWidget(
                        title: dua.title(langCode),
                        reference: reference,
                        arabicText: dua.arabicText,
                        audioUrl: dua.audioUrl,
                        isLiked: state.isDuaLiked(dua.id),
                        likeCount: dua.likesCount,
                        onLike: () => presenter.toggleLike(dua),
                        showTranscriptionAction: hasTranscription,
                        showTranscription: showTranscription.value,
                        transcriptionText: transcription,
                        onToggleTranscription: () =>
                            showTranscription.value = !showTranscription.value,
                        onShare: share,
                        translation: translation,
                        tafsirText: dua.tafsir(langCode),
                      ),
                      const UISpace.vert(24),
                      Text(
                        translation.isEmpty ? '' : '"$translation"',
                        style: typo.inter.display.copyWith(
                          color: UIColorsToken.white,
                          height: 1.35,
                        ),
                      ),
                      if (whenText.isNotEmpty) ...[
                        const UISpace.vert(20),
                        DuaWhenBoxWidget(text: whenText),
                      ],
                      const UISpace.vert(12),
                    ],
                  ),
                ),
              ),
              _NavBar(
                doneLabel: l10n.dua_done,
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
