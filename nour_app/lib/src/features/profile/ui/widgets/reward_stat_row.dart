import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// A single stat line on the daily-dhikr reward: a label on the left, an
/// illustration + value on the right, in a dark rounded card.
///
/// ```dart
/// RewardStatRow(label: 'Ajr earned', asset: Assets.images.illustration5, value: 10)
/// ```
class RewardStatRow extends StatelessWidget {
  const RewardStatRow({
    super.key,
    required this.label,
    required this.asset,
    required this.value,
  });

  final String label;
  final AssetGenImage asset;
  final int value;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.inter.bodyLarge.copyWith(color: UIColorsToken.white),
            ),
          ),
          UIGlowingBlock(
            shadow: UIShadowToken.smallTexts,
            child: asset.image(height: 30, filterQuality: FilterQuality.high),
          ),
          const UISpace.horz(10),
          Text(
            '$value',
            style: typo.inter.largeTitle.copyWith(
              color: UIColorsToken.textYellow,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
