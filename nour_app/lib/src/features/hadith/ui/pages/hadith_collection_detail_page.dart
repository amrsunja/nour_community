import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../state_management/hadith_provider.dart';
import '../widgets/hadith_card_widget.dart';

/// Collection detail: the full list of hadiths in a collection as compact
/// cards (numbered star badge + title + quoted preview). Tapping a card opens
/// the immersive reader at that hadith.
@RoutePage()
class HadithCollectionDetailPage extends HookConsumerWidget {
  const HadithCollectionDetailPage({
    super.key,
    @PathParam('id') required this.collectionId,
  });

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(hadithProvider.notifier);
    final state = ref.watch(hadithProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await presenter.init();
        await presenter.loadHadiths(collectionId);
      });
      return null;
    }, [collectionId]);

    final collection =
        state.collections.firstWhereOrNull((c) => c.id == collectionId);

    final hadiths = state.hadithsOf(collectionId);
    final progress = state.progressOf(collectionId);
    final isLoading =
        (state.isLoadingCollection(collectionId) || collection == null) &&
            hadiths.isEmpty;

    return Scaffold(
      appBar: UIAppBar(
        title: collection?.title(langCode) ?? l10n.hadith_title,
        onBack: context.pop,
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(child: UICircularProgressBar())
            : hadiths.isEmpty
                ? Center(
                    child: Text(
                      l10n.hadith_empty,
                      style: UITheme.of(context).typo.inter.bodyMedium.copyWith(
                            color: UIColorsToken.textParagraph,
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: hadiths.length,
                    separatorBuilder: (_, __) => const UISpace.vert(12),
                    itemBuilder: (context, index) {
                      final hadith = hadiths[index];
                      return HadithCardWidget(
                        hadith: hadith,
                        number: index + 1,
                        isLiked: state.isHadithLiked(hadith.id),
                        isCurrent: progress?.currentHadithId == hadith.id,
                        onTap: () => nav.toHadithReader(
                          collectionId: collectionId,
                          initialHadithId: hadith.id,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
