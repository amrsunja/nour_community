import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/share_services.dart';

import '../../data/models/adhkar_model.dart';
import '../state_management/adhkar_provider.dart';

@RoutePage()
class AdhkarDetailPage extends HookConsumerWidget {
  const AdhkarDetailPage({
    super.key,
    @PathParam('id') required this.subcategoryId,
    @QueryParam('adhkarId') this.initialAdhkarId,
  });

  final int subcategoryId;

  /// When set (e.g. opened from Favourites), the pager jumps straight to this
  /// adhkar within the subcategory instead of starting at the first one.
  final int? initialAdhkarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(adhkarProvider.notifier);
    final state = ref.watch(adhkarProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    final subcategory =
        state.subcategories.firstWhereOrNull((s) => s.id == subcategoryId);
    final adhkars = state.adhkarsOf(subcategoryId);

    final pageController = usePageController();
    final index = useState(0);
    final showTranscription = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => presenter.ensureAdhkars(subcategoryId),
      );
      return null;
    }, const []);

    // Jump to the requested adhkar once the list is available (deep-link from
    // Favourites). Runs once: guarded by [jumped].
    final jumped = useRef(false);
    useEffect(() {
      if (jumped.value || initialAdhkarId == null || adhkars.isEmpty) {
        return null;
      }
      final target = adhkars.indexWhere((a) => a.id == initialAdhkarId);
      if (target > 0) {
        jumped.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.jumpToPage(target);
          }
          index.value = target;
        });
      } else if (target == 0) {
        jumped.value = true;
      }
      return null;
    }, [adhkars.length]);

    final isLoading = state.isLoadingAdhkars(subcategoryId) && adhkars.isEmpty;

    return UIGradientLinedScaffold(
      bgArabicText: 'وَزِنَةَ عَرْشِهِ',
      appBar: UIAppBar(
        title: subcategory?.title(langCode) ?? '',
        onBack: context.pop,
      ),
      body: isLoading
          ? const Center(child: UICircularProgressBar())
          : adhkars.isEmpty
              ? Center(
                  child: Text(
                    l10n.adhkar_empty,
                    style: UITheme.of(context).typo.inter.bodyMedium.copyWith(
                          color: UIColorsToken.textParagraph,
                        ),
                  ),
                )
              : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      onPageChanged: (i) {
                        index.value = i;
                        showTranscription.value = false;
                      },
                      itemCount: adhkars.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                        child: _AdhkarPage(
                          adhkar: adhkars[i],
                          langCode: langCode,
                          showTranscription: showTranscription.value,
                          onToggleTranscription: () => showTranscription.value =
                              !showTranscription.value,
                          onShare: () => _share(adhkars[i], langCode),
                        ),
                      ),
                    ),
                  ),
                  _BottomBar(
                    current: index.value + 1,
                    total: adhkars.length,
                    isFirst: index.value <= 0,
                    isLast: index.value >= adhkars.length - 1,
                    onPrev: () => pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    ),
                    onNext: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    ),
                    onDone: context.pop,
                  ),
                  const UISpace.vert(12),
                ],
              ),
    );
  }

  Future<void> _share(AdhkarModel adhkar, String langCode) =>
      ShareServices.shareAdhkar(
        title: adhkar.when(langCode),
        arabicText: adhkar.arabicText,
        translation: adhkar.translation(langCode),
        reference: adhkar.reference(langCode),
        subcategoryId: adhkar.subcategoryId,
        adhkarId: adhkar.id,
      );
}

/// One swipeable adhkar: the green top card + the translation below it.
class _AdhkarPage extends StatelessWidget {
  const _AdhkarPage({
    required this.adhkar,
    required this.langCode,
    required this.showTranscription,
    required this.onToggleTranscription,
    required this.onShare,
  });

  final AdhkarModel adhkar;
  final String langCode;
  final bool showTranscription;
  final VoidCallback onToggleTranscription;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final translation = adhkar.translation(langCode);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UISpace.vert(8),
          UICard(
            colors: const [Color(0xff45513F), Color(0xff2B3326)],
            padding: const EdgeInsets.all(12),
            begin: .centerLeft,
            end: .centerRight,
            shadows: [],
            disableBorder: true,
            child: Column(
              children: [
                // 1. when_xx → title
                if (adhkar.when(langCode)?.isNotEmpty ?? false)
                  Text(
                    adhkar.when(langCode)!,
                    textAlign: TextAlign.center,
                    style: typo.inter.title,
                  ),
                const UISpace.vert(20),
                // 2. arabic text
                Text(
                  adhkar.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: typo.inter.largeTitle.copyWith(
                    height: 1.8,
                  ),
                ),
                // transcription, toggled by the "Aa" button
                if (showTranscription && (adhkar.transcription(langCode)?.isNotEmpty ?? false)) ...[
                  const UISpace.vert(12),
                  UIAppearAnimation(
                    child: Text(
                      adhkar.transcription(langCode)!,
                      textAlign: TextAlign.center,
                      style: typo.inter.bodyMedium.copyWith(
                        color: UIColorsToken.textYellow,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const UISpace.vert(16),
                // 3. row: share | reference | transcription toggle
                Row(
                  children: [
                    UIIcon(
                      UIIconsToken.icons.share,
                      color: UIColorsToken.white,
                      onTap: onShare,
                    ),
                    Expanded(
                      child: Text(
                        adhkar.reference(langCode) ?? '',
                        textAlign: TextAlign.center,
                        style: typo.inter.bodySmall.copyWith(
                          color: UIColorsToken.textParagraph,
                        ),
                      ),
                    ),
                    UIIcon(
                      UIIconsToken.icons.aa,
                      color: showTranscription ? UIColorsToken.textYellow : UIColorsToken.white,
                      onTap: onToggleTranscription,
                    )
                  ],
                ),
              ],
            ),
          ),
          const UISpace.vert(24),
          // 4. translation (display)
          if (translation?.isNotEmpty ?? false)
            Text(
              translation!,
              style: typo.inter.display,
            ),
          const UISpace.vert(16),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.current,
    required this.total,
    required this.isFirst,
    required this.isLast,
    required this.onPrev,
    required this.onNext,
    required this.onDone,
  });

  final int current;
  final int total;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Expanded(
            child: _ArrowButton(
              icon: Icons.arrow_back_rounded,
              enabled: !isFirst,
              onTap: onPrev,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current/$total',
                textAlign: TextAlign.center,
                style: typo.inter.title.copyWith(color: UIColorsToken.white),
              ),
              if (isLast) ...[
                const UISpace.vert(8),
                UIAppearAnimation(
                  child: SizedBox(
                    width: 120,
                    child: UIButton.primary(
                      label: AppLocale.of(context).dhikr_done,
                      onTap: onDone,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Expanded(
            child: _ArrowButton(
              icon: Icons.arrow_forward_rounded,
              enabled: !isLast,
              onTap: onNext,
            ),
          ),
        ],
      ),
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
