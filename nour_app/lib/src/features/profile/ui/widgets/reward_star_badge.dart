import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Daily-dhikr reward hero glyph: a faceted gold 8-pointed star sitting on a
/// soft scalloped green halo with a thin gold filigree outline — painted
/// (no asset) so it scales crisply and carries the yellow glow.
class RewardStarBadge extends StatelessWidget {
  const RewardStarBadge({super.key, this.size = 230});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: UIShadowToken.illustration,
      ),
      child: Image.asset(
        Assets.images.illustration3.path
      ),
    );
  }
}
