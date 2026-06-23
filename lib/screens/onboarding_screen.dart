import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../expense_tracker.dart';

class OnboardingScreen extends StatefulWidget {
  final ValueNotifier<String> themeModeNotifier;

  const OnboardingScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/onboarding/track_expenses.png',
      title: 'Track Every Expense',
      description:
          'Easily add and manage your daily expenses across 15+ categories like Food, Transport, Shopping, and more. Tap the "+" button to get started!',
      gradientColors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      badges: [
        {'icon': Icons.fastfood_rounded, 'label': 'Food'},
        {'icon': Icons.directions_car_rounded, 'label': 'Transport'},
        {'icon': Icons.shopping_bag_rounded, 'label': 'Shopping'},
      ],
    ),
    OnboardingData(
      imagePath: 'assets/onboarding/visualize_spending.png',
      title: 'Visualize Your Spending',
      description:
          'See where your money goes with beautiful interactive pie charts. Filter by category, date range, and sort by amount or date to analyze your habits.',
      gradientColors: [const Color(0xFF0EA5E9), const Color(0xFF06B6D4)],
      badges: [
        {'icon': Icons.filter_alt_rounded, 'label': 'Filter'},
        {'icon': Icons.sort_rounded, 'label': 'Sort'},
        {'icon': Icons.calendar_today_rounded, 'label': 'Date'},
      ],
    ),
    OnboardingData(
      imagePath: 'assets/onboarding/budget_tracking.png',
      title: 'Set Budget & Stay On Track',
      description:
          'Set a monthly budget limit and get real-time alerts when you\'re close to exceeding it. Track your remaining balance at a glance with the progress bar.',
      gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
      badges: [
        {'icon': Icons.tune_rounded, 'label': 'Set Limit'},
        {'icon': Icons.warning_rounded, 'label': 'Alerts'},
        {'icon': Icons.trending_up_rounded, 'label': 'Progress'},
      ],
    ),
    OnboardingData(
      imagePath: 'assets/onboarding/personalize.png',
      title: 'Personalize Your Experience',
      description:
          'Switch between Light, Dark, or System theme with a single tap. Choose from multiple currencies (৳, \$, €, ₹, £) to match your region.',
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      badges: [
        {'icon': Icons.light_mode_rounded, 'label': 'Light'},
        {'icon': Icons.dark_mode_rounded, 'label': 'Dark'},
        {'icon': Icons.attach_money_rounded, 'label': 'Currency'},
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ResponsiveExpenseTracker(
          themeModeNotifier: widget.themeModeNotifier,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = widget.themeModeNotifier.value;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = themeMode == 'system'
        ? platformBrightness == Brightness.dark
        : themeMode == 'dark';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], isDark);
                  },
                ),
              ),

              // Bottom section: Dots + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildDot(index, isDark),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Next / Get Started button
                    GestureDetector(
                      onTapDown: (_) => _buttonController.forward(),
                      onTapUp: (_) {
                        _buttonController.reverse();
                        _nextPage();
                      },
                      onTapCancel: () => _buttonController.reverse(),
                      child: AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScale.value,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _pages[_currentPage].gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _pages[_currentPage]
                                        .gradientColors[0]
                                        .withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == _pages.length - 1
                                          ? 'Get Started'
                                          : 'Next',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentPage == _pages.length - 1
                                          ? Icons.rocket_launch_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}

  Widget _buildPage(OnboardingData data, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = (screenWidth * 0.55).clamp(180.0, 260.0);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Realistic image from assets
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                height: imageSize,
                width: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: data.gradientColors[0].withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Feature badge row
            _buildFeatureBadges(data, isDark),

            const SizedBox(height: 20),

            // Title
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  height: 1.2,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Description
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadges(OnboardingData data, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: data.badges.map((badge) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? data.gradientColors[0].withValues(alpha: 0.15)
                : data.gradientColors[0].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: data.gradientColors[0].withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                badge['icon'] as IconData,
                size: 16,
                color: data.gradientColors[0],
              ),
              const SizedBox(width: 4),
              Text(
                badge['label'] as String,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: data.gradientColors[0],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? _pages[_currentPage].gradientColors[0]
            : (isDark
                ? const Color(0xFF334155)
                : const Color(0xFFCBD5E1)),
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final List<Map<String, dynamic>> badges;

  OnboardingData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.badges,
  });
}
