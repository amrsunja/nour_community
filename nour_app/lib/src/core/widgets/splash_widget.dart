import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/providers/audio/sound_effect_provider.dart';

class SplashWidget extends HookConsumerWidget {
  const SplashWidget({
    super.key,
    this.playSound = true
  });

  final bool playSound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: Duration(seconds: 3)
    );

    return Scaffold(
      backgroundColor: UIColorsToken.bgTertiaryGreen,
      body: Center(
        child: Lottie.asset(
          'assets/lotties/logo_animation.json',
          controller: controller,
          height: 100,
          onLoaded: (composition) {
            // Configure the AnimationController with the duration of the
            // Lottie file and start the animation, with the logo sound.
            controller
              ..duration = composition.duration
              ..forward();

            if (!playSound) return ;

            ref.read(soundEffectServiceProvider).playLogo();
          },
        ),
      ),
    ).animate(effects: [FadeEffect(duration: Duration(milliseconds: 700))]);
  }
}
