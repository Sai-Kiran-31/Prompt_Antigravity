import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TraumaMapView extends StatelessWidget {
  final LatLng traumaCenterLocation;

  const TraumaMapView({super.key, required this.traumaCenterLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: traumaCenterLocation,
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('trauma_center'),
              position: traumaCenterLocation,
              infoWindow: const InfoWindow(title: 'Level 1 Trauma Center'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          },
        ),
      ),
    );
  }
}
