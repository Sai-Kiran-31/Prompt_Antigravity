import 'dart:convert';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:http/http.dart' as http;


class ActionObject {
  final String action;
  final String priority;
  final List<String> instructions;
  final int? metronomeBpm;
  final String reasoning;

  final String? hospitalEta;
  final String? emsStatus;

  ActionObject({
    required this.action,
    required this.priority,
    required this.instructions,
    this.metronomeBpm,
    required this.reasoning,
    this.hospitalEta,
    this.emsStatus,
  });


  factory ActionObject.fromJson(Map<String, dynamic> json) {
    return ActionObject(
      action: json['action'] ?? 'UNKNOWN',
      priority: json['priority'] ?? 'MEDIUM',
      instructions: List<String>.from(json['instructions'] ?? []),
      metronomeBpm: json['metronome_bpm'],
      reasoning: json['reasoning'] ?? '',
      hospitalEta: json['hospital_eta'],
      emsStatus: json['ems_status'],
    );
  }

}

class ApiService {
  // Auto-switch between local dev and Cloud Run production
  static const String baseUrl = kReleaseMode
      ? 'https://aegis-backend-1079725957748.us-central1.run.app'
      : 'http://localhost:8081';

  static Future<ActionObject> processTranscript(String transcript, {Map<String, double>? location}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/agent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'transcript': transcript,
        'location': location,
      }),
    );

    if (response.statusCode == 200) {
      return ActionObject.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to process transcript: ${response.body}');
    }
  }
}
