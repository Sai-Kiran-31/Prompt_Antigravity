import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MetronomeWidget extends StatefulWidget {
  final int? bpm;
  const MetronomeWidget({super.key, this.bpm});

  @override
  State<MetronomeWidget> createState() => _MetronomeWidgetState();
}

class _MetronomeWidgetState extends State<MetronomeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer? _timer;
  final AudioPlayer _player = AudioPlayer();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    final bpmValue = widget.bpm ?? 110;
    _controller = AnimationController(
      duration: Duration(milliseconds: (60 / bpmValue * 1000 / 2).round()),
      vsync: this,
    )..repeat(reverse: true);

    _startMetronome(bpmValue);
  }

  void _startMetronome(int bpm) {
    final interval = Duration(milliseconds: (60 / bpm * 1000).round());

    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        _isVisible = !_isVisible;
      });
      // Optionally play a sound (uncomment if assets are ready)
      // _player.play(AssetSource('tick.mp3'));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isVisible ? Colors.cyanAccent.withOpacity(0.8) : Colors.transparent,
            boxShadow: _isVisible
                ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]
                : [],
            border: Border.all(color: Colors.cyanAccent, width: 4),
          ),
          child: const Center(
            child: Icon(Icons.favorite, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "PUSH TO THE BEAT (110 BPM)",
          style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
