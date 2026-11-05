import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sasya_drishti/src/screens/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'local_disease_history': [
        '{"crop":"Tomato","prediction":"Tomato_Early_Blight","common_name":"Tomato Early Blight","confidence":0.965,"status":"SUCCESS","severity":"MODERATE","timestamp":"2026-11-05 08:00:00"}'
      ]
    });
  });

  testWidgets('HomeScreen renders premium dashboard components', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('SasyaDrishti'), findsOneWidget);

    // Verify Plot Selector
    expect(find.text('Green Valley Plot #1 — Tomato'), findsOneWidget);

    // Verify Metric Stat Cards
    expect(find.text('Monitored Crop'), findsOneWidget);
    expect(find.text('Field Health'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsNWidgets(2)); // Overview card & Telemetry mini card
    expect(find.text('Live Climate'), findsOneWidget);

    // Verify Advisory Card
    expect(find.text('AI AGRONOMIC ADVISORY'), findsOneWidget);

    // Verify Recent Scans Section
    expect(find.text('Recent Leaf Pathology Scans'), findsOneWidget);

    // Verify Smart Irrigation Section
    expect(find.text('Smart Irrigation (FAO-56)'), findsOneWidget);
    expect(find.text('Irrigation'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Quick Control Actions'), findsOneWidget);
    expect(find.text('Crop Doctor'), findsNWidgets(2)); // in feed button & quick actions
    expect(find.text('Research Data'), findsOneWidget);
    expect(find.text('IoT & Telemetry'), findsOneWidget);

    // Verify Hardware Telemetry Stream
    expect(find.text('Hardware Telemetry Stream'), findsOneWidget);
  });
}
