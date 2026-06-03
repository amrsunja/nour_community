import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/audio/audio_player_provider.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

/// Settings › Favourite reciter. Mirrors onboarding screen 7 but persists the
/// selection immediately on tap (no continue button). Stops any preview audio
/// when leaving the page.
@RoutePage()
class FavoriteReciterPage extends HookConsumerWidget {
  const FavoriteReciterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final settingsPresenter = ref.read(settingsProvider.notifier);
    final audioPresenter = ref.read(audioPlayerProvider.notifier);
    final audioState = ref.watch(audioPlayerProvider);

    final stored = ref.watch(
      settingsProvider.select((s) => s.data?.favoriteReciter),
    );

    final selected = useState<ReciterType>(
      stored ?? ReciterType.defaultReciter,
    );

    // Keep local selection in sync if the stored value changes elsewhere.
    useEffect(() {
      if (stored != null) selected.value = stored;
      return null;
    }, [stored]);

    // Stop preview playback when the page is disposed.
    useEffect(() {
      return () => audioPresenter.stop();
    }, const []);

    Future<void> onSelect(ReciterType reciter) async {
      selected.value = reciter; // optimistic
      await settingsPresenter.selectFavoriteReciter(reciter);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            title: l10n.settings_favorite_reciter,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                12,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.settings_favorite_reciter_info,
                    style: theme.typo.inter.bodyMedium.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                  const UISpace.vert(20),
                  for (var i = 0; i < ReciterType.values.length; i++)
                    Builder(builder: (_) {
                      final reciter = ReciterType.values[i];
                      final previewUrl =
                          QuranTool.getReciterPreviewUrl(reciter);
                      final isCurrent = audioState.isCurrent(previewUrl);
                      return Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                        child: UIAppearAnimation(
                          delay: Duration(milliseconds: 120 + i * 70),
                          offsetY: 18,
                          child: _ReciterCard(
                            reciter: reciter,
                            selected: selected.value == reciter,
                            isPlaying: isCurrent && audioState.isPlaying,
                            isLoadingPreview: isCurrent && audioState.isLoading,
                            onTap: () => onSelect(reciter),
                            onPreviewTap: () => audioPresenter.toggle(
                              url: previewUrl,
                              title: reciter.displayName,
                              artist: l10n.onboarding_screen_7_reciter_artist,
                              id: 'reciter-preview-${reciter.dbValue}',
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReciterCard extends StatelessWidget {
  const _ReciterCard({
    required this.reciter,
    required this.selected,
    required this.isPlaying,
    required this.isLoadingPreview,
    required this.onTap,
    required this.onPreviewTap,
  });

  final ReciterType reciter;
  final bool selected;
  final bool isPlaying;
  final bool isLoadingPreview;
  final VoidCallback onTap;
  final VoidCallback onPreviewTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final accent = UIColorsToken.textYellow;
    final iconColor = (isPlaying) ? accent : UIColorsToken.white;

    return UITap(
      onTap: onTap,
      child: UIGradientCard(
        selected: selected,
        child: Row(
          children: [
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: theme.typo.inter.title.copyWith(
                  color: selected ? accent : UIColorsToken.white,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(reciter.displayName),
              ),
            ),
            if (isLoadingPreview)
              UICircularProgressBar(size: 22)
            else
              UIIcon(
                UIIconsToken.icons.volume,
                color: iconColor,
                size: 22,
                onTap: onPreviewTap,
              ),
          ],
        ),
      ),
    );
  }
}
