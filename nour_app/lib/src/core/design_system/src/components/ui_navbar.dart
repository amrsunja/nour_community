import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:blur/blur.dart';


/// Bottom navigation: a translucent pill holding the four primary tabs
/// (Home / Source / Impact / Tools) plus a detached circular Dhikr action
/// on the trailing edge that uses the `arabic_text` asset as its backdrop.
class UINavBar extends StatelessWidget {
  const UINavBar({
    super.key,
    required this.currentPage,
    required this.onPageChange,
    this.onDhikrTap,
    this.homeLabel = 'Home',
    this.sourceLabel = 'Source',
    this.impactLabel = 'Impact',
    this.toolsLabel = 'Tools',
    this.dhikrLabel = 'Dhikr',
  });

  final int currentPage;
  final ValueChanged<int> onPageChange;
  final VoidCallback? onDhikrTap;

  final String homeLabel;
  final String sourceLabel;
  final String impactLabel;
  final String toolsLabel;
  final String dhikrLabel;

  static const double _height = 58;
  static const Color _inactive = UIColorsToken.bgSecondaryGreen;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo.inter;

    final tabs = <_NavItem>[
      _NavItem(icon: Assets.icons.home, label: homeLabel),
      _NavItem(icon: Assets.icons.source, label: sourceLabel),
      _NavItem(icon: Assets.icons.impact, label: impactLabel),
      _NavItem(icon: Assets.icons.tools, label: toolsLabel),
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
                          selected: i == currentPage,
                          textStyle: typo.smallCaption,
                          inactiveColor: _inactive,
                          onTap: () => onPageChange(i),
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
          _DhikrButton(
            size: _height,
            label: dhikrLabel,
            textStyle: typo.smallCaption,
            onTap: onDhikrTap,
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
        padding: .symmetric(horizontal: 5),
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

class _DhikrButton extends StatelessWidget {
  const _DhikrButton({
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: UICard(
          borderRadius: 100,
          colors: [
            Color(0xff45513F),
            Color(0xff2B3326),
          ],
          child: Stack(
            fit: StackFit.expand,
            children: [
              // arabic_text backdrop, dimmed under a green wash for legibility.
              Assets.images.arabicText.image(
                fit: BoxFit.cover,
              ),
              Assets.images.arabicText.image(
                fit: BoxFit.fill,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIIcon(UIIconsToken.icons.dhikr, color: UIColorsToken.textYellow),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(
                      color: UIColorsToken.textYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
