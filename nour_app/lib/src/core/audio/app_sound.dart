import 'package:nour/gen/assets.gen.dart';

/// Single source of truth for every in-app one-shot sound effect.
///
/// Each entry maps a semantic event to its bundled asset (resolved by
/// [AppSoundAsset.asset]). Add new sounds here only — the [SoundEffectService]
/// preloads and plays purely off this enum, so nothing else in the app needs
/// to know asset paths or string ids.
enum AppSound {
  /// Splash screen logo animation.
  logo,

  // ---- Quiz ----
  /// Correct answer submitted / validated.
  correctAnswer,

  /// Wrong answer submitted / validated.
  wrongAnswer,

  // ---- Streaks & achievements (ascending importance) ----
  /// Basic achievement: daily streak day, small milestone, first level.
  achievement1,

  /// Medium achievement: significant streak milestone, progression reward.
  achievement2,

  /// Major achievement: quiz completion, high-value success / progression.
  achievement3,

  // ---- Quran ----
  /// Quran page turn (next / previous ayah).
  paperSlide,
}

extension AppSoundAsset on AppSound {
  /// Bundled asset path, resolved through `flutter_gen` so the registry stays
  /// the single source of truth. Resolved at runtime (gen getters aren't const).
  String get asset {
    switch (this) {
      case AppSound.logo:
        return Assets.sounds.logo;
      case AppSound.correctAnswer:
        return Assets.sounds.correctAnswer;
      case AppSound.wrongAnswer:
        return Assets.sounds.wrongAnswer;
      case AppSound.achievement1:
        return Assets.sounds.achievement1;
      case AppSound.achievement2:
        return Assets.sounds.achievement2;
      case AppSound.achievement3:
        return Assets.sounds.achievement3;
      case AppSound.paperSlide:
        return Assets.sounds.paperSlide;
    }
  }

  /// Stable native-engine id. Enum name is unique and constant.
  String get id => name;
}
