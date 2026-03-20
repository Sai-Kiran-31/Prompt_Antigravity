import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import 'emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHolding = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }


  void _handleHoldStart() {
    setState(() => _isHolding = true);
  }

  void _handleHoldEnd() async {
    setState(() => _isHolding = false);
    
    // Simulating a transcript for testing (to be replaced by real STT if needed)
    // In a real app, we'd record audio and send it.
    final transcript = "Help, my friend is having a heart attack at 123 Main St";
    
    try {
      final action = await ApiService.processTranscript(transcript);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyScreen(action: action)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF1C1C1E)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "AEGIS COPILOT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onLongPressStart: (_) => _handleHoldStart(),
                  onLongPressEnd: (_) => _handleHoldEnd(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isHolding)
                        Pulse(
                          infinite: true,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                        ),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF3B30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3B30).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mic, color: Colors.white, size: 60),
                              const SizedBox(height: 12),
                              Text(
                                _isHolding ? "LISTENING..." : "HOLD TO SPEAK",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Describe the emergency clearly. \nAegis will handle the rest.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _textController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    cursorColor: const Color(0xFFFF3B30),
                    decoration: InputDecoration(
                      hintText: "OR TYPE EMERGENCY HERE",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white10, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.keyboard, color: Colors.white24),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Color(0xFFFF3B30)),
                        onPressed: () {
                          _handleTextSubmit(_textController.text);
                          _textController.clear(); // Clear text after submission
                        },
                      ),
                    ),
                    onSubmitted: (value) => _handleTextSubmit(value),
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }

  void _handleTextSubmit(String value) async {
    if (value.trim().isEmpty) return;
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing emergency request..."), duration: Duration(seconds: 1)),
    );

    try {
      final action = await ApiService.processTranscript(value);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyScreen(action: action)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}

