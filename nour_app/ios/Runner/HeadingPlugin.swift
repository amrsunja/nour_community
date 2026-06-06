import CoreLocation
import Flutter

/// Streams a tilt-compensated, hard-iron-calibrated compass heading to Flutter.
///
/// Why this exists: the Dart `CompassHeading` fuses the raw accelerometer +
/// magnetometer from `sensors_plus`. On Android the OS delivers a *calibrated*
/// magnetic field, so the fusion is correct. On iOS `sensors_plus` exposes the
/// *uncalibrated* `CMMagnetometerData.magneticField` (raw, with the device's
/// hard-iron bias baked in), so the fused heading barely rotates (~10–30°) and
/// points the wrong way.
///
/// CoreLocation already solves this: `CLHeading` is calibrated, tilt-compensated
/// and (with location authorized) corrected to TRUE north. We surface it on the
/// `nour/heading` EventChannel as degrees clockwise from north, where `0` means
/// the top edge of the device points north — the same convention the widget and
/// the Android path use.
public class HeadingPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
  CLLocationManagerDelegate
{
  private let locationManager = CLLocationManager()
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = HeadingPlugin()
    let channel = FlutterEventChannel(
      name: "nour/heading",
      binaryMessenger: registrar.messenger()
    )
    channel.setStreamHandler(instance)
  }

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.headingFilter = 1  // emit on ~1° change
    locationManager.headingOrientation = .portrait  // 0 == top edge to north
  }

  // MARK: FlutterStreamHandler

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    guard CLLocationManager.headingAvailable() else {
      // No magnetometer -> Dart receives null -> widget shows the "no sensor" UI.
      events(nil)
      return nil
    }
    eventSink = events
    locationManager.startUpdatingHeading()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager.stopUpdatingHeading()
    eventSink = nil
    return nil
  }

  // MARK: CLLocationManagerDelegate

  public func locationManager(
    _ manager: CLLocationManager,
    didUpdateHeading newHeading: CLHeading
  ) {
    guard let sink = eventSink else { return }

    // Negative accuracy == reading is invalid / needs calibration.
    if newHeading.headingAccuracy < 0 {
      sink(nil)
      return
    }

    // Prefer TRUE north (matches the Qibla bearing's reference frame). When
    // location is not authorized, trueHeading is -1; fall back to magnetic.
    let heading =
      newHeading.trueHeading >= 0
      ? newHeading.trueHeading
      : newHeading.magneticHeading
    sink(heading)
  }

  public func locationManagerShouldDisplayHeadingCalibration(
    _ manager: CLLocationManager
  ) -> Bool {
    // Let iOS show the figure-8 calibration overlay when the field is unreliable.
    return true
  }
}
