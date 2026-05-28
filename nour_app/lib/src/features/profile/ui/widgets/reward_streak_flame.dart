import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Streak-reward hero glyph.
///
/// For days 1–6 it's a single flame. For the 7-day milestone it becomes a
/// "bigger fire": the base flame with two rotated copies fanned out behind it
/// (`stack(flame.rotate, flame.rotate, flame)`), matching the fuller flame in
/// the design.
class RewardStreakFlame extends StatelessWidget {
  const RewardStreakFlame({
    super.key,
    required this.streakDay,
    this.size = 220,
  });

  final int streakDay;
  final double size;

  bool get _isMilestone => streakDay >= 7;

  @override
  Widget build(BuildContext context) {
    final flame = Assets.images.illustration10.image(
      height: size,
      filterQuality: FilterQuality.high,
    );

    final Widget glyph = _isMilestone
        ? SizedBox(
            width: size * 1.5,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Two flames rotated outward behind the main one.
                Transform.translate(
                  offset: Offset(-size * 0.14, size * 0.02),
                  child: Transform.rotate(
                    angle: -0.30,
                    child: Opacity(
                      opacity: 0.95,
                      child: Assets.images.illustration10.image(
                        height: size * 0.82,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(size * 0.14, size * 0.02),
                  child: Transform.rotate(
                    angle: 0.30,
                    child: Opacity(
                      opacity: 0.95,
                      child: Assets.images.illustration10.image(
                        height: size * 0.82,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                flame,
              ],
            ),
          )
        : flame;

    return UIGlowingBlock(
      shadow: UIShadowToken.illustration,
      child: glyph,
    );
  }
}
