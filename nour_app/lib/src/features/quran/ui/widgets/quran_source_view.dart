import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../state_management/quran_provider.dart';
import 'quran_continue_card_widget.dart';
import 'quran_surah_card_widget.dart';

/// Quran tab body: a "Continue reading" card (when progress exists) followed by
/// the full surah list. Owns its own load lifecycle and renders loading / error
/// / empty states.
class QuranSourceView extends HookConsumerWidget {
  const QuranSourceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(quranProvider.notifier);
    final state = ref.watch(quranProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    if (state.isLoading && state.isEmpty) {
      return const Center(child: UICircularProgressBar());
    }

    if (state.hasError && state.isEmpty) {
      return _QuranError(onRetry: presenter.retry);
    }

    if (state.isEmpty) {
      return const _QuranEmpty();
    }

    final progress = state.progress;
    final continueSurah = progress == null
        ? null
        : state.surahs.firstWhere(
            (s) => s.number == progress.surahNumber,
            orElse: () => state.surahs.first,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (continueSurah != null) ...[
            Text(
              l10n.quran_continue_reading,
              style: typo.inter.title.copyWith(
                color: UIColorsToken.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const UISpace.vert(12),
            UIAppearAnimation(
              child: UiRepeatShimerAnimation(
                child: QuranContinueCardWidget(
                  surah: continueSurah,
                  ayahNumber: progress!.ayahNumber,
                  onResume: () => nav.toAyahReader(
                    surahNumber: continueSurah.number,
                    initialAyah: progress.ayahNumber,
                  ),
                ),
              ),
            ),
            const UISpace.vert(24),
          ],
          Text(
            l10n.quran_all_surahs,
            style: typo.inter.title.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const UISpace.vert(12),
          ...state.surahs.map(
            (surah) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuranSurahCardWidget(
                surah: surah,
                highlighted: progress?.surahNumber == surah.number,
                onTap: () => nav.toSurahDetail(surahNumber: surah.number),
              ),
            ),
          ),
        ].animate(effects: [FadeEffect()]),
      ),
    );
  }
}

class _QuranError extends StatelessWidget {
  const _QuranError({required this.onRetry});

  final VoidCallback onRetry;

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
            const Icon(Icons.error_outline, color: UIColorsToken.textYellow, size: 44),
            const UISpace.vert(12),
            Text(
              l10n.quran_error_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(6),
            Text(
              l10n.quran_error_subtitle,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(16),
            UIButton.primary(label: l10n.quran_try_again, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _QuranEmpty extends StatelessWidget {
  const _QuranEmpty();

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return Center(
      child: Text(
        l10n.quran_empty,
        style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
      ),
    );
  }
}
