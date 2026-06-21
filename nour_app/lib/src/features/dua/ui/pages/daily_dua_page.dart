import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/share_services.dart';

import '../state_management/dua_provider.dart';
import '../widgets/dua_reader_card_widget.dart';
import '../widgets/dua_when_box_widget.dart';

/// "Daily Dua" quick action: a deterministic dua of the day shown in the same
/// cream card as the reader. The footer is an expanded "I'm done" button plus
/// an ajr box (the earnable ajr on top of the all-time dua ajr total). Tapping
/// "I'm done" logs the ajr (profile + ajr_log, server-side idempotent per day)
/// and closes the page.
@RoutePage()
class DailyDuaPage extends HookConsumerWidget {
  const DailyDuaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(duaProvider.notifier);
    final state = ref.watch(duaProvider);

    final showTranscription = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await presenter.init();
        await presenter.loadDailyDuaStatus();
      });
      return null;
    }, const []);

    final dua = presenter.getDailyDua();

    if (dua == null) {
      return UIGradientLinedScaffold(
        appBar: UIAppBar(title: l10n.tools_daily_dua, onBack: context.pop),
        body: const Center(child: UICircularProgressBar()),
      );
    }

    final reference = dua.reference(langCode);
    final translation = dua.translation(langCode);
    final whenText = dua.when(langCode);
    final transcription = dua.transcription(langCode);
    final hasTranscription = langCode != 'ar' && transcription.isNotEmpty;

    Future<void> share() => ShareServices.shareDua(
          title: dua.title(langCode),
          arabicText: dua.arabicText,
          translation: translation,
          reference: reference,
          duaId: dua.id,
        );

    Future<void> onDone() async {
      await presenter.completeDailyDua();
      if (context.mounted) context.pop();
    }

    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: l10n.tools_daily_dua, onBack: context.pop),
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
                    Column(
                      children: [
                        Text(
                          '"$translation"',
                          style: typo.inter.display.copyWith(
                            color: UIColorsToken.white,
                            height: 1.35,
                          ),
                        ),
                        if (whenText.isNotEmpty) ...[
                          const UISpace.vert(20),
                          DuaWhenBoxWidget(text: whenText),
                        ],
                      ],
                    ),
                    const UISpace.vert(20),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: .end,
              children: [
                if (!state.dailyDuaDoneToday)
                  Text(
                    '+${state.dailyDuaEarnableAjr}',
                    style: typo.inter.title,
                  ),
                Row(
                  children: [
                    Expanded(
                      child: UIButton.primary(
                        label: l10n.dua_done,
                        isBusy: state.isLoadingDailyDua,
                        onTap: state.dailyDuaDoneToday
                            ? () {
                                context.pop();
                              }
                            : onDone,
                      ),
                    ),
                    const UISpace.horz(12),
                    _AjrBox(
                      total: state.dailyDuaTotalAjr,
                      label: l10n.dhikr_ajr_earned,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer ajr summary: the earnable "+N" on top of the all-time dua ajr total.
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
