import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:sound_effect/sound_effect.dart';

import 'app_sound.dart';

/// Centralized, low-latency one-shot sound effects.
///
/// This is the single playback authority for every UI sound effect (quiz
/// feedback, achievements, Quran page turns, splash logo). Features call
/// [play] with an [AppSound] — they never touch asset paths or the native
/// engine directly, which keeps playback logic in one place and trivially
/// scalable (add an enum case, nothing else).
///
/// Behaviour:
///  - Lazily initializes the native engine and preloads **all** effects on
///    first use.
///  - Serializes calls so two effects never race the platform channel.
///  - Debounces identical effects within [_debounce] to prevent the same sound
///    firing multiple times simultaneously from widget rebuilds / rapid taps.
///  - Never throws — a missing/failed sound must not break the UI.
class SoundEffectService {
  SoundEffectService();

  /// Re-trigger window for the *same* effect. Guards against duplicate /
  /// overlapping playback from rebuilds or double taps.
  static const _debounce = Duration(milliseconds: 120);

  final _soundEffect = SoundEffect();
  final _lastPlayed = <AppSound, DateTime>{};

  Future<void>? _init;
  Future<void> _chain = Future.value();

  Future<void> _ensureInitialized() => _init ??= () async {
        await _soundEffect.initialize();
        for (final sound in AppSound.values) {
          await _soundEffect.load(sound.id, sound.asset);
        }
      }();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Splash screen logo animation sound.
  Future<void> playLogo() => play(AppSound.logo);

  /// Quiz answer feedback — correct or wrong based on [isCorrect].
  Future<void> playQuizAnswer({required bool isCorrect}) =>
      play(isCorrect ? AppSound.correctAnswer : AppSound.wrongAnswer);

  /// Quran page-turn sound.
  Future<void> playPageTurn() => play(AppSound.paperSlide);

  /// Play any effect. Debounced per-sound and serialized across all sounds.
  Future<void> play(AppSound sound) {
    final now = DateTime.now();
    final last = _lastPlayed[sound];
    if (last != null && now.difference(last) < _debounce) {
      return Future.value();
    }
    _lastPlayed[sound] = now;

    // Serialize on a single chain so plays never overlap on the channel.
    _chain = _chain.then((_) => _play(sound));
    return _chain;
  }

  Future<void> _play(AppSound sound) async {
    try {
      await _ensureInitialized();
      await _soundEffect.play(sound.id);
    } catch (e, st) {
      talker.error('SoundEffectService: failed to play "${sound.id}"', e, st);
    }
  }

  void dispose() {
    _soundEffect.release();
    _init = null;
    _lastPlayed.clear();
  }
}
