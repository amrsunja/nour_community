import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIGradientRaysPainter extends CustomPainter {
  UIGradientRaysPainter({
    required this.gradientHeightFactor,
    required this.rayCount,
    required this.rayOpacity,
    required this.centerRayWidth,
    required this.edgeRayWidth,
  });

  final double gradientHeightFactor;
  final int rayCount;
  final double rayOpacity;
  final double centerRayWidth;
  final double edgeRayWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final gradientHeight = size.height * gradientHeightFactor;
    final gradientRect = Rect.fromLTWH(0, 0, size.width, gradientHeight);

    // 1. Green-to-black vertical gradient at the top.
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xff404F3B),
          Color(0xff000000),
        ],
        stops: [0.0, 1.0],
      ).createShader(gradientRect);
    canvas.drawRect(gradientRect, bgPaint);

    // 2. Sun-like rays — converging point is BELOW the gradient,
    //    rays fan upward and outward, brighter near the origin (bottom)
    //    and fading as they reach the top edge.
    final origin = Offset(size.width / 2, gradientHeight + size.width * 0.04);
    final rayLength = gradientHeight * 1.4;
    const spread = math.pi * 0.6;
    // Pointing upward → centered around -π/2.
    final startAngle = -math.pi / 2 - spread / 2;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, gradientHeight));

    for (var i = 0; i < rayCount; i++) {
      final t = rayCount == 1 ? 0.5 : i / (rayCount - 1);
      final angle = startAngle + spread * t;
      final end = Offset(
        origin.dx + math.cos(angle) * rayLength,
        origin.dy + math.sin(angle) * rayLength,
      );

      // 1.0 at the middle index, 0.0 at the edges.
      final centeredness = 1 - (2 * t - 1).abs();
      final strokeWidth =
          edgeRayWidth + (centerRayWidth - edgeRayWidth) * centeredness;

      final shaderRect = Rect.fromPoints(origin, end).inflate(1);
      final rayPaint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..shader = LinearGradient(
          // Bright end sits at the origin (bottom), fades toward `end` (top).
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            UIColorsToken.white.withValues(alpha: rayOpacity),
            UIColorsToken.white.withValues(alpha: 0),
          ],
        ).createShader(shaderRect);

      canvas.drawLine(origin, end, rayPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant UIGradientRaysPainter oldDelegate) {
    return oldDelegate.gradientHeightFactor != gradientHeightFactor ||
        oldDelegate.rayCount != rayCount ||
        oldDelegate.rayOpacity != rayOpacity ||
        oldDelegate.centerRayWidth != centerRayWidth ||
        oldDelegate.edgeRayWidth != edgeRayWidth;
  }
}
