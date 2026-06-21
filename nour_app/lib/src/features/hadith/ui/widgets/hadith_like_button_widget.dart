import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Heart toggle + formatted like count for a hadith.
///
/// Stateless / controlled — the parent owns [isLiked] and [count] (from
/// `HadithState`) and reacts to [onTap]. The visual flips immediately because
/// the presenter applies the like optimistically.
class HadithLikeButtonWidget extends StatelessWidget {
  const HadithLikeButtonWidget({
    super.key,
    required this.isLiked,
    required this.count,
    this.onTap,
  });

  final bool isLiked;
  final int count;
  final VoidCallback? onTap;

  static String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(2)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UITap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? UIColorsToken.red : UIColorsToken.white,
            size: 24,
          ),
          const UISpace.vert(2),
          Text(
            _format(count),
            style: typo.inter.smallCaption
          ),
        ],
      ),
    );
  }
}
