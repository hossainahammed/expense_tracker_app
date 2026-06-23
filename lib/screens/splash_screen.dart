import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import '../expense_tracker.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  final String themeModeSetting;
  final Function(String) onThemeChanged;

  const SplashScreen({
    super.key,
    required this.isDarkMode,
    required this.themeModeSetting,
    required this.onThemeChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _loadingOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Pulse animation for the icon glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Loading bar animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _loadingController.forward();

    // Wait then navigate
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      _navigateToNext();
    }
  }

  Future<void> _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  ResponsiveExpenseTracker(
                    isDarkMode: widget.isDarkMode,
                    themeModeSetting: widget.themeModeSetting,
                    onThemeChanged: widget.onThemeChanged,
                  ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => OnboardingScreen(
                isDarkMode: widget.isDarkMode,
                themeModeSetting: widget.themeModeSetting,
                onThemeChanged: widget.onThemeChanged,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E1B4B),
                      const Color(0xFF0F172A),
                    ]
                    : [
                      const Color(0xFFE0F2FE),
                      const Color(0xFFBAE6FD),
                      const Color(0xFFE0F2FE),
                    ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Animated App Icon from assets
              AnimatedBuilder(
                animation: Listenable.merge([
                  _logoController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFF0EA5E9))
                                  .withValues(
                                    alpha: 0.35 * _pulseAnimation.value,
                                  ),
                              blurRadius: 35 * _pulseAnimation.value,
                              spreadRadius: 8 * _pulseAnimation.value,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/expense_app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App name with slide animation
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Text(
                        'SpendWise',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color:
                              isDark
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Subtitle
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _subtitleOpacity.value,
                    child: Text(
                      'Smart Expense Tracking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color:
                            isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),

              // Loading indicator
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingOpacity.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor:
                              isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFBAE6FD),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF0284C7),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Version text
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingOpacity.value,
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
