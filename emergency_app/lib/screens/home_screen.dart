import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/copilot_provider.dart';
import '../widgets/action_buttons.dart';
import '../widgets/trauma_map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CopilotProvider>(
      builder: (context, provider, child) {
        final isEmergency = provider.isEmergency;
        
        return Scaffold(
          backgroundColor: isEmergency ? Colors.red[900] : Colors.grey[50],
          appBar: AppBar(
            title: Text(
              isEmergency ? 'EMERGENCY DETECTED' : 'Emergency Copilot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isEmergency ? Colors.white : Colors.red[800],
              ),
            ),
            backgroundColor: isEmergency ? Colors.red[900] : Colors.white,
            elevation: isEmergency ? 0 : 2,
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isEmergency ? _buildEmergencyState(context, provider) : _buildNormalState(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildNormalState(BuildContext context, CopilotProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          provider.isListening ? Icons.mic : Icons.mic_none,
          size: 80,
          color: provider.isListening ? Colors.red : Colors.grey[400],
        ),
        const SizedBox(height: 24),
        Text(
          provider.isListening 
            ? 'Listening to intent...' 
            : 'Tap the microphone to state your emergency',
          style: const TextStyle(fontSize: 18, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (provider.transcript.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: Text(
              '"${provider.transcript}"',
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
          ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            if (!provider.isListening) {
              provider.startListening();
              // Mock Voice Intake & Gemini reasoning
              Future.delayed(const Duration(seconds: 2), () {
                provider.stopListening("Dad is not breathing");
              });
            }
          },
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[600],
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withAlpha(102),
                  spreadRadius: 8,
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.mic, color: Colors.white, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () {
            provider.triggerManualEmergency();
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red[600],
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withAlpha(50),
                  spreadRadius: 4,
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmergencyState(BuildContext context, CopilotProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Intent: "${provider.transcript}"',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ActionButtons(),
          const SizedBox(height: 32),
          const Text(
            'Nearest Level 1 Trauma Center',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const TraumaMapView(traumaCenterLocation: LatLng(37.7554, -122.4046)),
          const SizedBox(height: 30),
          Center(
            child: TextButton.icon(
              onPressed: () {
                provider.reset();
              },
              icon: const Icon(Icons.refresh, color: Colors.white70),
              label: const Text('Reset Demo', style: TextStyle(color: Colors.white70)),
            ),
          )
        ],
      ),
    );
  }
}
