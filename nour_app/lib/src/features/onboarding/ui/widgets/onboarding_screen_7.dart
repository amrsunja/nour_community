import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/audio/audio_player_provider.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/enums/reciter_type.dart';
import 'package:nour/src/core/utils/islamic_tools/quran_tool.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/settings_provider.dart';

class OnboardingScreen7 extends HookConsumerWidget {
  const OnboardingScreen7({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final onboarding = ref.read(onboardingProvider.notifier);
    final settingsPresenter = ref.read(settingsProvider.notifier);
    final audioPresenter = ref.read(audioPlayerProvider.notifier);
    final audioState = ref.watch(audioPlayerProvider);

    final stored = ref.watch(
      settingsProvider.select((s) => s.data?.favoriteReciter),
    );
    final isLoading = ref.watch(
      settingsProvider.select((s) => s.isLoading),
    );

    final selected = useState<ReciterType>(stored ?? ReciterType.defaultReciter);

    Future<void> onContinue() async {
      await audioPresenter.stop();
      final ok = await settingsPresenter.selectFavoriteReciter(selected.value);
      if (ok) onboarding.changePage(7);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  UISpace.vert(80),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      l10n.onboarding_screen_7_title,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.largeTitle.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 220),
                    child: Text(
                      l10n.onboarding_screen_7_description,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.bodyLarge.copyWith(
                        color: UIColorsToken.textParagraph,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  for (var i = 0; i < ReciterType.values.length; i++)
                    Builder(builder: (_) {
                      final reciter = ReciterType.values[i];
                      final previewUrl =
                          QuranTool.getReciterPreviewUrl(reciter);
                      final isCurrent = audioState.isCurrent(previewUrl);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UIAppearAnimation(
                          delay: Duration(milliseconds: 320 + i * 70),
                          offsetY: 18,
                          child: _ReciterCard(
                            reciter: reciter,
                            selected: selected.value == reciter,
                            isPlaying: isCurrent && audioState.isPlaying,
                            isLoadingPreview: isCurrent && audioState.isLoading,
                            onTap: () => selected.value = reciter,
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
          UIAppearAnimation(
            delay: const Duration(milliseconds: 900),
            offsetY: 16,
            child: UIButton.primary(
              label: l10n.common_continue,
              fullWidth: true,
              isBusy: isLoading,
              onTap: onContinue,
            ),
          ),
          const UISpace.vert(10),
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
