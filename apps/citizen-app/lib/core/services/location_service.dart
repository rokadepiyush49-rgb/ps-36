import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../errors/failure.dart';

/// A resolved place: coordinates plus something human to show in the UI.
class ResolvedPosition {
  const ResolvedPosition({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;
}

class LocationService {
  /// Asks for permission, then returns the current fix.
  ///
  /// Throws a [PermissionFailure] the UI can show verbatim rather than a raw
  /// platform exception.
  Future<ResolvedPosition> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const PermissionFailure(
        'Location services are turned off. Turn them on, or pick the spot on '
        'the map instead.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const PermissionFailure(
        'JanMaang needs your location to route this report to the right ward. '
        'You can also pick the spot on the map.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return ResolvedPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      label: AppConfig.defaultDistrict,
    );
  }

  double distanceKm(double lat1, double lng1, double lat2, double lng2) =>
      Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);
