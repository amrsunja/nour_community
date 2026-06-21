import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../state_management/hadith_provider.dart';
import '../widgets/hadith_collection_card_widget.dart';

/// Hadith tab body: the list of hadith collections (author books). Each card
/// opens the collection detail; a collection the user has started also exposes
/// a progress line + "Resume" that reopens the reader at the saved hadith.
///
/// Owns its own load lifecycle and renders loading / error / empty states —
/// the mirror of [QuranSourceView] for the Hadith source.
class HadithsPage extends HookConsumerWidget {
  const HadithsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(hadithProvider.notifier);
    final state = ref.watch(hadithProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    if (state.isLoading && state.isEmpty) {
      return const Center(child: UICircularProgressBar());
    }

    if (state.hasError && state.isEmpty) {
      return _HadithError(onRetry: presenter.retry);
    }

    if (state.isEmpty) {
      return const _HadithEmpty();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...state.collections.map((collection) {
            final progress = state.progressOf(collection.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HadithCollectionCardWidget(
                collection: collection,
                readCount: progress?.currentPosition == null ? 0 : progress!.currentPosition + 1,
                onTap: () => nav.toHadithCollectionDetail(
                  collectionId: collection.id,
                ),
                onResume: progress?.currentHadithId == null
                    ? null
                    : () => nav.toHadithReader(
                          collectionId: collection.id,
                          initialHadithId: progress!.currentHadithId!,
                        ),
              ),
            );
          }),
        ].animate(effects: [FadeEffect()]),
      ),
    );
  }
}

class _HadithError extends StatelessWidget {
  const _HadithError({required this.onRetry});

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
            const Icon(Icons.error_outline,
                color: UIColorsToken.textYellow, size: 44),
            const UISpace.vert(12),
            Text(
              l10n.hadith_error_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(6),
            Text(
              l10n.hadith_error_subtitle,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(16),
            UIButton.primary(label: l10n.hadith_try_again, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _HadithEmpty extends StatelessWidget {
  const _HadithEmpty();

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return Center(
      child: Text(
        l10n.hadith_empty,
        style:
            typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
      ),
    );
  }
}
