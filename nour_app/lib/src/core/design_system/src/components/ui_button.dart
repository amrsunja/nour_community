import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';

/// Horizontal placement of the icon relative to the label (LTR: left vs right).
enum UIButtonIconAxis {
  leading,
  trailing,
}

enum _UIButtonVariant {
  primary,
  secondary,
  textual,
}

/// Design-system button: hug width by default; use [fullWidth] for full cross-axis width.
class UIButton extends StatelessWidget {
  const UIButton._({
    super.key,
    required this.variant,
    this.label,
    this.assetIcon,
    this.onTap,
    this.isSmall = false,
    this.fullWidth = false,
    this.isBusy = false,
    this.iconAxis,
    this.contentColor,
  });

  factory UIButton.primary({
    Key? key,
    String? label,
    String? assetIcon,
    bool isSmall = false,
    bool fullWidth = false,
    bool isBusy = false,
    UIButtonIconAxis? iconAxis,
    VoidCallback? onTap,
  }) {
    return UIButton._(
      key: key,
      variant: _UIButtonVariant.primary,
      label: label,
      assetIcon: assetIcon,
      onTap: onTap,
      isSmall: isSmall,
      fullWidth: fullWidth,
      isBusy: isBusy,
      iconAxis: iconAxis,
    );
  }

  factory UIButton.secondary({
    Key? key,
    String? label,
    String? assetIcon,
    bool isSmall = false,
    bool fullWidth = false,
    bool isBusy = false,
    UIButtonIconAxis? iconAxis,
    VoidCallback? onTap,
  }) {
    return UIButton._(
      key: key,
      variant: _UIButtonVariant.secondary,
      label: label,
      assetIcon: assetIcon,
      onTap: onTap,
      isSmall: isSmall,
      fullWidth: fullWidth,
      isBusy: isBusy,
      iconAxis: iconAxis,
    );
  }

  factory UIButton.textual({
    Key? key,
    String? label,
    String? assetIcon,
    bool isSmall = false,
    bool fullWidth = false,
    bool isBusy = false,
    UIButtonIconAxis? iconAxis,
    Color? contentColor,
    VoidCallback? onTap,
  }) {
    return UIButton._(
      key: key,
      variant: _UIButtonVariant.textual,
      label: label,
      assetIcon: assetIcon,
      onTap: onTap,
      isSmall: isSmall,
      fullWidth: fullWidth,
      isBusy: isBusy,
      iconAxis: iconAxis,
      contentColor: contentColor,
    );
  }

  final _UIButtonVariant variant;
  final String? label;
  final String? assetIcon;
  final bool isSmall;
  final bool fullWidth;

  /// When `true`, swaps the icon+label row for a centered
  /// `CircularProgressIndicator` and absorbs taps. Useful for async actions
  /// (e.g. sign in) that should give immediate feedback without a layout
  /// jump — padding/decoration stay the same so the button keeps its size.
  final bool isBusy;

  /// Defaults: large → icon after text; small → icon before text.
  final UIButtonIconAxis? iconAxis;

  final Color? contentColor;
  final VoidCallback? onTap;

  EdgeInsets? get _padding => variant == _UIButtonVariant.textual ? null : isSmall
      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
      : EdgeInsets.symmetric(horizontal: label == null ? 20 : 16, vertical: label == null ? 16 : 12);

  double get _radius => isSmall ? 6 : 12;

  double get _gap => isSmall ? 4 : 8;

  UIButtonIconAxis get _resolvedIconAxis =>
      iconAxis ?? (isSmall ? UIButtonIconAxis.leading : UIButtonIconAxis.trailing);

  LinearGradient? get _backgroundColor {
    switch (variant) {
      case _UIButtonVariant.primary:
        return UIColorsToken.bgPriYellow;
      case _UIButtonVariant.secondary:
        return null;
      case _UIButtonVariant.textual:
        return null;
    }
  }

  Color get _foregroundColor {
    if (contentColor != null) return contentColor!;

    switch (variant) {
      case _UIButtonVariant.primary:
        return UIColorsToken.black;
      case _UIButtonVariant.secondary:
        return UIColorsToken.white;
      case _UIButtonVariant.textual:
        return UIColorsToken.textYellow;
    }
  }

  BoxDecoration get _decoration {
    return BoxDecoration(
      gradient: _backgroundColor,
      borderRadius: BorderRadius.circular(_radius),
      border: variant == _UIButtonVariant.secondary && label == null && assetIcon != null
          ? Border.all(color: UIColorsToken.white, width: 1)
          : null,
    );
  }

  double get _iconSize => isSmall ? 12 : 14;

  double get _spinnerSize => isSmall ? 14 : 20;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final baseLabelStyle = isSmall ? typo.inter.bodySmall : typo.inter.buttonLabel;
    final fg = _foregroundColor;
    final textStyle = baseLabelStyle.copyWith(color: fg);
    final iconWidget = assetIcon == null ? null : UIIconsToken.toIcon(
      assetIcon!,
      color: fg,
      size: _iconSize,
    );

    Widget? labelWidget() {
      if (label == null) return null;

      return Text(
        label!,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }

    final leading = _resolvedIconAxis == UIButtonIconAxis.leading;

    Widget rowChild(BoxConstraints constraints) {
      final bounded = fullWidth || (constraints.hasBoundedWidth && constraints.maxWidth.isFinite);

      Widget? textCell() {
        final text = labelWidget();

        if (text == null) return null;

        if (!bounded) return text;
        return Flexible(child: text);
      }

      final text = textCell();

      if (leading) {
        return Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: text == null ? 0 : _gap,
          children: [
            ?iconWidget,
            ?text,
          ],
        );
      }

      return Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
          spacing: text == null ? 0 : _gap,
        children: [
          ?text,
          ?iconWidget,
        ],
      );
    }

    Widget busyChild() {
      // Force the busy state to occupy at least the same height as the
      // icon-row variant so the button doesn't visibly jump when toggled.
      return Center(
        child: UICircularProgressBar(
          color: UIColorsToken.black,
          size: _spinnerSize + 3,
        ),
      );
    }

    return UITap(
      onTap: isBusy
          ? null
          : () {
              AppVibrations.buttonClick();
              onTap?.call();
            },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: fullWidth ? double.infinity : null,
            padding: _padding,
            decoration: _decoration,
            child: isBusy ? busyChild() : rowChild(constraints),
          );
        },
      ),
    );
  }
}
