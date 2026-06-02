import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UiRepeatShimerAnimation extends HookWidget {
  const UiRepeatShimerAnimation({
    super.key,
    required this.child
  });

  final Widget child;

  @override
  Widget build(BuildContext context, ) {
    final controller = useAnimationController();

    return child.animate(
      controller: controller,
      onPlay: (c) => c.repeat()
    ).shimmer(
      duration: const Duration(seconds: 1),
      delay: const Duration(seconds: 3),
      color: UIColorsToken.white.withValues(alpha: 0.35),
    );
  }
}


