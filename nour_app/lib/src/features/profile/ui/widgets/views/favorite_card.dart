import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// One row in a Favourites list: a dark rounded card with a white [title] and a
/// muted gold [subtitle] preview. Tapping opens the matching reader.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UICard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      disableBorder: true,
      shadows: [],
      color: UIColorsToken.black80,
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.inter.title.copyWith(color: UIColorsToken.white),
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const UISpace.vert(6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.inter.bodySmall.copyWith(
                color: UIColorsToken.textYellow,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
