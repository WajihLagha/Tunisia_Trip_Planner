import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';

/// Data class for the quick-action menu items that fan out from the FAB.
class _FabMenuItem {
  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

// ─────────────────────────────────────────────────────────────────────────────
//  TripBottomNavBar  –  Stateful (needs AnimationController for the FAB menu)
// ─────────────────────────────────────────────────────────────────────────────
class TripBottomNavBar extends StatefulWidget {
  const TripBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onStartNewTrip,
    required this.onAddPlace,
    required this.onAddStay,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onStartNewTrip;
  final VoidCallback onAddPlace;
  final VoidCallback onAddStay;

  @override
  State<TripBottomNavBar> createState() => _TripBottomNavBarState();
}

class _TripBottomNavBarState extends State<TripBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconRotation;
  late final Animation<double> _menuScale;
  late final Animation<double> _overlayOpacity;

  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _iconRotation = Tween<double>(begin: 0.0, end: math.pi / 4) // 45° → ×
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _menuScale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);

    _overlayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
    if (_isMenuOpen) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() => _isMenuOpen = false);
      _ctrl.reverse();
    }
  }

  void _onMenuItemTap(VoidCallback action) {
    _closeMenu();
    // Small delay so the closing animation plays before navigation
    Future.delayed(const Duration(milliseconds: 150), action);
  }

  // ── Navigation data ──────────────────────────────────────────────────────
  static const _items = [
    _NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    _NavItem(icon: Icons.hotel_rounded, label: 'Stays'),
    _NavItem(icon: null, label: ''), // FAB placeholder
    _NavItem(icon: Icons.directions_car_rounded, label: 'Cars'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barColor = isDark ? AppColors.navBarDark : AppColors.navBarLight;
    final selectedColor = isDark ? AppColors.green100 : AppColors.primary;
    final unselectedColor =
        isDark ? AppColors.green700 : const Color(0xFFADC8C3);
    final fabBgColor = isDark ? AppColors.green300 : AppColors.primary;
    final fabIconColor = isDark ? AppColors.green950 : Colors.white;

    final menuItems = [
      _FabMenuItem(
        icon: Icons.auto_awesome_rounded,
        label: 'Start Trip',
        onTap: () => _onMenuItemTap(widget.onStartNewTrip),
      ),
      _FabMenuItem(
        icon: Icons.add_location_alt_outlined,
        label: 'Add Place',
        onTap: () => _onMenuItemTap(widget.onAddPlace),
      ),
      _FabMenuItem(
        icon: Icons.hotel_rounded,
        label: 'Add Stays',
        onTap: () => _onMenuItemTap(widget.onAddStay),
      ),
    ];

    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Scrim / overlay that catches taps to close ──────────────────
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _overlayOpacity,
                  builder: (_, __) => Container(
                    color: Colors.black
                        .withValues(alpha: 0.35 * _overlayOpacity.value),
                  ),
                ),
              ),
            ),

          // ── Bottom bar area ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 62,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // ── Bar background ─────────────────────────────────────
                    Positioned.fill(
                      child: _BarShape(color: barColor, isDark: isDark),
                    ),

                    // ── Nav items ──────────────────────────────────────────
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        height: 62,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_items.length, (i) {
                            if (i == 2) {
                              // Placeholder gap – the FAB sits here
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _buildFab(fabBgColor, fabIconColor, barColor, isDark),
                              );
                            }
                            final item = _items[i];
                            final logicalIndex = i < 2 ? i : i - 1;
                            final selected =
                                widget.currentIndex == logicalIndex;

                            return _NavButton(
                              icon: item.icon!,
                              label: item.label,
                              selected: selected,
                              selectedColor: selectedColor,
                              unselectedColor: unselectedColor,
                              onTap: () {
                                _closeMenu();
                                widget.onTap(logicalIndex);
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Fan-out menu items ──────────────────────────────────────────
          if (_isMenuOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 100, // above the bar
              child: _buildFanMenu(menuItems, isDark, fabBgColor),
            ),
        ],
      ),
    );
  }

  // ── FAB circle (inline with the other icons) ─────────────────────────────
  Widget _buildFab(Color bgColor, Color iconColor, Color barColor, bool isDark) {
    final pageBgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    return GestureDetector(
      onTap: _toggleMenu,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: pageBgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _iconRotation,
          builder: (_, child) => Transform.rotate(
            angle: _iconRotation.value,
            child: child,
          ),
          child: Icon(Icons.add_rounded, color: iconColor, size: 30),
        ),
      ),
        ),
      ),
    );
  }

  // ── Fan-out menu (3 items in a row, centered) ────────────────────────────
  Widget _buildFanMenu(
    List<_FabMenuItem> items,
    bool isDark,
    Color accentColor,
  ) {
    return AnimatedBuilder(
      animation: _menuScale,
      builder: (_, child) {
        return Transform.scale(
          scale: _menuScale.value,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: _menuScale.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _FanMenuItem(
              icon: item.icon,
              label: item.label,
              accentColor: accentColor,
              isDark: isDark,
              onTap: item.onTap,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single fan-out menu item  (circle icon + label underneath)
// ─────────────────────────────────────────────────────────────────────────────
class _FanMenuItem extends StatelessWidget {
  const _FanMenuItem({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantD
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _NavItem  (data class for the bottom bar items)
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData? icon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Individual nav button (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform:
                  Matrix4.translationValues(0, selected ? -6.0 : 0.0, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey(selected),
                  color: selected ? selectedColor : unselectedColor,
                  size: selected ? 24 : 22,
                  shadows: selected
                      ? [
                          Shadow(
                            color: selectedColor.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          Shadow(
                            color: selectedColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? selectedColor : unselectedColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bar shape  –  simple rounded rectangle (no notch, FAB is inline)
// ─────────────────────────────────────────────────────────────────────────────
class _BarShape extends StatelessWidget {
  const _BarShape({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PillBarPainter(color: color, isDark: isDark),
    );
  }
}

class _PillBarPainter extends CustomPainter {
  const _PillBarPainter({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.3 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    const radius = 28.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    canvas.drawRRect(rrect, shadowPaint);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_PillBarPainter old) => old.color != color;
}