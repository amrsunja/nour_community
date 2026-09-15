import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Shared chrome for every modal bottom sheet: rounded top corners, the white
/// drag line, and the warm glow bleeding in from above the top edge.
///
/// Use [UIBottomSheet.show] instead of `showModalBottomSheet` — it keeps the
/// route transparent and wraps the content in [UIBottomSheetSurface] so the
/// chrome is identical everywhere.
abstract final class UIBottomSheet {
  /// Top corner radius of every sheet.
  static const double radius = 24;

  /// Diameter of the glow circle sitting above the sheet.
  static const double glowDiameter = 150;

  /// Portion of that circle that reaches inside the sheet (20%).
  static const double glowVisibleFraction = 0.1;

  /// Layer blur applied to the glow.
  static const double glowBlur = 90;

  /// #C59F54 at 30% opacity.
  static const Color glowColor = Color(0x4DC59F54);

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = false,
    bool showHandle = true,
    double borderRadius = radius,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      builder: (ctx) => UIBottomSheetSurface(
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        showHandle: showHandle,
        child: builder(ctx),
      ),
    );
  }
}

/// The visual shell of a bottom sheet. Exposed for sheets that are pushed by
/// something else than [UIBottomSheet.show].
class UIBottomSheetSurface extends StatelessWidget {
  const UIBottomSheetSurface({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = UIBottomSheet.radius,
    this.showHandle = true,
  });

  final Widget child;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? UIColorsToken.bgPrimary,
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -UIBottomSheet.glowDiameter *
                  (1 - UIBottomSheet.glowVisibleFraction),
              left: 0,
              right: 0,
              child: IgnorePointer(child: UIBottomSheetTopGlow()),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHandle) const UIBottomSheetHandle(),
                Flexible(child: child),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The blurred gold circle whose bottom 20% peeks into the sheet.
class UIBottomSheetTopGlow extends StatelessWidget {
  const UIBottomSheetTopGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: UIBottomSheet.glowBlur,
          sigmaY: UIBottomSheet.glowBlur,
          tileMode: TileMode.decal,
        ),
        child: Container(
          width: UIBottomSheet.glowDiameter,
          height: UIBottomSheet.glowDiameter,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: UIBottomSheet.glowColor,
          ),
        ),
      ),
    );
  }
}

/// The white drag line at the top of every sheet.
class UIBottomSheetHandle extends StatelessWidget {
  const UIBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 72,
        height: 5,
        decoration: BoxDecoration(
          color: UIColorsToken.white,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
