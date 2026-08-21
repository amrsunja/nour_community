import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Hero glyph of the donation reward page: two overlapping gold coins with a
/// cream ring and a deep-green center (matches the mock). Painted — no asset —
/// so it scales crisply and inherits the reward glow. Swap the body for an
/// `Image.asset` if a brand illustration is provided later.
class RewardCoinsBadge extends StatelessWidget {
  const RewardCoinsBadge({super.key, this.size = 230});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: UIShadowToken.illustration,
      ),
      child: CustomPaint(painter: _CoinsPainter()),
    );
  }
}

class _CoinsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * 0.34;
    // Back coin (top-right), front coin (bottom-left) — like the mock.
    _coin(canvas, Offset(size.width * 0.60, size.height * 0.42), r, back: true);
    _coin(canvas, Offset(size.width * 0.42, size.height * 0.56), r, back: false);
  }

  void _coin(Canvas canvas, Offset c, double r, {required bool back}) {
    // Edge (thickness) — a slightly offset darker disc.
    final edge = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xffB8893A), Color(0xff7A5A22)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c.translate(r * 0.06, r * 0.08), r, edge);

    // Face — gold gradient with a highlight.
    final face = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.4, -0.5),
        radius: 1.1,
        colors: [Color(0xffF3D98B), Color(0xffD9AE52), Color(0xffA9792A)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, face);

    // Milled rim: short radial ticks.
    final tick = Paint()
      ..color = const Color(0xff8C6420).withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 72; i++) {
      final a = i / 72 * math.pi * 2;
      final p1 = c + Offset(math.cos(a), math.sin(a)) * (r * 0.97);
      final p2 = c + Offset(math.cos(a), math.sin(a)) * (r * 0.90);
      canvas.drawLine(p1, p2, tick);
    }

    // Cream ring.
    canvas.drawCircle(
      c,
      r * 0.72,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFBF3DF), Color(0xffE9DAB6)],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.72)),
    );
    // Thin gold separator.
    canvas.drawCircle(
      c,
      r * 0.50,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = const Color(0xffD1A64E),
    );
    // Green center.
    canvas.drawCircle(
      c,
      r * 0.47,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 1.0,
          colors: [Color(0xff3E5A3B), Color(0xff1E2E1D)],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.47)),
    );

    // Soft highlight sweep on the face.
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: back ? 0.20 : 0.28),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, gloss);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
