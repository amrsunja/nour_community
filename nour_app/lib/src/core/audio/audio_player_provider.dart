import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import 'audio_player_state.dart';

/// Global player instance. We intentionally keep a single, app-wide
/// [AudioPlayer] so only one audio plays at a time — switching sources
/// stops the previous one automatically.
final AudioPlayer audioPlayer = AudioPlayer();

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerPresenter, AudioPlayerState>(
  (ref) => AudioPlayerPresenter(player: audioPlayer),
);

class AudioPlayerPresenter extends Presenter<AudioPlayerState> {
  final AudioPlayer player;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  AudioPlayerPresenter({required this.player})
      : super(AudioPlayerState.initial) {
    _bindStreams();
  }

  void _bindStreams() {
    _stateSub = player.playerStateStream.listen((s) {
      state = state.copyWith(
        isPlaying: s.playing && s.processingState != ProcessingState.completed,
        processingState: s.processingState,
      );
    });
    _positionSub = player.positionStream.listen((p) {
      state = state.copyWith(position: p);
    });
    _durationSub = player.durationStream.listen((d) {
      state = state.copyWith(duration: d);
    });
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  /// Plays [url] from network. If a different URL is currently loaded the
  /// previous source is replaced. If the same URL is already loaded, this
  /// just resumes/restarts playback.
  Future<void> playFromUrl(
    String url, {
    required String title,
    String? artist,
    String? album,
    String? artUri,
    String? id,
  }) async {
    try {
      if (state.currentUrl == url) {
        // Same source — restart from beginning if completed, else just play.
        if (state.isCompleted) {
          await player.seek(Duration.zero);
        }
        await player.play();
        return;
      }

      state = state.copyWith(
        currentUrl: url,
        processingState: ProcessingState.loading,
        position: Duration.zero,
        duration: null,
        errorMessage: null,
      );

      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: id ?? url,
          title: title,
          artist: artist,
          album: album,
          artUri: artUri == null ? null : Uri.parse(artUri),
        ),
      );

      await player.setAudioSource(source);
      await player.play();
    } catch (e, st) {
      talker.error('AudioPlayer.playFromUrl failed', e, st);
      state = state.copyWith(
        errorMessage: e.toString(),
        processingState: ProcessingState.idle,
        isPlaying: false,
      );
    }
  }

  Future<void> pause() => player.pause();

  Future<void> resume() => player.play();

  /// Toggle play/pause for the currently loaded source. If [url] is passed
  /// and differs from the current one, [playFromUrl] is invoked instead.
  Future<void> toggle({
    String? url,
    String? title,
    String? artist,
    String? album,
    String? artUri,
    String? id,
  }) async {
    if (url != null && state.currentUrl != url) {
      await playFromUrl(
        url,
        title: title ?? 'Audio',
        artist: artist,
        album: album,
        artUri: artUri,
        id: id,
      );
      return;
    }
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> stop() async {
    await player.stop();
    state = AudioPlayerState.initial;
  }

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  Future<void> setVolume(double volume) => player.setVolume(volume);

  @override
  void dispose() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }
}
