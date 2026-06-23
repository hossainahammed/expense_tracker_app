import 'package:expense_tracker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<String> themeModeNotifier = ValueNotifier('system');

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    themeModeNotifier.value = prefs.getString('themeMode') ?? 'system';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeModeNotifier,
      builder: (context, themeModeSetting, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SpendWise',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFE0F2FE), // Soft Sea Water Blue
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0EA5E9), // Ocean Blue
              brightness: Brightness.light,
              primary: const Color(0xFF0284C7),
              secondary: const Color(0xFF0D9488),
              surface: const Color(0xFFF0F9FF),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
              titleMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              bodyLarge: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Color(0xFF0F172A),
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF475569),
              ),
              bodySmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
              ),
              labelSmall: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFFF0F9FF), // Ice-Blue (Sea Foam White)
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: Color(0xFFBAE6FD),
                  width: 1,
                ), // Soft blue border
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFE0F2FE),
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF0369A1)),
              titleTextStyle: TextStyle(
                color: Color(0xFF0369A1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF818CF8), // Indigo Light
              brightness: Brightness.dark,
              primary: const Color(0xFF6366F1),
              secondary: const Color(0xFF38BDF8),
              surface: const Color(0xFF1E293B), // Slate 800
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
              titleMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
              bodyLarge: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Color(0xFFF1F5F9),
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF94A3B8),
              ),
              bodySmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
              ),
              labelSmall: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E293B),
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0x7F334155), width: 1),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
              titleTextStyle: TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            useMaterial3: true,
          ),
          themeMode: themeModeSetting == 'system'
              ? ThemeMode.system
              : (themeModeSetting == 'dark' ? ThemeMode.dark : ThemeMode.light),
          home: SplashScreen(
            themeModeNotifier: themeModeNotifier,
          ),
        );
      },
    );
  }
}
