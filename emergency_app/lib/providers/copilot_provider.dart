import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/triage_service.dart';

class CopilotProvider extends ChangeNotifier {
  final TriageService _triageService = TriageService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isEmergency = false;
  bool get isEmergency => _isEmergency;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _transcript = '';
  String get transcript => _transcript;

  CopilotProvider();

  Future<void> startListening() async {
    _transcript = 'Initializing microphone...';
    _isListening = true;
    notifyListeners();

    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech Status: $status'),
        onError: (errorNotification) {
          debugPrint('Speech Error: ${errorNotification.errorMsg}');
          stopListening('Microphone Error: ${errorNotification.errorMsg}');
        },
      );

      if (available) {
        _transcript = 'Listening...';
        notifyListeners();

        await _speech.listen(
          onResult: (result) {
            _transcript = result.recognizedWords;
            notifyListeners();
            
            if (result.finalResult) {
              _processFinalTranscript(result.recognizedWords);
            }
          },
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 10),
        );
      } else {
        // Fallback if browser/emulator denies permissions or lacks support
        _transcript = 'Listening... (Simulating hardware)';
        notifyListeners();
        Future.delayed(const Duration(seconds: 4), () {
          _processFinalTranscript("Dad is not breathing");
        });
      }
    } catch (e) {
      debugPrint("Microphone Initialization Exception: $e");
      _transcript = 'Listening... (Simulating hardware)';
      notifyListeners();
      Future.delayed(const Duration(seconds: 4), () {
        _processFinalTranscript("Dad is not breathing");
      });
    }
  }

  void stopListening(String finalRecognizedText) {
    if (_isListening) {
      _speech.stop();
      _processFinalTranscript(finalRecognizedText);
    }
  }

  void _processFinalTranscript(String text) async {
    _isListening = false;
    _transcript = text;
    notifyListeners();

    if (text.isNotEmpty && !text.startsWith('Listening...') && !text.startsWith('Initializing')) {
      bool emergencyDetected = await _triageService.detectEmergencyIntent(text);
      if (emergencyDetected) {
        _isEmergency = true;
        notifyListeners();
      }
    }
  }

  void triggerManualEmergency() {
    _isEmergency = true;
    _transcript = 'Manual SOS Triggered';
    notifyListeners();
  }

  void reset() {
    _isEmergency = false;
    _transcript = '';
    notifyListeners();
  }
}
