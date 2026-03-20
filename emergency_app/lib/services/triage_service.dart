import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TriageService {
  late final GenerativeModel _model;

  TriageService() {
    final apiKey = dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null;
    if (apiKey == null || apiKey.isEmpty) {
      // In a real app we would throw an exception, but for safety in the 
      // absence of a valid key in the .env, we initialize a dummy model
      // so it doesn't crash on startup.
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'DUMMY_KEY');
    } else {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system('You are a high-stakes emergency medical triage AI. The user provides a raw voice transcript. If the transcript describes a critical life-threatening emergency (like not breathing, heart attack, unconsciousness, severe bleeding, fire), reply with exactly "TRUE". Otherwise, if it is minor or conversational, reply exactly "FALSE".'),
      );
    }
  }

  /// Analyzes the text and determines if it constitutes an emergency using Gemini.
  Future<bool> detectEmergencyIntent(String text) async {
    if (text.trim().isEmpty) return false;
    
    // If no real API key is provided, fallback to rule-based logic to avoid crashes
    if (!dotenv.isInitialized || dotenv.env['GEMINI_API_KEY'] == null || dotenv.env['GEMINI_API_KEY']!.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      final lower = text.toLowerCase();
      return lower.contains('not breathing') || lower.contains('heart attack') || lower.contains('emergency') || lower.contains('help');
    }

    try {
      final response = await _model.generateContent([Content.text(text)]);
      final result = response.text?.trim().toUpperCase() ?? 'FALSE';
      return result.contains('TRUE');
    } catch (e) {
      // Fallback rule-based if API fails
      final lower = text.toLowerCase();
      return lower.contains('not breathing') || lower.contains('heart attack') || lower.contains('emergency');
    }
  }
}
