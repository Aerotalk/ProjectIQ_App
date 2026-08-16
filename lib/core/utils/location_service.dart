import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationResult {
  final Position? position;
  final String? locationLabel;
  final String? error;
  final bool isMocked;

  LocationResult({this.position, this.locationLabel, this.error, this.isMocked = false});
}

class LocationService {
  /// Captures the current position with timeout fallbacks and mock detection.
  static Future<LocationResult> getSecureLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(error: 'Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(error: 'Location permissions are denied.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return LocationResult(error: 'Location permissions are permanently denied.');
      }

      // Attempt high accuracy first, fallback to medium if weak signal causes a timeout
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } on TimeoutException {
        debugPrint("High accuracy GPS timed out. Falling back to medium accuracy.");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      }

      // Security check: Reject spoofed GPS locations
      if (position.isMocked) {
         return LocationResult(error: 'Spoofed or Mocked location detected.', isMocked: true);
      }

      // Reverse geocode to get a human-readable location label
      String? locationLabel;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationLabel = [place.subLocality, place.locality, place.administrativeArea]
              .where((e) => e != null && e.isNotEmpty)
              .join(', ');
        }
      } catch (e) {
        debugPrint("Reverse geocoding failed: $e");
      }

      return LocationResult(position: position, locationLabel: locationLabel);
    } catch (e) {
      return LocationResult(error: e.toString());
    }
  }
}
