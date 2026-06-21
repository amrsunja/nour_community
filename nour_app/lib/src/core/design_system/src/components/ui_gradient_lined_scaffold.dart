import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Scaffold with a dark surface, a top green gradient, and subtle
/// sun-ray lines fanning out from an origin above the screen.
///
/// Use it as a drop-in replacement for [Scaffold] on screens that need
/// the branded "sunrise" backdrop (onboarding, splash, intro pages).
class UIGradientLinedScaffold extends StatelessWidget {
  const UIGradientLinedScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.safeArea = true,
    this.gradientHeightFactor = 0.55,
    this.rayCount = 9,
    this.rayOpacity = 0.07,
    this.centerRayWidth = 64,
    this.edgeRayWidth = 34,
    this.bgArabicText,
  });

  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;

  /// Wraps [body] in a [SafeArea] when true.
  final bool safeArea;

  /// Portion of the screen height the green gradient covers (0..1).
  final double gradientHeightFactor;

  /// Number of sun rays painted.
  final int rayCount;

  /// Peak opacity at the origin of each ray (fades to 0).
  final double rayOpacity;

  /// Stroke width of the centermost ray.
  final double centerRayWidth;

  /// Stroke width of the outermost rays. Widths interpolate linearly
  /// from edge → center across [rayCount].
  final double edgeRayWidth;

  final String? bgArabicText;

  @override
  Widget build(BuildContext context) {
    Widget? content = body;
    if (safeArea && content != null) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Builder(
                  builder: (context) {
                    if (bgArabicText != null) {
                      return Column(
                        children: [
                          UICard(
                            width: .infinity,
                            height: 250,
                            disableBorder: true,
                            colors: [
                              Color(0xff45513F),
                              Color(0xff2B3326),
                              Colors.transparent
                            ],
                            child: FittedBox(
                              fit: .fitWidth,
                              alignment: .topCenter,
                              child: bgArabicText == null ? null : Text(
                                bgArabicText!,
                                style: TextStyle(
                                  color: UIColorsToken.yellow.withValues(alpha: 0.07)
                                ),
                              ),
                            )
                          ),
                        ],
                      );
                    }

                    return CustomPaint(
                      painter: UIGradientRaysPainter(
                        gradientHeightFactor: gradientHeightFactor,
                        rayCount: rayCount,
                        rayOpacity: rayOpacity,
                        centerRayWidth: centerRayWidth,
                        edgeRayWidth: edgeRayWidth,
                      ),
                    );
                  }
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topLeft,
                  end: .bottomCenter,
                  colors: [
                    UIColorsToken.black.withValues(alpha: 0.15),
                    UIColorsToken.black,
                    UIColorsToken.black,
                    UIColorsToken.black,
                  ]
                )
              ),
              child: content
            )
          ),
        ],
      ),
    );
  }
}
