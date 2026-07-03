import 'dart:async';

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
  ///
  /// Pass [openSettingsIfBlocked] `true` only from an explicit user action
  /// (e.g. a "Enable location" retry button) to deep-link into settings when
  /// the permission is permanently denied or the GPS service is off.
  static Future<Position> currentOrCachedPosition({
    bool openSettingsIfBlocked = false,
  }) async {
    final now = DateTime.now();
    if (_cached != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cached!;
    }
    try {
      final pos = await determinePosition(
        openSettingsIfBlocked: openSettingsIfBlocked,
      );
      _cached = pos;
      _cachedAt = now;
      await _persist(pos, manual: false);
      return pos;
    } on TimeoutException {
      // GPS couldn't produce a fix in time (indoors, simulator, weak signal).
      // Degrade gracefully: OS last-known fix → last persisted coordinate.
      // For prayer times / Qibla a stale coordinate is perfectly adequate.
      final fallback =
          await Geolocator.getLastKnownPosition() ?? await _lastPersisted();
      if (fallback == null) rethrow;
      _cached = fallback;
      // Short TTL so we retry a real fix soon instead of pinning stale data
      // for the full cache window.
      _cachedAt = now.subtract(_cacheTtl - const Duration(minutes: 10));
      return fallback;
    }
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

  /// Whether the app currently holds a usable location permission
  /// (`whileInUse` or `always`). Cheap check — does not touch the GPS.
  static Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Permission gate for enabling location-dependent features (prayer / adhkar
  /// notifications). Returns `true` when permission is granted. When it isn't,
  /// it prompts once if still requestable, otherwise deep-links the user to the
  /// app settings so they can grant it manually — then returns `false` so the
  /// caller can keep the feature (and its switch) off.
  static Future<bool> ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    // Denied / permanently denied: OS won't re-prompt → send them to settings.
    await Geolocator.openAppSettings();
    return false;
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
  /// Re-checks the system location service and app permission on every call
  /// (so location silently starts working the moment the user grants it), then
  /// throws when unavailable. It NEVER deep-links to settings on its own —
  /// callers degrade gracefully (skip prayer times / Qibla) instead of yanking
  /// the user out of the app on every launch.
  ///
  /// Pass [openSettingsIfBlocked] `true` only from an explicit, user-initiated
  /// action (e.g. an "Enable location" button) to deep-link into settings when
  /// the OS won't re-prompt.
  static Future<Position> determinePosition({
    bool openSettingsIfBlocked = false,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      // System-level GPS toggle is off — independent of app permission.
      if (openSettingsIfBlocked) {
        await Geolocator.openLocationSettings();
        if (!await Geolocator.isLocationServiceEnabled()) {
          return Future.error('Location services are disabled.');
        }
      } else {
        return Future.error('Location services are disabled.');
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Not-yet-answered → the OS shows the native prompt exactly once.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permanently denied: the OS will not re-prompt. Only deep-link to app
      // settings on an explicit user action — otherwise just fail quietly so
      // the caller can skip location-dependent features.
      if (openSettingsIfBlocked) {
        await Geolocator.openAppSettings();
      }
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
