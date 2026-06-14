import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';

import 'expense_tracker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DevicePreview(enabled: false, builder: (context) => const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
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
        cardTheme: CardThemeData(
          color: const Color(0xFFF0F9FF), // Ice-Blue (Sea Foam White)
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFBAE6FD), width: 1), // Soft blue border
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
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ResponsiveExpenseTracker(
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}
