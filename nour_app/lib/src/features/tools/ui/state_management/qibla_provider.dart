import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/geolocator/geolocator_tools.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import 'qibla_state.dart';

final qiblaProvider =
    StateNotifierProvider.autoDispose<QiblaPresenter, QiblaState>((ref) {
  return QiblaPresenter();
});

class QiblaPresenter extends Presenter<QiblaState> {
  QiblaPresenter() : super(const QiblaState());

  /// Resolves the device location, the Qibla bearing/distance (via
  /// [IslamicTools]) and a human-readable place label (reverse geocoding).
  ///
  /// The compass heading is NOT handled here — the widget binds to the sensor
  /// stream directly. This method only needs to run once per screen open.
  Future<void> init() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, hasLocationError: false);

    try {
      final position = await GeolocatorTools.currentOrCachedPosition();
      final qibla = await IslamicTools.getQibla(position: position);

      state = state.copyWith(
        isLoading: false,
        hasLocationError: false,
        bearing: qibla.bearing,
        distanceKm: qibla.distanceKm,
      );

      // Place name is best-effort: never let a geocoding failure break the
      // compass, which is the primary feature of the screen.
      final place = await _resolvePlaceName(position);
      if (place != null && mounted) {
        state = state.copyWith(placeName: place);
      }
    } catch (e, st) {
      talker.handle(e, st, 'Failed to resolve Qibla direction');
      state = state.copyWith(isLoading: false, hasLocationError: true);
    }
  }

  Future<String?> _resolvePlaceName(Position position) async {
    try {
      final marks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (marks.isEmpty) return null;
      final m = marks.first;
      final city = (m.locality?.isNotEmpty ?? false)
          ? m.locality
          : (m.subAdministrativeArea?.isNotEmpty ?? false)
              ? m.subAdministrativeArea
              : m.administrativeArea;
      final country = m.country;
      final label = [city, country]
          .where((p) => p != null && p.isNotEmpty)
          .join(', ');
      return label.isEmpty ? null : label;
    } catch (e, st) {
      talker.handle(e, st, 'Reverse geocoding failed');
      return null;
    }
  }
}
