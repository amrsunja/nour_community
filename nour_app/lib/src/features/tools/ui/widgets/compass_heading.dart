import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// Tilt-compensated magnetic compass heading, built from the raw accelerometer
/// + magnetometer instead of the (unmaintained, frequently-stale) flutter_compass
/// plugin.
///
/// Emits the heading in degrees, clockwise from magnetic north, where `0` means
/// the **top edge of the device** is pointing north — the same convention
/// `flutter_compass` used, so the widget math is unchanged.
///
/// Emits `null` when a reliable heading cannot be computed (no magnetometer, or
/// the device is momentarily in a magnetic anomaly / free-fall).
///
/// NOTE: this is *magnetic* north. Qibla bearing is computed from *true* north,
/// so there is a residual declination error (a few degrees in most regions).
/// flutter_compass had the same limitation on Android. If you need true north,
/// offset the heading by the magnetic declination for the user's lat/lng.
class CompassHeading {
  CompassHeading._();

  /// Low-pass smoothing factor for the raw sensor vectors (0..1).
  /// Lower = smoother but laggier. 0.2 is a good phone-compass default.
  static const double _alpha = 0.2;

  /// Minimum cross-product norm below which the heading is considered
  /// unreliable (sensors nearly parallel → no horizontal reference).
  static const double _minNorm = 1e-6;

  /// A shared broadcast stream of headings (degrees, magnetic north).
  static Stream<double?> events({
    Duration samplingPeriod = SensorInterval.uiInterval,
  }) {
    final controller = StreamController<double?>.broadcast();

    // Latest smoothed sensor vectors.
    List<double>? accel; // [x, y, z]
    List<double>? mag;

    StreamSubscription<AccelerometerEvent>? accelSub;
    StreamSubscription<MagnetometerEvent>? magSub;

    List<double> _lowPass(List<double>? prev, double x, double y, double z) {
      if (prev == null) return [x, y, z];
      return [
        prev[0] + _alpha * (x - prev[0]),
        prev[1] + _alpha * (y - prev[1]),
        prev[2] + _alpha * (z - prev[2]),
      ];
    }

    void emit() {
      if (accel == null || mag == null) return;
      final h = _heading(accel!, mag!);
      if (!controller.isClosed) controller.add(h);
    }

    controller.onListen = () {
      accelSub = accelerometerEventStream(samplingPeriod: samplingPeriod)
          .listen((e) {
        accel = _lowPass(accel, e.x, e.y, e.z);
        emit();
      }, onError: (_) {
        if (!controller.isClosed) controller.add(null);
      });

      magSub = magnetometerEventStream(samplingPeriod: samplingPeriod)
          .listen((e) {
        mag = _lowPass(mag, e.x, e.y, e.z);
        emit();
      }, onError: (_) {
        if (!controller.isClosed) controller.add(null);
      });
    };

    controller.onCancel = () async {
      await accelSub?.cancel();
      await magSub?.cancel();
      accel = null;
      mag = null;
    };

    return controller.stream;
  }

  /// Android `getRotationMatrix` + `getOrientation` azimuth, distilled to the
  /// single value we need. Returns degrees [0, 360) or null if unreliable.
  static double? _heading(List<double> a, List<double> m) {
    final ax = a[0], ay = a[1], az = a[2];
    final ex = m[0], ey = m[1], ez = m[2];

    // H = E x A  (points east)
    var hx = ey * az - ez * ay;
    var hy = ez * ax - ex * az;
    var hz = ex * ay - ey * ax;
    final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (normH < _minNorm) return null;
    final invH = 1.0 / normH;
    hx *= invH;
    hy *= invH;
    hz *= invH;

    // Normalize A.
    final normA = math.sqrt(ax * ax + ay * ay + az * az);
    if (normA < _minNorm) return null;
    final nax = ax / normA, naz = az / normA;

    // M = A x H  (points north, tilt-compensated). Only the y-component is
    // needed for the azimuth: azimuth = atan2(H.y, M.y).
    final my = naz * hx - nax * hz;

    final azimuthRad = math.atan2(hy, my);
    final deg = azimuthRad * 180.0 / math.pi;
    return (deg + 360.0) % 360.0;
  }
}
