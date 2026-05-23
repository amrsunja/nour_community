import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/audio/audio_player_provider.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Play / pause / loading control for a single hadith recitation.
///
/// Bound to the global [audioPlayerProvider] so only one source plays at a
/// time. State is derived from whether [audioUrl] is the player's current
/// source — identical contract to the Quran ayah audio button.
class HadithAudioButtonWidget extends ConsumerWidget {
  const HadithAudioButtonWidget({
    super.key,
    required this.audioUrl,
    required this.title,
    this.artist,
  });

  final String audioUrl;
  final String title;
  final String? artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioPlayerProvider);
    final controller = ref.read(audioPlayerProvider.notifier);

    final isCurrent = audio.isCurrent(audioUrl);
    final isLoading = isCurrent && audio.isLoading;
    final isPlaying = isCurrent && audio.isPlaying;

    return UITap(
      onTap: () => controller.toggle(
        url: audioUrl,
        title: title,
        artist: artist,
        id: audioUrl,
      ),
      child: Container(
        height: 30,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: UIColorsToken.bgPriYellow,
          borderRadius: BorderRadius.circular(8),
          boxShadow: UIShadowToken.kMd,
        ),
        child: isLoading
            ? const UICircularProgressBar(color: UIColorsToken.white, size: 15)
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: UIColorsToken.white,
                size: 30,
              ),
      ),
    );
  }
}
