import 'package:equatable/equatable.dart';

/// Immutable Qibla-finder screen state (hand-written, mirrors PrayerTimesState).
///
/// Only the *location-derived* data lives here (qibla bearing, distance,
/// resolved place name). The high-frequency compass heading is intentionally
/// kept out of the state — it is consumed directly from the sensor stream in
/// [QiblaCompassWidget] to avoid flooding the StateNotifier with rebuilds.
class QiblaState extends Equatable {
  final bool isLoading;
  final bool hasLocationError;

  /// Qibla bearing from the device location to the Kaaba, clockwise from true
  /// north (0..360). Null until resolved / on error.
  final double? bearing;

  /// Great-circle distance to the Kaaba, in kilometres. Null until resolved.
  final double? distanceKm;

  /// Reverse-geocoded "City, Country" label (e.g. "Roissy-en-Brie, France").
  /// Null while still resolving or when geocoding is unavailable.
  final String? placeName;

  const QiblaState({
    this.isLoading = false,
    this.hasLocationError = false,
    this.bearing,
    this.distanceKm,
    this.placeName,
  });

  bool get isReady => bearing != null && distanceKm != null;

  QiblaState copyWith({
    bool? isLoading,
    bool? hasLocationError,
    double? bearing,
    double? distanceKm,
    String? placeName,
  }) {
    return QiblaState(
      isLoading: isLoading ?? this.isLoading,
      hasLocationError: hasLocationError ?? this.hasLocationError,
      bearing: bearing ?? this.bearing,
      distanceKm: distanceKm ?? this.distanceKm,
      placeName: placeName ?? this.placeName,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        hasLocationError,
        bearing,
        distanceKm,
        placeName,
      ];
}
