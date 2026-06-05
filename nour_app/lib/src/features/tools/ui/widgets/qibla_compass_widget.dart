import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/features/tools/ui/widgets/compass_heading.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Live Qibla compass.
///
/// Two independently-rotating layers, both driven by the device magnetometer
/// heading (clockwise from true north):
///   • the dial (green disc, glow, dotted ring, N/E/S/W) rotates by `-heading`
///     so North always points at true north;
///   • the needle + Kaaba pointer rotates by `(qiblaBearing - heading)` so it
///     always points to Makkah relative to the device's top edge.
///
/// When the user faces the Qibla, the needle snaps to the top, the Kaaba sits
/// over the North marker, and a light haptic confirms alignment.
class QiblaCompassWidget extends StatelessWidget {
  const QiblaCompassWidget({
    super.key,
    required this.qiblaBearing,
    this.size = 300,
  });

  /// Qibla bearing from the current location, clockwise from true north.
  final double qiblaBearing;

  /// Diameter of the dial in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double?>(
      stream: CompassHeading.events(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: size,
            child: const Center(child: UICircularProgressBar()),
          );
        }

        final heading = snapshot.data;
        // No magnetometer, or a momentarily-unreliable reading.
        if (heading == null) return _NoSensor(size: size);

        return _CompassView(
          size: size,
          heading: heading,
          qiblaBearing: qiblaBearing,
        );
      },
    );
  }
}

/// Holds the smoothed, wrap-around-safe rotation of both layers.
class _CompassView extends StatefulWidget {
  const _CompassView({
    required this.size,
    required this.heading,
    required this.qiblaBearing,
  });

  final double size;
  final double heading;
  final double qiblaBearing;

  @override
  State<_CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<_CompassView> {
  /// Accumulated turns (continuous, never wraps) so [AnimatedRotation] always
  /// takes the short way around the 359°→0° seam.
  late double _dialTurns;
  late double _pointerTurns;
  bool _wasAligned = false;

  /// Tolerance (degrees) for the "facing the Qibla" haptic + glow.
  static const double _alignTolerance = 5;

  @override
  void initState() {
    super.initState();
    _dialTurns = _shortestTurns(0, -widget.heading);
    _pointerTurns =
        _shortestTurns(0, widget.qiblaBearing - widget.heading);
  }

  @override
  void didUpdateWidget(covariant _CompassView old) {
    super.didUpdateWidget(old);
    _dialTurns = _shortestTurns(_dialTurns, -widget.heading);
    _pointerTurns = _shortestTurns(
      _pointerTurns,
      widget.qiblaBearing - widget.heading,
    );
    _maybeHaptic();
  }

  /// Signed angular gap to the Qibla (-180..180].
  double get _offset {
    var diff = (widget.qiblaBearing - widget.heading) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }

  bool get _aligned => _offset.abs() <= _alignTolerance;

  void _maybeHaptic() {
    final aligned = _aligned;
    if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
    _wasAligned = aligned;
  }

  /// Returns a new continuous turn value near [current] that represents
  /// [targetDeg], stepping by the shortest signed fraction of a turn.
  static double _shortestTurns(double current, double targetDeg) {
    final targetTurns = targetDeg / 360.0;
    var diff = targetTurns - current;
    diff -= diff.roundToDouble();
    return current + diff;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    const duration = Duration(milliseconds: 220);
    const curve = Curves.easeOut;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Dial ──────────────────────────────────────────────────────
          AnimatedRotation(
            turns: _dialTurns,
            duration: duration,
            curve: curve,
            child: CustomPaint(
              size: Size.square(size),
              painter: _DialPainter(aligned: _aligned),
            ),
          ),

          // ── Qibla pointer (needle + Kaaba) ────────────────────────────
          AnimatedRotation(
            turns: _pointerTurns,
            duration: duration,
            curve: curve,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Assets.images.compassLines.image(
                      height: size * 0.96,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: -14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Assets.images.kaaba.image(
                        width: 54,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the static dial face (rotated by the parent): outer gold glow,
/// dark-green disc, dotted ring and the N/E/S/W cardinal markers.
class _DialPainter extends CustomPainter {
  _DialPainter({required this.aligned});

  final bool aligned;

  static const _gold = UIColorsToken.textYellow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final discRadius = radius - 14;

    // 1. Outer glow — wide soft halo + a tighter brighter rim.
    canvas.drawCircle(
      center,
      discRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..color = _gold.withValues(alpha: aligned ? 0.55 : 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );
    canvas.drawCircle(
      center,
      discRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = _gold.withValues(alpha: aligned ? 0.9 : 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 2. Dark-green disc.
    final discRect = Rect.fromCircle(center: center, radius: discRadius);
    canvas.drawCircle(
      center,
      discRadius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xff3B4737), Color(0xff20271D)],
          stops: [0.0, 1.0],
        ).createShader(discRect),
    );

    // 3. Thin gold edge.
    canvas.drawCircle(
      center,
      discRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _gold.withValues(alpha: 0.30),
    );

    // 4. Dotted ring (72 ticks, every 9th — the cardinals — is a dash).
    final dotOrbit = discRadius - 18;
    for (var i = 0; i < 72; i++) {
      final angle = (i * 5) * math.pi / 180 - math.pi / 2;
      final isCardinal = i % 18 == 0; // 0,18,36,54 → N,E,S,W
      final p = center +
          Offset(math.cos(angle), math.sin(angle)) * dotOrbit;
      if (isCardinal) {
        // short radial dash
        final inner = center +
            Offset(math.cos(angle), math.sin(angle)) * (dotOrbit - 6);
        final outer = center +
            Offset(math.cos(angle), math.sin(angle)) * (dotOrbit + 6);
        canvas.drawLine(
          inner,
          outer,
          Paint()
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..color = _gold.withValues(alpha: 0.85),
        );
      } else {
        canvas.drawCircle(
          p,
          i % 3 == 0 ? 1.8 : 1.2,
          Paint()..color = _gold.withValues(alpha: 0.55),
        );
      }
    }

    // 5. Cardinal letters.
    final letterOrbit = discRadius - 44;
    const labels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    labels.forEach((deg, label) {
      final angle = deg * math.pi / 180 - math.pi / 2;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * letterOrbit;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: _gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.aligned != aligned;
}

/// Shown when the device has no usable compass sensor.
class _NoSensor extends StatelessWidget {
  const _NoSensor({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = AppLocale.of(context);
    return SizedBox(
      height: size,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore_off_outlined,
                color: UIColorsToken.textYellow,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.qibla_sensor_error,
                textAlign: TextAlign.center,
                style: theme.typo.inter.title.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
