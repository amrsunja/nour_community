import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart' show EventChannel;
import 'package:sensors_plus/sensors_plus.dart';

/// Compass heading in degrees, clockwise from north, where `0` means the
/// **top edge of the device** is pointing north — the convention the
/// [QiblaCompassWidget] math depends on (unchanged across this refactor).
///
/// Emits `null` when a reliable heading cannot be computed (no magnetometer, or
/// a momentary magnetic anomaly / calibration drop).
///
/// ## Why the source is platform-conditional
///
/// The heading is derived from the device magnetometer. The catch is that the
/// *calibration* of that magnetometer differs by OS:
///
///   • **Android** delivers an already hard/soft-iron *calibrated* field
///     (`Sensor.TYPE_MAGNETIC_FIELD`). We can fuse it with the accelerometer in
///     Dart and get a correct heading — see [_sensorFusionEvents].
///
///   • **iOS** only exposes the *raw, uncalibrated* magnetometer through
///     `sensors_plus` (`CMMagnetometerData.magneticField`). It carries the
///     device's hard-iron bias, so the same Dart fusion barely rotates
///     (~10–30°) and points the wrong way. iOS's calibrated, tilt-compensated,
///     true-north heading lives in `CLHeading`, which we surface natively over
///     the `nour/heading` [EventChannel] — see [_nativeHeadingEvents].
///
/// On iOS the value is referenced to **true north** (matching the Qibla
/// bearing). On Android it remains *magnetic* north, i.e. a residual
/// declination error of a few degrees, exactly as before this change.
class CompassHeading {
  CompassHeading._();

  /// Native iOS heading stream (degrees, true north, 0 = top edge to north).
  static const EventChannel _iosHeadingChannel = EventChannel('nour/heading');

  /// Low-pass smoothing factor for the raw sensor vectors (0..1).
  /// Lower = smoother but laggier. 0.2 is a good phone-compass default.
  static const double _alpha = 0.2;

  /// Minimum cross-product norm below which the heading is considered
  /// unreliable (sensors nearly parallel → no horizontal reference).
  static const double _minNorm = 1e-6;

  /// A stream of headings (degrees, clockwise from north).
  ///
  /// Routes to the native CoreLocation heading on iOS and to the
  /// accelerometer+magnetometer fusion everywhere else.
  static Stream<double?> events({
    Duration samplingPeriod = SensorInterval.uiInterval,
  }) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _nativeHeadingEvents();
    }
    return _sensorFusionEvents(samplingPeriod: samplingPeriod);
  }

  /// iOS: calibrated true-north heading from `CLHeading` via the platform
  /// channel. A native `null` (no compass / invalid reading) is forwarded as a
  /// Dart `null`; a channel error degrades to `null` rather than crashing the
  /// widget.
  static Stream<double?> _nativeHeadingEvents() {
    return _iosHeadingChannel
        .receiveBroadcastStream()
        .map<double?>((e) => e == null ? null : (e as num).toDouble())
        .handleError((_) => null);
  }

  /// Android / others: tilt-compensated magnetic heading built from the raw
  /// accelerometer + magnetometer (unchanged from the original implementation).
  static Stream<double?> _sensorFusionEvents({
    required Duration samplingPeriod,
  }) {
    final controller = StreamController<double?>.broadcast();

    // Latest smoothed sensor vectors.
    List<double>? accel; // [x, y, z]
    List<double>? mag;

    StreamSubscription<AccelerometerEvent>? accelSub;
    StreamSubscription<MagnetometerEvent>? magSub;

    List<double> lowPass(List<double>? prev, double x, double y, double z) {
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
        accel = lowPass(accel, e.x, e.y, e.z);
        emit();
      }, onError: (_) {
        if (!controller.isClosed) controller.add(null);
      });

      magSub = magnetometerEventStream(samplingPeriod: samplingPeriod)
          .listen((e) {
        mag = lowPass(mag, e.x, e.y, e.z);
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
