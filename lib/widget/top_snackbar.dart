import 'package:flutter/material.dart';

class TopSnackbar {
  /// Displays a floating SnackBar at the upper side of the screen.
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: (screenHeight - topPadding - 160).clamp(
            40.0,
            double.infinity,
          ),
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor:
            backgroundColor ??
            (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A)),
        duration: duration,
        elevation: 6,
      ),
    );
  }
}
