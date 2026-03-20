import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AegisApp());
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Copilot',
      debugShowCheckedModeBanner: false,
      theme: AegisTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
