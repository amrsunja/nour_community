import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// A single segment of [UITabs]: a [value] paired with its display [label].
class UITabItem<T> {
  const UITabItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Generic segmented control used across the app (Source header, profile
/// Statistics, …). Segments share the width equally; the active one is filled
/// with a gold pill while the rest stay plain tappable labels.
///
/// ```dart
/// UITabs<SourceTab>(
///   selected: tab,
///   items: const [
///     UITabItem(value: SourceTab.quran, label: 'Quran'),
///     UITabItem(value: SourceTab.hadith, label: 'Hadith'),
///   ],
///   onChanged: (t) => ...,
/// )
/// ```
class UITabs<T> extends StatelessWidget {
  const UITabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.height = 38,
    this.spacing = 0,
    this.padding,
    this.trackColor,
    this.borderRadius = 6,
    this.activeGradient,
    this.activeTextColor,
    this.inactiveTextColor,
    this.textStyle,
  });

  /// The selectable segments, in display order.
  final List<UITabItem<T>> items;

  /// Currently selected value.
  final T selected;

  /// Emitted with the tapped segment's value.
  final ValueChanged<T> onChanged;

  /// Segment height.
  final double height;

  /// Gap between segments.
  final double spacing;

  /// Optional padding around the whole control (e.g. a visible track).
  final EdgeInsets? padding;

  /// Optional background color for the track (the area behind the segments).
  final Color? trackColor;

  /// Corner radius of both the track and the active pill.
  final double borderRadius;

  /// Active pill fill. Defaults to [UIColorsToken.bgPriYellow].
  final Gradient? activeGradient;

  /// Label color when active. Defaults to [UIColorsToken.black].
  final Color? activeTextColor;

  /// Label color when inactive. Defaults to [UIColorsToken.textParagraph].
  final Color? inactiveTextColor;

  /// Base label style. Defaults to `typo.inter.title`.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final baseStyle = textStyle ?? typo.inter.bodyMedium;

    Widget row = Row(
      spacing: 4,
      mainAxisAlignment: .center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0 && spacing > 0) SizedBox(width: spacing),
          Expanded(
            child: _Segment(
              label: items[i].label,
              active: items[i].value == selected,
              height: height,
              borderRadius: borderRadius,
              activeGradient: activeGradient ?? UIColorsToken.bgPriYellow,
              activeTextColor: activeTextColor ?? UIColorsToken.black,
              inactiveTextColor: inactiveTextColor ?? UIColorsToken.textParagraph,
              baseStyle: baseStyle,
              onTap: () => onChanged(items[i].value),
            ),
          ),
        ],
      ],
    );

    if (padding != null || trackColor != null) {
      row = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: row,
      );
    }

    return row;
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.height,
    required this.borderRadius,
    required this.activeGradient,
    required this.activeTextColor,
    required this.inactiveTextColor,
    required this.baseStyle,
    required this.onTap,
  });

  final String label;
  final bool active;
  final double height;
  final double borderRadius;
  final Gradient activeGradient;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final TextStyle baseStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active ? activeGradient : null,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle.copyWith(
            color: active ? activeTextColor : inactiveTextColor,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
