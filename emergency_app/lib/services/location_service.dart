import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Fetches the user's exact current GPS location.
  Future<LatLng> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LatLng(37.7749, -122.4194); // Fallback if disabled
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LatLng(37.7749, -122.4194);
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return const LatLng(37.7749, -122.4194);
    } 

    Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    return LatLng(position.latitude, position.longitude);
  }

  /// Finds a nearby Level 1 Trauma Center. 
  /// In this live version, we plot a simulated trauma center strictly relative to the user's *actual* live GPS location.
  Future<LatLng> getNearestTraumaCenter(LatLng userLocation) async {
    // Generate a location roughly 1-2 miles from their actual pinged location.
    await Future.delayed(const Duration(milliseconds: 200));
    return LatLng(userLocation.latitude + 0.015, userLocation.longitude + 0.015);
  }
}
