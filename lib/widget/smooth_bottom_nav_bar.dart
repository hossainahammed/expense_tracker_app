import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.label,
  });
}

class SmoothBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onAddPressed;
  final bool isDark;

  const SmoothBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onAddPressed,
    required this.isDark,
  });

  static const List<NavItemData> navItems = [
    NavItemData(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.pie_chart_rounded,
      label: 'Analytics',
    ),
    NavItemData(
      icon: Icons.folder_rounded,
      label: 'Folders',
    ),
    NavItemData(
      icon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  State<SmoothBottomNavBar> createState() => _SmoothBottomNavBarState();
}

class _SmoothBottomNavBarState extends State<SmoothBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _notchAnimation;
  double _currentFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _currentFraction = widget.currentIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _notchAnimation = Tween<double>(
      begin: _currentFraction,
      end: _currentFraction,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SmoothBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final target = widget.currentIndex.toDouble();
      _notchAnimation = Tween<double>(
        begin: _notchAnimation.value,
        end: target,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutCubic,
        ),
      );
      _controller.forward(from: 0.0);
      _currentFraction = target;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barBgColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor = widget.isDark
        ? Colors.black.withValues(alpha: 0.45)
        : const Color(0xFF0F172A).withValues(alpha: 0.12);
    final activeColor = Theme.of(context).colorScheme.primary;
    final unselectedColor =
        widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        height: 84, // accommodates the protruding circular active button
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final slotWidth = totalWidth / SmoothBottomNavBar.navItems.length;

            return AnimatedBuilder(
              animation: _notchAnimation,
              builder: (context, child) {
                final activeCenter = slotWidth * (_notchAnimation.value + 0.5);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Scooped Nav Bar Background with dynamic notch at active tab
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 64,
                      child: CustomPaint(
                        painter: AnimatedScoopedNavBarPainter(
                          centerX: activeCenter,
                          color: barBgColor,
                          shadowColor: shadowColor,
                          cornerRadius: 24.0,
                        ),
                      ),
                    ),

                    // 2. Navigation items row (Icons & labels)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 64,
                      child: Row(
                        children: List.generate(
                          SmoothBottomNavBar.navItems.length,
                          (index) {
                            final item = SmoothBottomNavBar.navItems[index];
                            final isSelected = widget.currentIndex == index;

                            return Expanded(
                              child: InkResponse(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onTabSelected(index);
                                },
                                radius: 28,
                                splashColor:
                                    activeColor.withValues(alpha: 0.15),
                                highlightColor: Colors.transparent,
                                child: isSelected
                                    ? Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            item.label,
                                            style: TextStyle(
                                              color: activeColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            item.icon,
                                            color: unselectedColor,
                                            size: 22,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              color: unselectedColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 3. Elevated Circular Floating Button sitting in the active notch
                    Positioned(
                      left: activeCenter - 24,
                      top: 0, // floats 20px above the bar's top line
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onTabSelected(widget.currentIndex);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: activeColor, // Reference Emerald Green
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.38),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                              child: Icon(
                                SmoothBottomNavBar
                                    .navItems[widget.currentIndex]
                                    .icon,
                                key: ValueKey<int>(widget.currentIndex),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter that dynamically draws a pill-shaped bar with a smooth,
/// concave scooped cradle centered at [centerX].
class AnimatedScoopedNavBarPainter extends CustomPainter {
  final double centerX;
  final Color color;
  final Color shadowColor;
  final double cornerRadius;

  AnimatedScoopedNavBarPainter({
    required this.centerX,
    required this.color,
    required this.shadowColor,
    this.cornerRadius = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const notchWidth = 74.0;
    const notchDepth = 32.0;

    final path = Path();
    path.moveTo(cornerRadius, 0);

    // Left line up to the start of the scoop
    final scoopStart = centerX - notchWidth / 2;
    final scoopEnd = centerX + notchWidth / 2;

    if (scoopStart > cornerRadius) {
      path.lineTo(scoopStart, 0);
    }

    // Smooth bezier curve dipping down into the center cradle
    path.cubicTo(
      centerX - notchWidth * 0.32,
      0,
      centerX - notchWidth * 0.28,
      notchDepth,
      centerX,
      notchDepth,
    );

    // Smooth bezier curve rising up out of the cradle
    path.cubicTo(
      centerX + notchWidth * 0.28,
      notchDepth,
      centerX + notchWidth * 0.32,
      0,
      scoopEnd,
      0,
    );

    // Right horizontal line
    if (w - cornerRadius > scoopEnd) {
      path.lineTo(w - cornerRadius, 0);
    }
    path.arcToPoint(
      Offset(w, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );

    // Right vertical line
    path.lineTo(w, h - cornerRadius);
    path.arcToPoint(
      Offset(w - cornerRadius, h),
      radius: Radius.circular(cornerRadius),
    );

    // Bottom horizontal line
    path.lineTo(cornerRadius, h);
    path.arcToPoint(
      Offset(0, h - cornerRadius),
      radius: Radius.circular(cornerRadius),
    );

    // Left vertical line
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
    );

    path.close();

    // Soft drop shadow
    canvas.drawShadow(path, shadowColor, 8.0, false);

    // Solid surface fill
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedScoopedNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
