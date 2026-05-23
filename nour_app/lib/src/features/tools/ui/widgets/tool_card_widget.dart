import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Grid cell for the Tools page: a dark [UICard] with a glowing illustration
/// (via [UIGlowingBlock] inside [UIToolCard]) and a label beneath.
///
/// Thin wrapper over [UIToolCard] that lets the card flex to the grid cell
/// (no fixed width/height) and exposes [onTap].
class ToolCardWidget extends StatelessWidget {
  const ToolCardWidget({
    super.key,
    required this.illustration,
    required this.label,
    this.onTap,
  });

  /// Tool illustration asset, e.g. `Assets.images.illustration15.image()`.
  final Widget illustration;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UICard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      color: UIColorsToken.black80,
      disableBorder: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: UIGlowingBlock(
                  shadow: UIShadowToken.texts,
                  child: illustration,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typo.inter.title.copyWith(
              color: UIColorsToken.white,
            ),
          ),
        ],
      ),
    );
  }
}
