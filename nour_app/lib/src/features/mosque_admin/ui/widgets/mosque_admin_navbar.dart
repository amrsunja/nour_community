import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Bottom bar of the mosque admin shell: Dashboard · Community · Mosque and a
/// raised "+ Post" button (Figma "Dashboard - Nour mosques").
class MosqueAdminNavBar extends StatelessWidget {
  const MosqueAdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onPost,
    required this.labels,
    required this.postLabel,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onPost;
  /// Dashboard, Community, Mosque.
  final List<String> labels;
  final String postLabel;

  static const _icons = [Icons.grid_view_rounded, Icons.public, Icons.mosque_outlined];

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 68,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: UIColorsToken.bgSurface,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: UIColorsToken.stroke.withValues(alpha: .15)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Expanded(
                        child: UITap(
                          onTap: () => onChanged(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            decoration: BoxDecoration(
                              color: currentIndex == i ? UIColorsToken.bgTertiaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(34),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _icons[i],
                                  size: 20,
                                  color: currentIndex == i ? UIColorsToken.textYellow : UIColorsToken.textParagraph,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typo.inter.smallCaption.copyWith(
                                    color: currentIndex == i ? UIColorsToken.textYellow : UIColorsToken.textParagraph,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            UITap(
              onTap: onPost,
              child: Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: UIColorsToken.bgSecondaryGreen,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: UIColorsToken.textYellow, size: 22),
                    Text(
                      postLabel,
                      style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textYellow),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
