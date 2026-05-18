import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class SplashWidget extends HookWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Lottie file and start the animation.
            controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    ).animate(effects: [FadeEffect(duration: Duration(milliseconds: 700))]);
  }
}
