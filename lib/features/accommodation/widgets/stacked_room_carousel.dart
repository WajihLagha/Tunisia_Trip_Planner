import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';

class StackedRoomCarousel extends StatefulWidget {
  final List<RoomDto> rooms;

  const StackedRoomCarousel({super.key, required this.rooms});

  @override
  State<StackedRoomCarousel> createState() => _StackedRoomCarouselState();
}

class _StackedRoomCarouselState extends State<StackedRoomCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  final int _initialPage = 10000;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 1.0, // Full width for stacking logic
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rooms.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
              } else {
                value = (_initialPage - index).toDouble();
              }

              // The card is being swiped away
              if (value > 0) {
                return Opacity(
                  opacity: max(0.0, 1.0 - value),
                  child: Transform.translate(
                    offset: Offset(0, 0), // Use default page view scroll
                    child: Transform.scale(
                      scale: max(0.8, 1.0 - (value * 0.1)),
                      child: child,
                    ),
                  ),
                );
              } 
              // Cards stacked behind
              else {
                double absValue = value.abs();
                
                // Stack up to 3 cards behind
                if (absValue > 3) return const SizedBox.shrink();

                // Counteract the default horizontal offset of PageView to stack them in the center
                // PageView automatically shifts items by `value * screenWidth`
                // We must calculate the exact width to counteract it. 
                // Using LayoutBuilder to get exact width is better, but since viewportFraction is 1.0, 
                // we can use MediaQuery width or let PageView handle the base and we just translate.
                
                double screenWidth = MediaQuery.of(context).size.width;
                double cancelHorizontalScroll = absValue * screenWidth;

                double scale = max(0.8, 1.0 - (absValue * 0.08));
                double dy = -absValue * 35.0; // Move up by 35px for each depth level

                return Transform.translate(
                  offset: Offset(cancelHorizontalScroll, dy),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: max(0.0, 1.0 - (absValue * 0.2)),
                      child: child,
                    ),
                  ),
                );
              }
            },
            child: Center(
              child: _buildCard(context, widget.rooms[index % widget.rooms.length]),
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
      width: MediaQuery.of(context).size.width * 0.85,
      height: 320,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              room.images?.firstOrNull?.imageUrl ?? 'assets/images/room_placeholder.png',
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
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Favorite Icon
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.favorite_border, color: Colors.white, size: 22),
            ),
          ),

          // Top Chip
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Recommended',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // Details at Bottom
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.description ?? 'Beautiful Room',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 Rating', // Mock rating for room
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${room.price?.round() ?? 0}',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ' /night',
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
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
