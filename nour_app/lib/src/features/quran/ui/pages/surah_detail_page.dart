import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../state_management/quran_provider.dart';
import '../widgets/quran_ayah_card_widget.dart';

/// Surah detail: header (name + verse count / place) and the full ayah list.
/// Tapping an ayah opens the immersive reader. Reading progress is recorded
/// when the screen is left (the surah becomes the "continue reading" position).
@RoutePage()
class SurahDetailPage extends HookConsumerWidget {
  const SurahDetailPage({
    super.key,
    required this.surahNumber,
  });

  final int surahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = UITheme.of(context).typo;
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(quranProvider.notifier);
    final state = ref.watch(quranProvider);

    final surah = useMemoized(() => presenter.getSurah(surahNumber), [surahNumber]);
    final ayahs =
        useMemoized(() => presenter.getSurahAyahs(surahNumber), [surahNumber]);

    useEffect(() {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => presenter.loadSurahLikes(surahNumber));
      return null;
    }, [surahNumber]);

    // Record this surah as the reading position on leave — but never regress an
    // ayah the reader already advanced within the same surah.
    Future<void> persistOnLeave() async {
      final progress = state.progress;
      if (progress != null && progress.surahNumber == surahNumber) return;
      await presenter.saveProgress(surahNumber: surahNumber, ayahNumber: 1);
    }

    final place = surah.isMakki ? l10n.quran_meccan : l10n.quran_medinan;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) persistOnLeave();
      },
      child: Scaffold(
        appBar: UIAppBar(title: surah.nameEnglish, onBack: context.pop),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Text(
                      surah.nameArabic,
                      textDirection: TextDirection.rtl,
                      style: typo.inter.hero.copyWith(color: UIColorsToken.textYellow),
                    ),
                    const UISpace.vert(8),
                    Text(
                      '${surah.versesCount} ${l10n.quran_verses}  |  $place',
                      style: typo.inter.bodyMedium.copyWith(
                        color: UIColorsToken.textParagraph,
                      ),
                    ),
                    const UISpace.vert(8),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: ayahs.length,
                separatorBuilder: (_, __) => const UISpace.vert(12),
                itemBuilder: (context, index) {
                  final ayah = ayahs[index];
                  return QuranAyahCardWidget(
                    ayah: ayah,
                    isLiked: state.isAyahLiked(surahNumber, ayah.ayahNumber),
                    onTap: () => nav.toAyahReader(
                      surahNumber: surahNumber,
                      initialAyah: ayah.ayahNumber,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
