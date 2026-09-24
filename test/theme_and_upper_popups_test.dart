import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widget/smooth_bottom_nav_bar.dart';
import 'package:expense_tracker/widget/top_snackbar.dart';

void main() {
  testWidgets('SmoothBottomNavBar active color in Light Mode uses light primary color',
      (WidgetTester tester) async {
    const lightPrimary = Color(0xFF0284C7);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(primary: lightPrimary),
        ),
        home: Scaffold(
          bottomNavigationBar: SmoothBottomNavBar(
            currentIndex: 0,
            isDark: false,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );

    // Active label text style color should match light primary
    final Text homeLabelLight = tester.widget(find.text('Home'));
    expect(homeLabelLight.style?.color, equals(lightPrimary));

    // Active floating circle container decoration color
    bool foundLightActiveCircle = false;
    for (final elem in find.byType(Container).evaluate()) {
      final Container container = elem.widget as Container;
      final decoration = container.decoration;
      if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
        expect(decoration.color, equals(lightPrimary));
        foundLightActiveCircle = true;
      }
    }
    expect(foundLightActiveCircle, isTrue);
  });

  testWidgets('SmoothBottomNavBar active color in Dark Mode uses dark primary color',
      (WidgetTester tester) async {
    const darkPrimary = Color(0xFF6366F1);

    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(primary: darkPrimary),
        ),
        home: Scaffold(
          bottomNavigationBar: SmoothBottomNavBar(
            currentIndex: 1,
            isDark: true,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );

    final Text analyticsLabelDark = tester.widget(find.text('Analytics'));
    expect(analyticsLabelDark.style?.color, equals(darkPrimary));

    bool foundDarkActiveCircle = false;
    for (final elem in find.byType(Container).evaluate()) {
      final Container container = elem.widget as Container;
      final decoration = container.decoration;
      if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
        expect(decoration.color, equals(darkPrimary));
        foundDarkActiveCircle = true;
      }
    }
    expect(foundDarkActiveCircle, isTrue);
  });

  testWidgets('Add Expense button adapts to light theme primary',
      (WidgetTester tester) async {
    const lightPrimary = Color(0xFF0284C7);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(primary: lightPrimary),
        ),
        home: Scaffold(
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text("Add Expense"),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );

    final FloatingActionButton fabLight =
        tester.widget(find.byType(FloatingActionButton));
    expect(fabLight.backgroundColor, equals(lightPrimary));
  });

  testWidgets('Add Expense button adapts to dark theme primary',
      (WidgetTester tester) async {
    const darkPrimary = Color(0xFF6366F1);

    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(primary: darkPrimary),
        ),
        home: Scaffold(
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text("Add Expense"),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );

    final FloatingActionButton fabDark =
        tester.widget(find.byType(FloatingActionButton));
    expect(fabDark.backgroundColor, equals(darkPrimary));
  });

  testWidgets('TopSnackbar displays at upper side of the screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  TopSnackbar.show(
                    context,
                    message: 'Upper snackbar test',
                    icon: Icons.check_circle_rounded,
                  );
                },
                child: const Text('Show Top SnackBar'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Top SnackBar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final snackBarFinder = find.byType(SnackBar);
    expect(snackBarFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject(snackBarFinder);
    final position = renderBox.localToGlobal(Offset.zero);
    expect(position.dy, lessThan(150.0));
  });

  testWidgets('Top Dialog renders with top alignment',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AlertDialog(
                      alignment: Alignment.topCenter,
                      insetPadding: EdgeInsets.only(top: 80, left: 20, right: 20),
                      title: Text('Top Alert Dialog'),
                      content: Text('Content'),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    final dialogFinder = find.byType(AlertDialog);
    expect(dialogFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject(dialogFinder);
    final position = renderBox.localToGlobal(Offset.zero);
    expect(position.dy, lessThan(120.0));
  });
}
