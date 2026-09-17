import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Read-only grid of preset amounts — the selectable twin of the admin
/// `AdminAmountsEditor` tiles (same 56px tile, 14px radius, currency symbol in
/// yellow), but the value can only be picked, never edited.
///
/// ```dart
/// UIAmountSelector(
///   amounts: settings.suggestedAmounts,
///   selected: amount.round(),
///   onSelected: (v) => amount = v.toDouble(),
/// )
/// ```
///
/// [selected] is `null` when the user typed a custom amount elsewhere, so no
/// tile is highlighted. Pass [selectedValues] instead for a multi-select grid
/// (e.g. an admin picking which amounts donors will see) — [onSelected] then
/// fires with the tapped amount and the caller toggles it. Pass [otherLabel]
/// to append a full-width "Other amount" tile after the grid.
class UIAmountSelector extends StatelessWidget {
  const UIAmountSelector({
    super.key,
    required this.amounts,
    this.selected,
    this.selectedValues,
    required this.onSelected,
    this.currencySymbol = '€',
    this.columns = 2,
    this.gap = 12,
    this.tileHeight = 56,
    this.enabled = true,
    this.otherLabel,
    this.otherSelected = false,
    this.onOtherTap,
    this.bgColor = const Color(0xff171717)
  });

  final List<int> amounts;

  /// Highlighted amount, or `null` when none of the presets is active.
  /// Ignored when [selectedValues] is set.
  final int? selected;

  /// Multi-select mode: every amount in this set is highlighted.
  final Set<int>? selectedValues;
  final ValueChanged<int> onSelected;
  final String currencySymbol;
  final int columns;
  final double gap;
  final double tileHeight;

  /// `false` renders the grid as a non-tappable preview.
  final bool enabled;

  /// Optional trailing full-width tile (e.g. "Other amount").
  final String? otherLabel;
  final bool otherSelected;
  final VoidCallback? onOtherTap;
  final Color bgColor;


  @override
  Widget build(BuildContext context) {
    if (amounts.isEmpty && otherLabel == null) return const SizedBox.shrink();
    final cols = columns < 1 ? 1 : columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (amounts.isNotEmpty)
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final a in amounts)
                    SizedBox(
                      width: tileWidth,
                      child: _AmountTile(
                        label: '$a',
                        currencySymbol: currencySymbol,
                        selected: selectedValues?.contains(a) ?? (selected == a),
                        height: tileHeight,
                        onTap: enabled ? () => onSelected(a) : null,
                        bgColor: bgColor,
                      ),
                    ),
                ],
              ),
            if (otherLabel != null) ...[
              if (amounts.isNotEmpty) SizedBox(height: gap),
              _AmountTile(
                label: otherLabel!,
                selected: otherSelected,
                height: tileHeight,
                center: true,
                onTap: enabled ? onOtherTap : null,
                bgColor: bgColor,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.selected,
    required this.height,
    this.currencySymbol,
    this.center = false,
    this.onTap,
    required this.bgColor
  });

  final String label;
  final bool selected;
  final double height;
  final String? currencySymbol;
  final bool center;
  final VoidCallback? onTap;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final fg = selected ? UIColorsToken.textYellow : UIColorsToken.white;

    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: height,
        padding: EdgeInsets.symmetric(horizontal: center ? 12 : 14),
        alignment: center ? Alignment.center : null,
        decoration: BoxDecoration(
          color: selected ? UIColorsToken.yellow.withValues(alpha: .12) : bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? UIColorsToken.yellow.withValues(alpha: .85) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: center
            ? Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typo.inter.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w600),
              )
            : Row(
                children: [
                  if (currencySymbol != null) ...[
                    Text(
                      currencySymbol!,
                      style: theme.typo.inter.body.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typo.inter.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
