import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:emergency_app/main.dart';
import 'package:emergency_app/providers/copilot_provider.dart';

void main() {
  testWidgets('SOS Button smoke test', (WidgetTester tester) async {

    // Build our app with the exact same MultiProvider structure as main.dart
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CopilotProvider()),
        ],
        child: const EmergencyApp(),
      ),
    );

    // Verify that our SOS button is present on the regular screen.
    expect(find.text('SOS'), findsOneWidget);
  });
}
