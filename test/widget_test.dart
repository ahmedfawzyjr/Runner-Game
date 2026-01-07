// Basic Flutter widget test for Neon Runner
//
// This test verifies the app loads correctly.

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_runner/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const NeonRunnerApp());
    
    // Verify the app loads (splash screen should appear)
    await tester.pump(const Duration(milliseconds: 100));
    
    // App should not crash
    expect(tester.takeException(), isNull);
  });
}
