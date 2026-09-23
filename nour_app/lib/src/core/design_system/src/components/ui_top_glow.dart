import 'dart:ui';

import 'package:flutter/material.dart';

/// A blurred gold circle that sits above the top edge of its parent so only a
/// sliver of it bleeds in — the warm halo used at the top of bottom sheets and
/// at the top of the mosque header.
///
/// Drop it in a [Stack] as the first child and let the stack clip it:
///
/// ```dart
/// Stack(
///   children: [
///     const Positioned(top: UITopGlow.offset, left: 0, right: 0, child: UITopGlow()),
///     content,
///   ],
/// )
/// ```
class UITopGlow extends StatelessWidget {
  const UITopGlow({
    super.key,
    this.diameter = defaultDiameter,
    this.blur = defaultBlur,
    this.color = defaultColor,
  });

  /// Diameter of the glow circle.
  static const double defaultDiameter = 150;

  /// Portion of that circle that reaches inside the parent (10%).
  static const double defaultVisibleFraction = 0.1;

  /// Layer blur applied to the glow.
  static const double defaultBlur = 90;

  /// #C59F54 at 30% opacity.
  static const Color defaultColor = Color(0x4DC59F54);

  /// `top:` to use in the enclosing [Stack] so [defaultVisibleFraction] of the
  /// circle sits inside it.
  static const double offset = -defaultDiameter * (1 - defaultVisibleFraction);

  /// `top:` for a custom [diameter] / visible fraction.
  static double offsetFor(double diameter, {double visibleFraction = defaultVisibleFraction}) =>
      -diameter * (1 - visibleFraction);

  final double diameter;
  final double blur;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

/// The same blurred circle as [UITopGlow], pinned to a corner of its parent so
/// only a quarter of it bleeds in — the halo on the mosque post cards.
///
/// Drop it in a [Stack] that clips (e.g. inside a `ClipRRect`):
///
/// ```dart
/// Stack(
///   children: [
///     Positioned(top: UICornerGlow.offset, right: UICornerGlow.offset, child: UICornerGlow(color: accent)),
///     content,
///   ],
/// )
/// ```
class UICornerGlow extends StatelessWidget {
  const UICornerGlow({
    super.key,
    this.diameter = defaultDiameter,
    this.blur = defaultBlur,
    this.color = UITopGlow.defaultColor,
  });

  /// Diameter of the glow circle.
  static const double defaultDiameter = 120;

  /// Layer blur applied to the glow.
  static const double defaultBlur = 60;

  /// Portion of the circle that reaches inside the parent (35%).
  static const double defaultVisibleFraction = 0.35;

  /// `top:` / `right:` to use in the enclosing [Stack].
  static const double offset = -defaultDiameter * (1 - defaultVisibleFraction);

  /// Offset for a custom [diameter] / visible fraction.
  static double offsetFor(double diameter, {double visibleFraction = defaultVisibleFraction}) =>
      -diameter * (1 - visibleFraction);

  final double diameter;
  final double blur;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
