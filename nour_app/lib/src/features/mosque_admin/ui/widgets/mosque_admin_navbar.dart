import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:blur/blur.dart';

/// Bottom bar of the mosque admin shell: a translucent pill holding the three
/// primary tabs (Dashboard / Community / Mosque) plus a detached circular
/// "Post" action on the trailing edge, mirroring [UINavBar].
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

  static const double _height = 58;
  static const Color _inactive = UIColorsToken.bgSecondaryGreen;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo.inter;

    final tabs = <_NavItem>[
      _NavItem(icon: Assets.icons.tools, label: labels[0]),
      _NavItem(icon: Assets.icons.world, label: labels[1]),
      _NavItem(icon: Assets.icons.masjid, label: labels[2]),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_height),
              child: Container(
                height: _height,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                        child: _NavTab(
                          item: tabs[i],
                          selected: i == currentIndex,
                          textStyle: typo.smallCaption,
                          inactiveColor: _inactive,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ).frosted(
                blur: 5,
                frostColor: Color(0xffAEAEAE),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PostButton(
            size: _height,
            label: postLabel,
            textStyle: typo.smallCaption,
            onTap: onPost,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final String icon;
  final String label;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.textStyle,
    required this.inactiveColor,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final TextStyle textStyle;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? UIColorsToken.textYellow : inactiveColor;

    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: selected ? UIColorsToken.bgSecondaryGreen : null,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UIIconsToken.toIcon(item.icon, color: color, size: 22),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  const _PostButton({
    required this.size,
    required this.label,
    required this.textStyle,
    required this.onTap,
  });

  final double size;
  final String label;
  final TextStyle textStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: UICard(
          borderRadius: 100,
          colors: [
            Color(0xff45513F),
            Color(0xff2B3326),
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: UIColorsToken.textYellow,
                size: 22,
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle.copyWith(
                    color: UIColorsToken.textYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
