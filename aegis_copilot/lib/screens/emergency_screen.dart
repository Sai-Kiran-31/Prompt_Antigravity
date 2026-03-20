import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../widgets/metronome_widget.dart';
import '../widgets/instruction_card.dart';

class EmergencyScreen extends StatelessWidget {
  final ActionObject action;
  const EmergencyScreen({super.key, required this.action});

  void _showHandoverDialog(BuildContext context) {
    final handoverData = {
      "start": DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      "symptoms": action.reasoning,
      "location": "37.7749, -122.4194",
      "protocols": action.action,
      "administered": action.instructions,
    };

    final qrData = jsonEncode(handoverData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("EMS HANDOVER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scan this to sync emergency data with EMS tablet.", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = action.priority == 'CRITICAL' || action.priority == 'HIGH';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _showHandoverDialog(context),
            icon: const Icon(Icons.qr_code, color: Colors.cyanAccent),
            label: const Text("HANDOVER", style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
        title: Text(
          action.priority,
          style: TextStyle(
            color: isCritical ? const Color(0xFFFF3B30) : Colors.amber,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCritical)
                  Center(
                    child: FadeInDown(child: MetronomeWidget(bpm: action.metronomeBpm)),
                  ),

                const SizedBox(height: 32),
                const Text(
                  "INSTRUCTIONS",
                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...action.instructions.asMap().entries.map((entry) {
                   return FadeInLeft(
                     delay: Duration(milliseconds: entry.key * 200),
                     child: InstructionCard(step: entry.value, index: entry.key),
                   );
                }),
                const SizedBox(height: 40),
                const Text(
                  "NEAREST HOSPITAL",
                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.7749, -122.4194), // Placeholder (SF)
                      zoom: 14,
                    ),
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
                const SizedBox(height: 100), // Space for pinned button
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: FadeInUp(
              child: ElevatedButton(
                onPressed: () {
                  // Simulate 911 call
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 20,
                  shadowColor: Colors.red.withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "CALL 911 NOW",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
