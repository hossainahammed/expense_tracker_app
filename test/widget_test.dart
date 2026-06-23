import 'package:expense_tracker/my_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': true,
      'themeMode': 'light',
    });
  });

  testWidgets('Expense tracker smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Let the splash screen animations and navigation complete.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that the title is present in the widget tree.
    expect(find.text('SpendWise'), findsOneWidget);

    // Verify that the Available Balance card title is displayed.
    expect(find.text('Available Balance'), findsOneWidget);
  });
}
