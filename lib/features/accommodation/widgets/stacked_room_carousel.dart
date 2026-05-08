import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';

class StackedRoomCarousel extends StatefulWidget {
  final List<RoomDto> rooms;
  final void Function(RoomDto room)? onRoomTap;

  const StackedRoomCarousel({
    super.key,
    required this.rooms,
    this.onRoomTap,
  });

  @override
  State<StackedRoomCarousel> createState() => _StackedRoomCarouselState();
}

class _StackedRoomCarouselState extends State<StackedRoomCarousel> {
  late PageController _pageController;
  // Deferred flag — PageView is only inserted into the tree after the first
  // frame, ensuring its slivers are fully laid out before any hit-testing
  // occurs. This prevents the `child.geometry! == null` crash in
  // RenderViewportBase.hitTestChildren during route transitions.
  bool _controllerReady = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.78,
    );
    // Wait for the first frame before showing the PageView so that the
    // PageController is attached and slivers are fully laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _controllerReady = true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rooms.isEmpty) return const SizedBox.shrink();

    // Show a placeholder until the controller is ready to avoid
    // hit-test crashes on uninitialized PageView slivers.
    if (!_controllerReady) {
      return const SizedBox(height: 240);
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        clipBehavior: Clip.none,
        itemCount: widget.rooms.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0;
              // Guard both hasClients AND haveDimensions before accessing page
              if (_pageController.hasClients &&
                  _pageController.position.haveDimensions) {
                value = (_pageController.page ?? 0) - index;
              }

              // Scale: current card = 1.0, adjacent cards smaller
              final scale = max(0.88, 1.0 - value.abs() * 0.12);
              // Slight vertical offset for depth
              final dy = value.abs() * 10.0;

              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: max(0.6, 1.0 - value.abs() * 0.3),
                    child: child,
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: () => widget.onRoomTap?.call(widget.rooms[index]),
              child: _buildCard(context, widget.rooms[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, RoomDto room) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/default_room.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 50)),
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.35, 0.6, 1.0],
              ),
            ),
          ),

          // Favorite Icon
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
            ),
          ),

          // Top Chip
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Recommended',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Details at Bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.description ?? 'Beautiful Room',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 Rating',
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${room.price?.round() ?? 0}',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ' /night',
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
