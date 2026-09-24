import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widget/smooth_bottom_nav_bar.dart';

void main() {
  testWidgets('SmoothBottomNavBar renders functional icons and labels with animated scoop', (WidgetTester tester) async {
    int selectedTab = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) {
              return SmoothBottomNavBar(
                currentIndex: selectedTab,
                isDark: false,
                onTabSelected: (index) {
                  setState(() => selectedTab = index);
                },
              );
            },
          ),
        ),
      ),
    );

    // Verify icons and corresponding names exist based on functionality
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.text('Home'), findsOneWidget);

    expect(find.byIcon(Icons.pie_chart_rounded), findsWidgets);
    expect(find.text('Analytics'), findsOneWidget);

    expect(find.byIcon(Icons.folder_rounded), findsWidgets);
    expect(find.text('Folders'), findsOneWidget);

    expect(find.byIcon(Icons.settings_rounded), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);

    // Tap on Folders tab (index 2)
    await tester.tap(find.text('Folders'));
    await tester.pumpAndSettle();
    expect(selectedTab, equals(2));

    // Tap on Analytics tab (index 1)
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(selectedTab, equals(1));
  });
}
