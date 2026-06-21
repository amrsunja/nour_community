import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// A single statistic tile on the profile statistics page.
///
/// Two layouts share one widget:
///  * default (square) — centered glowing illustration, label + value pinned to
///    the bottom-left. Used for the two-up top row.
///  * [wide] — label + value stacked on the left, illustration on the right.
///    Used for the full-width bottom card.
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.asset,
    this.wide = false,
  });

  final String label;
  final int value;
  final AssetGenImage asset;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
    );

    final valueText = Text(
      _format(value),
      style: typo.inter.display.copyWith(
        color: UIColorsToken.white,
        fontWeight: FontWeight.w700,
      ),
    );

    if (wide) {
      return UICard(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        color: UIColorsToken.black80,
        shadows: [],
        disableBorder: true,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  labelText,
                  const UISpace.vert(8),
                  valueText,
                ],
              ),
            ),
            const UISpace.horz(12),
            _Illustration(asset: asset, size: 84),
          ],
        ),
      );
    }

    return UICard(
      height: 220,
      color: UIColorsToken.black80,
      shadows: [],
      disableBorder: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(child: _Illustration(asset: asset, size: 96)),
          ),
          const UISpace.vert(20),
          labelText,
          const UISpace.vert(6),
          valueText,
        ],
      ),
    );
  }

  /// Compact count: 4600 -> "4.6k", 250 -> "250".
  static String _format(int value) {
    if (value < 1000) return '$value';
    final k = value / 1000;
    final text = k.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text}k';
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.asset, required this.size});

  final AssetGenImage asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return UIGlowingBlock(
      shadow: UIShadowToken.texts,
      child: asset.image(height: size, filterQuality: FilterQuality.high),
    );
  }
}
