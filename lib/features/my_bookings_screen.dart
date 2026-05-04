import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';

enum BookingType { car, hotel, trip }

class BookingModel {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final BookingType type;
  final String? refNumber;

  BookingModel({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.type,
    this.refNumber,
  });
}

// Test data
final List<BookingModel> mockBookings = [
  BookingModel(
    title: 'Car Rental - Clio',
    date: '12 Oct, 10:00 AM',
    status: 'PENDING',
    statusColor: const Color(0xFFFF9800),
    type: BookingType.car,
    refNumber: '#TR-88291',
  ),
  BookingModel(
    title: 'Hotel Majestic Tunis',
    date: '12 Oct - 15 Oct',
    status: 'CONFIRMED',
    statusColor: const Color(0xFF4CAF50),
    type: BookingType.hotel,
    refNumber: '#HT-12345',
  ),
  BookingModel(
    title: 'Sahara Desert Trip',
    date: '20 Nov - 22 Nov',
    status: 'CANCELLED',
    statusColor: const Color(0xFFF44336),
    type: BookingType.trip,
    refNumber: '#TR-99120',
  ),
];

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter test data based on selected index
    List<BookingModel> filteredBookings;
    if (_selectedIndex == 0) {
      filteredBookings = mockBookings.where((b) => b.status != 'CANCELLED').toList();
    } else if (_selectedIndex == 1) {
      filteredBookings = mockBookings.where((b) => b.status == 'CONFIRMED').toList();
    } else {
      // Intentionally clear to show empty state for test
      filteredBookings = []; 
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Bookings',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantD : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Upcoming', isDark),
                  _buildTab(1, 'Completed', isDark),
                  _buildTab(2, 'Cancelled', isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // List or Empty State
          Expanded(
            child: filteredBookings.isEmpty
                ? _EmptyState(
                    icon: '📅',
                    title: 'No Bookings Yet',
                    subtitle: 'Looks like you don\'t have any bookings in this category.',
                    isDark: isDark,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _buildBookingCard(booking, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, bool isDark) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E6C3) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.black87
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, bool isDark) {
    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    switch (booking.type) {
      case BookingType.car:
        iconData = Icons.directions_car_rounded;
        iconBgColor = const Color(0xFFD9FBF5);
        iconColor = const Color(0xFF00796B);
        break;
      case BookingType.hotel:
        iconData = Icons.hotel_rounded;
        iconBgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1976D2);
        break;
      case BookingType.trip:
        iconData = Icons.explore_rounded;
        iconBgColor = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFF57C00);
        break;
    }

    if (isDark) {
      iconBgColor = iconBgColor.withOpacity(0.15);
      iconColor = iconColor.withOpacity(0.9);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          booking.date,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: booking.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: booking.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.status,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: booking.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (booking.refNumber != null)
                Text(
                  'Ref: ${booking.refNumber}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFF8F9FA),
                  foregroundColor: isDark ? Colors.white : const Color(0xFF2B3A4A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.05),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.green900.withOpacity(0.4)
                      : AppColors.green100.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.green700.withOpacity(0.5)
                        : AppColors.green300.withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.onSurfaceDark.withOpacity(0.6)
                    : AppColors.onSurfaceLight.withOpacity(0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
