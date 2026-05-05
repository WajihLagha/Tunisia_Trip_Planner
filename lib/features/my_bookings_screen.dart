import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────────────────────────────────────
enum BookingType { car, hotel, trip }

class BookingModel {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final BookingType type;
  final String refNumber;

  const BookingModel({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.type,
    required this.refNumber,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hardcoded test data  (no nulls anywhere)
// ─────────────────────────────────────────────────────────────────────────────
const List<BookingModel> _mockBookings = [
  BookingModel(
    title: 'Car Rental – Clio',
    date: '12 Oct, 10:00 AM',
    status: 'PENDING',
    statusColor: Color(0xFFFF9800),
    type: BookingType.car,
    refNumber: '#TR-88291',
  ),
  BookingModel(
    title: 'Hotel Majestic Tunis',
    date: '12 Oct – 15 Oct',
    status: 'CONFIRMED',
    statusColor: Color(0xFF4CAF50),
    type: BookingType.hotel,
    refNumber: '#HT-12345',
  ),
  BookingModel(
    title: 'Sahara Desert Trip',
    date: '20 Nov – 22 Nov',
    status: 'CANCELLED',
    statusColor: Color(0xFFF44336),
    type: BookingType.trip,
    refNumber: '#TR-99120',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────
class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  int _selectedIndex = 0;

  List<BookingModel> get _filtered {
    switch (_selectedIndex) {
      case 0:
        return _mockBookings
            .where((b) => b.status == 'PENDING' || b.status == 'CONFIRMED')
            .toList();
      case 1:
        return _mockBookings.where((b) => b.status == 'CONFIRMED').toList();
      case 2:
        return _mockBookings.where((b) => b.status == 'CANCELLED').toList();
      default:
        return List<BookingModel>.from(_mockBookings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookings = _filtered;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.onSurfaceLight,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Bookings',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.onSurfaceLight,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // ── Segmented tab bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantD
                    : const Color(0xFFF0F4F3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  _TabPill(
                    label: 'Upcoming',
                    selected: _selectedIndex == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _TabPill(
                    label: 'Completed',
                    selected: _selectedIndex == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _TabPill(
                    label: 'Cancelled',
                    selected: _selectedIndex == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Content area ──────────────────────────────────────────────────
          Expanded(
            child: bookings.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        _BookingCard(booking: bookings[i], isDark: isDark),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tab pill widget
// ─────────────────────────────────────────────────────────────────────────────
class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF00E6C3) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E6C3).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.black87
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Booking card widget  (all colors inlined – zero nullable risk)
// ─────────────────────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;

  const _BookingCard({required this.booking, required this.isDark});

  // Resolve icon + colors per booking type without any nullable fields
  _IconMeta get _iconMeta {
    switch (booking.type) {
      case BookingType.car:
        return _IconMeta(
          icon: Icons.directions_car_rounded,
          bg: isDark ? const Color(0x2600796B) : const Color(0xFFD9FBF5),
          fg: isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B),
        );
      case BookingType.hotel:
        return _IconMeta(
          icon: Icons.hotel_rounded,
          bg: isDark ? const Color(0x261565C0) : const Color(0xFFE3F2FD),
          fg: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2),
        );
      case BookingType.trip:
        return _IconMeta(
          icon: Icons.explore_rounded,
          bg: isDark ? const Color(0x26E65100) : const Color(0xFFFFF3E0),
          fg: isDark ? const Color(0xFFFFCC80) : const Color(0xFFF57C00),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _iconMeta;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2A4440) : const Color(0xFFF0F0F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon bubble
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: meta.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(meta.icon, color: meta.fg, size: 26),
              ),
              const SizedBox(width: 14),
              // Title + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            booking.date,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.mutedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: booking.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: booking.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      booking.status,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: booking.statusColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A4440) : const Color(0xFFEEEEEE),
          ),
          const SizedBox(height: 14),
          // ── Footer ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ref: ${booking.refNumber}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.green900.withValues(alpha: 0.4)
                        : AppColors.green100.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.green300 : AppColors.green700,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Helper data class for icon metadata
// ─────────────────────────────────────────────────────────────────────────────
class _IconMeta {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _IconMeta({required this.icon, required this.bg, required this.fg});
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.green900.withValues(alpha: 0.4)
                    : AppColors.green100.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.green700.withValues(alpha: 0.5)
                      : AppColors.green300.withValues(alpha: 0.8),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('📅', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Bookings Yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "You don't have any bookings\nin this category.",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.6),
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
