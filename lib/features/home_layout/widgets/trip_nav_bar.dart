import 'package:flutter/material.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TripBottomNavBar
//
//  Mimics the design from the screenshots:
//    • Light mode  → white pill-shaped bar, green floating center button
//      with a notch / bump cut-out.
//    • Dark mode   → deep-teal pill bar, lighter green floating button.
//
//  Usage:
//    TripBottomNavBar(
//      currentIndex: _selectedIndex,
//      onTap:        (i) => setState(() => _selectedIndex = i),
//      onFabTap:     () { /* open explore / camera / etc. */ },
//    )
//
//  Put it inside a Scaffold like this:
//    bottomNavigationBar: TripBottomNavBar( … ),
//    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// ─────────────────────────────────────────────────────────────────────────────

class TripBottomNavBar extends StatelessWidget {
  const TripBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  static const _items = [
    _NavItem(icon: Icons.explore_rounded,    label: 'Explore'),
    _NavItem(icon: Icons.favorite_rounded,   label: 'Favourite'),
    _NavItem(icon: null,                     label: ''),   // FAB placeholder
    _NavItem(icon: Icons.directions_car_rounded, label: 'Cars'),
    _NavItem(icon: Icons.person_rounded,     label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barColor = isDark ? AppColors.navBarDark : AppColors.navBarLight;
    final selectedColor =
    isDark ? AppColors.green100 : AppColors.primary;
    final unselectedColor =
    isDark ? AppColors.green700 : const Color(0xFFADC8C3);
    final fabBgColor =
    isDark ? AppColors.green300 : AppColors.primary;
    final fabIconColor =
    isDark ? AppColors.green950 : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 70,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // ── Bar background ──────────────────────────────────────────
              Positioned.fill(
                top: 10, // leave room for FAB overflow
                child: _BarShape(
                  color: barColor,
                  isDark: isDark,
                ),
              ),

              // ── Nav items ───────────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_items.length, (i) {
                      if (i == 2) {
                        // Gap for FAB
                        return const SizedBox(width: 60);
                      }
                      final item = _items[i];
                      // Map logical index skipping slot 2
                      final logicalIndex = i < 2 ? i : i - 1;
                      final selected = currentIndex == logicalIndex;

                      return _NavButton(
                        icon:          item.icon!,
                        label:         item.label,
                        selected:      selected,
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        onTap: () => onTap(logicalIndex),
                      );
                    }),
                  ),
                ),
              ),

              // ── Floating Action Button ───────────────────────────────────
              Positioned(
                bottom: 28,
                child: GestureDetector(
                  onTap: onFabTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:  58,
                    height: 58,
                    decoration: BoxDecoration(
                      color:     fabBgColor,
                      shape:     BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:       fabBgColor.withOpacity(0.4),
                          blurRadius:  16,
                          spreadRadius: 2,
                          offset:      const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: fabIconColor,
                      size:  32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData? icon;
  final String label;
}

// ── Individual nav button ─────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData  icon;
  final String    label;
  final bool      selected;
  final Color     selectedColor;
  final Color     unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:       onTap,
      behavior:    HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(0, selected ? -6.0 : 0.0, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key:   ValueKey(selected),
                  color: selected ? selectedColor : unselectedColor,
                  size:  selected ? 28 : 24,
                  shadows: selected
                      ? [
                          Shadow(
                            color: selectedColor.withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          Shadow(
                            color: selectedColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Active dot instead of label text (like screenshot 1 style)
            // Toggle the comment blocks below to switch between dot / label.

            /* ── LABEL style (like screenshot 2) ── */
            Text(
              label,
              style: TextStyle(
                fontSize:   10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color:      selected ? selectedColor : unselectedColor,
                letterSpacing: 0.5,
              ),
            ),

            /* ── DOT style (like screenshot 1) ── *
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  selected ? 5 : 0,
              height: selected ? 5 : 0,
              decoration: BoxDecoration(
                color:  selectedColor,
                shape:  BoxShape.circle,
              ),
            ),
            * ────────────────────────────────── */
          ],
        ),
      ),
    );
  }
}

// ── Bar shape with centre bump cut-out ───────────────────────────────────────
class _BarShape extends StatelessWidget {
  const _BarShape({required this.color, required this.isDark});

  final Color color;
  final bool  isDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BumpBarPainter(color: color, isDark: isDark),
    );
  }
}

class _BumpBarPainter extends CustomPainter {
  const _BumpBarPainter({required this.color, required this.isDark});

  final Color color;
  final bool  isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color  = color
      ..style  = PaintingStyle.fill;

    // Drop shadow
    final shadowPaint = Paint()
      ..color       = Colors.black.withOpacity(isDark ? 0.3 : 0.08)
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = _buildPath(size);
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size size) {
    const radius   = 28.0;   // pill corner radius
    const notchR   = 34.0;   // FAB circle radius (a bit larger for breathing room)
    final cx       = size.width / 2;

    final path = Path();

    // Start top-left corner
    path.moveTo(radius, 0);

    // Top-left → notch start
    final notchLeft = cx - notchR;
    path.lineTo(notchLeft - 8, 0);

    // Notch curve (concave arc for the FAB)
    path.arcToPoint(
      Offset(cx + notchR + 8, 0),
      radius:    const Radius.circular(notchR + 6),
      clockwise: false,
    );

    // Notch end → top-right
    path.lineTo(size.width - radius, 0);

    // Top-right corner
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );

    // Right side → bottom-right
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );

    // Bottom edge
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );

    // Left side → top-left corner close
    path.lineTo(0, radius);
    path.arcToPoint(
      const Offset(radius, 0),
      radius: const Radius.circular(radius),
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_BumpBarPainter old) => old.color != color;
}