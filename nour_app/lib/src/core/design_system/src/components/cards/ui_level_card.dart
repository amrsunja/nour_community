import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/design_system/src/components/cards/ui_selecteable_card.dart';

/// Two-state selectable card used in onboarding / preference screens.
/// When [selected] is true the border turns yellow, the title flips to
/// yellow and a soft yellow halo glows behind the card.
class UILevelCard extends StatelessWidget {
  const UILevelCard({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
    this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final accent = UIColorsToken.textYellow;

    return UITap(
      onTap: onTap,
      child: UISelecteableCard(
        selected: selected,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: theme.typo.inter.title.copyWith(
                color: selected ? accent : UIColorsToken.white,
              ),
              child: UIGlowingBlock(
                shadow: UIShadowToken.texts,
                child: Text(title, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.typo.inter.bodySmall.copyWith(
                color: selected ? accent : UIColorsToken.textParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
