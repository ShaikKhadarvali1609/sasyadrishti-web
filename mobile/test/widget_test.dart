import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sasya_drishti/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SasyaDrishtiApp renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SasyaDrishtiApp());

    // Verify app bar title
    expect(find.text('SasyaDrishti'), findsOneWidget);

    // Verify navigation tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Disease'), findsOneWidget);
    expect(find.text('Irrigation'), findsNWidgets(2)); // Bottom nav and Home quick-action button
    expect(find.text('Research'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
