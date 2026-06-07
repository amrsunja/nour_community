import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:sound_effect/sound_effect.dart';

/// Low-latency one-shot sound effects (splash logo, reward celebrations).
///
/// Lazily initializes the native engine and preloads all effects on first
/// use. Play calls never throw — a missing/failed sound must not break UI.
class SoundEffectService {
  SoundEffectService();

  static const _logoId = 'logo';
  static const _rewardId = 'reward';

  final _soundEffect = SoundEffect();
  Future<void>? _init;

  Future<void> _ensureInitialized() => _init ??= () async {
        await _soundEffect.initialize();
        await _soundEffect.load(_logoId, Assets.sounds.logo);
        await _soundEffect.load(_rewardId, Assets.sounds.reward);
      }();

  /// Splash screen logo animation sound.
  Future<void> playLogo() => _play(_logoId);

  /// Reward screens celebration sound.
  Future<void> playReward() => _play(_rewardId);

  Future<void> _play(String id) async {
    try {
      await _ensureInitialized();
      await _soundEffect.play(id);
    } catch (e, st) {
      talker.error('SoundEffectService: failed to play "$id"', e, st);
    }
  }

  void dispose() {
    _soundEffect.release();
    _init = null;
  }
}
