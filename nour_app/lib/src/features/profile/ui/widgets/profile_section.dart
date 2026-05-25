import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Labelled group of profile rows: a muted section title above a vertical
/// stack of [children] (typically [ProfileMenuRow]s).
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
    this.gap = 12,
  });

  final String title;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            title,
            style: theme.typo.inter.bodyMedium
                .copyWith(color: UIColorsToken.textParagraph),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: children,
        ),
      ],
    );
  }
}
