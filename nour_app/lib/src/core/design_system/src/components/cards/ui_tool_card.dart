import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Square-ish dark card showcasing a feature/tool illustration with a label
/// beneath. Used in onboarding "feature highlight" stacks and tool grids.
class UIToolCard extends StatelessWidget {
  const UIToolCard({
    super.key,
    required this.illustration,
    required this.label,
    this.width = 170,
    this.height = 210,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 18),
  });

  final Widget illustration;
  final String label;
  final double width;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UICard(
      width: width,
      height: height,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: UIGlowingBlock(child: illustration),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typo.inter.body.copyWith(
              color: UIColorsToken.white,
            ),
          ),
        ],
      ),
    );
  }
}
