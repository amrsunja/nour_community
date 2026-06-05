import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeolocatorTools {
  // In-memory cache to avoid hitting the GPS on every notification re-schedule.
  static Position? _cached;
  static DateTime? _cachedAt;
  static const _cacheTtl = Duration(hours: 6);

  static const _kLat = 'geo_last_lat';
  static const _kLng = 'geo_last_lng';
  static const _kManual = 'geo_is_manual';

  /// Returns a cached position if still fresh, otherwise re-resolves via GPS.
  /// Throws when services/permissions are unavailable — use only in
  /// foreground/interactive contexts.
  static Future<Position> currentOrCachedPosition() async {
    final now = DateTime.now();
    if (_cached != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cached!;
    }
    final pos = await determinePosition();
    _cached = pos;
    _cachedAt = now;
    await _persist(pos, manual: false);
    return pos;
  }

  /// Non-throwing resolver for background / notification-scheduling contexts.
  /// Never depends on a live GPS fix succeeding: tries the live/cached path,
  /// and on any failure (services off, permission denied, timeout) falls back
  /// to the last persisted coordinate. Returns `null` only when no fix has ever
  /// been obtained or set manually — callers should skip scheduling in that case.
  static Future<Position?> positionForScheduling() async {
    try {
      return await currentOrCachedPosition();
    } catch (_) {
      return _lastPersisted();
    }
  }

  /// Persist a user-chosen coordinate (e.g. from a city picker) as the fallback
  /// location. Lets prayer times / scheduling work without GPS at all.
  static Future<void> setManualCoordinates(double lat, double lng) async {
    final pos = _buildPosition(lat, lng);
    _cached = pos;
    _cachedAt = DateTime.now();
    await _persist(pos, manual: true);
  }

  static Future<bool> hasStoredLocation() async {
    final sp = await SharedPreferences.getInstance();
    return sp.containsKey(_kLat) && sp.containsKey(_kLng);
  }

  static Future<bool> isManualLocation() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kManual) ?? false;
  }

  static void invalidateCache() {
    _cached = null;
    _cachedAt = null;
  }

  // ---------------------------------------------------------------------------

  static Future<void> _persist(Position p, {required bool manual}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kLat, p.latitude);
    await sp.setDouble(_kLng, p.longitude);
    await sp.setBool(_kManual, manual);
  }

  static Future<Position?> _lastPersisted() async {
    final sp = await SharedPreferences.getInstance();
    final lat = sp.getDouble(_kLat);
    final lng = sp.getDouble(_kLng);
    if (lat == null || lng == null) return null;
    return _buildPosition(lat, lng);
  }

  static Position _buildPosition(double lat, double lng) => Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

  /// Determine the current position of the device.
  ///
  /// Foreground-only: when the system location service is off it deep-links the
  /// user to Location settings and re-checks; throws if still unavailable or if
  /// permission is denied.
  static Future<Position> determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      // System-level GPS toggle is off — independent of app permission.
      // Deep-link the user to settings, then re-check on return.
      await Geolocator.openLocationSettings();
      if (!await Geolocator.isLocationServiceEnabled()) {
        return Future.error('Location services are disabled.');
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium, // plenty for prayer times / Qibla
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
