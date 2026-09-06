import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Hero glyph of the donation reward page: two overlapping gold coins with a
/// cream ring and a deep-green center (matches the mock). Painted — no asset —
/// so it scales crisply and inherits the reward glow. Swap the body for an
/// `Image.asset` if a brand illustration is provided later.
class RewardCoinsBadge extends StatelessWidget {
  const RewardCoinsBadge({super.key, this.size = 230});

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
        Assets.images.donationIllustration.path
      ),
    );
  }
}
