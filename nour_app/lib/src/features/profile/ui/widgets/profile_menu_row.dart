import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Tappable settings-style row: leading gold [icon], [label], trailing
/// directional chevron. Sits inside a flat [UICard].
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UIGradientCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      reverseGradient: true,
      child: Row(
        children: [
          Icon(icon, size: 24, color: UIColorsToken.textYellow),
          const UISpace.horz(16),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typo.inter.title
                  .copyWith(color: UIColorsToken.white),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 22,
            color: UIColorsToken.yellow,
          ),
        ],
      ),
    );
  }
}
