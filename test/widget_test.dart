import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Expense tracker smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Trigger a frame to let asynchronous operations complete.
    await tester.pumpAndSettle();

    // Verify that the title is present in the widget tree.
    expect(find.text('Expense Tracker'), findsOneWidget);

    // Verify that the Available Balance card title is displayed.
    expect(find.text('Available Balance'), findsOneWidget);
  });
}
