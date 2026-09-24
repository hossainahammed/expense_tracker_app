import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/expense_tracker.dart';
import 'package:expense_tracker/screens/calculator_screen.dart';
import 'package:expense_tracker/screens/notes_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CalculatorScreen Tests', () {
    testWidgets('Basic addition arithmetic works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CalculatorScreen()),
      );

      // Tap 7 + 8 =
      await tester.tap(find.text('7'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('8'));
      await tester.pump();
      await tester.tap(find.text('='));
      await tester.pump();

      // Display should show 15
      expect(find.text('15'), findsOneWidget);
      expect(find.text('7 + 8 ='), findsOneWidget);
    });

    testWidgets('Multiplication and All Clear (AC) work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CalculatorScreen()),
      );

      // Tap 9 × 6 = 54
      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('×'));
      await tester.pump();
      await tester.tap(find.text('6'));
      await tester.pump();
      await tester.tap(find.text('='));
      await tester.pump();

      expect(find.text('54'), findsOneWidget);

      // Tap AC -> resets to 0
      await tester.tap(find.text('AC'));
      await tester.pump();

      // Display result is 0 and keypad button 0 is also 0
      expect(find.text('0'), findsNWidgets(2));
    });

    testWidgets('Decimal and backspace work properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CalculatorScreen()),
      );

      // Tap 2, ., 5 -> 2.5
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('.'));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();

      expect(find.text('2.5'), findsOneWidget);

      // Tap backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(find.text('2.'), findsOneWidget);
    });

    testWidgets('Copy result triggers TopSnackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CalculatorScreen()),
      );

      // Tap 4, 2
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      // Tap Copy action in AppBar
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Copied 42 to clipboard'), findsOneWidget);
    });
  });

  group('NotesScreen Tests', () {
    testWidgets('Displays empty state initially and can create a note',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotesScreen()),
      );
      await tester.pumpAndSettle();

      // Empty state visible
      expect(find.text('No notes in All yet'), findsOneWidget);

      // Tap New Note FAB
      await tester.tap(find.text('New Note'));
      await tester.pumpAndSettle();

      // Enter Title and Content
      final titleField = find.widgetWithText(TextField, 'Title');
      final contentField = find.widgetWithText(TextField, 'Note Content');

      await tester.enterText(titleField, 'Monthly Budget Goal');
      await tester.enterText(contentField, 'Save 30% of salary for investments.');

      // Tap Budget Category chip in modal sheet
      await tester.tap(find.widgetWithText(ChoiceChip, 'Budget').last);
      await tester.pump();

      // Tap Create Note button
      await tester.tap(find.text('Create Note'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar shows note added
      expect(find.text('Note added successfully'), findsOneWidget);
      await tester.pumpAndSettle();

      // Note card rendered in list
      expect(find.text('Monthly Budget Goal'), findsOneWidget);
      expect(find.text('Save 30% of salary for investments.'), findsOneWidget);
      expect(find.text('Budget'), findsWidgets);
    });

    testWidgets('Search and category filter work on NotesScreen',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'spendwise_user_notes':
            '[{"id":"1","title":"Grocery List","content":"Milk, Bread, Apples","category":"Shopping","updatedAt":"2026-09-24T10:00:00.000"},'
                '{"id":"2","title":"Office Utilities","content":"Electric bill pending","category":"Budget","updatedAt":"2026-09-24T10:05:00.000"}]',
      });

      await tester.pumpWidget(
        const MaterialApp(home: NotesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Grocery List'), findsOneWidget);
      expect(find.text('Office Utilities'), findsOneWidget);

      // Filter by Shopping category
      await tester.tap(find.widgetWithText(ChoiceChip, 'Shopping'));
      await tester.pumpAndSettle();

      expect(find.text('Grocery List'), findsOneWidget);
      expect(find.text('Office Utilities'), findsNothing);

      // Filter back to All
      await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
      await tester.pumpAndSettle();

      // Search by text "Electric"
      final searchField = find.widgetWithText(TextField, 'Search notes...');
      await tester.enterText(searchField, 'Electric');
      await tester.pumpAndSettle();

      expect(find.text('Grocery List'), findsNothing);
      expect(find.text('Office Utilities'), findsOneWidget);
    });

    testWidgets('Delete note confirmation dialog renders and deletes note',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'spendwise_user_notes':
            '[{"id":"1","title":"Temporary Note","content":"To be deleted","category":"General","updatedAt":"2026-09-24T10:00:00.000"}]',
      });

      await tester.pumpWidget(
        const MaterialApp(home: NotesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Temporary Note'), findsOneWidget);

      // Open popup menu on note card
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Tap Delete in menu
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify upper dialog appears
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      final RenderBox renderBox = tester.renderObject(dialogFinder);
      final position = renderBox.localToGlobal(Offset.zero);
      expect(position.dy, lessThan(120.0)); // Upper side of app

      // Confirm Delete
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Note deleted'), findsOneWidget);
      await tester.pumpAndSettle();

      // Note removed
      expect(find.text('Temporary Note'), findsNothing);
    });
  });

  group('Settings Screen Integration Tests', () {
    testWidgets('Settings screen contains Calculator and Expense Notes options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveExpenseTracker(
            themeModeNotifier: ValueNotifier('system'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings Tab (index 3)
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify Calculator and Expense Notes options exist
      expect(find.text('Calculator'), findsOneWidget);
      expect(find.text('Perform quick math & expense arithmetic'), findsOneWidget);

      expect(find.text('Expense Notes'), findsOneWidget);
      expect(find.text('Keep budget notes, shopping lists & reminders'), findsOneWidget);
    });
  });
}
