import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_cubit.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_cubit.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_states.dart';
import 'package:tunisian_trip_planner/features/bookings/models/booking_request.dart';
import 'package:tunisian_trip_planner/features/bookings/enums/payment_method.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomDto room;

  /// Optional parent hotel — shown in the header. Can be null when navigating
  /// from the global carousel where the parent is not easily available.
  final AccommodationDto? accommodation;

  const RoomDetailScreen({super.key, required this.room, this.accommodation});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _nights = 1;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.stripe;

  RoomDto get room => widget.room;
  AccommodationDto? get hotel => widget.accommodation;

  double get _total => (room.price ?? 0) * _nights;

  String get _roomImagePath {
    final url =
        room.images?.isNotEmpty == true ? room.images!.first.imageUrl : null;
    return (url != null && url.isNotEmpty)
        ? url
        : 'assets/images/default_room.jpg';
  }

  String get _roomTypeName {
    switch (room.type?.name) {
      case 'suite':
        return 'Suite';
      case 'double':
        return 'Double';
      case 'single':
        return 'Single';
      case 'family':
        return 'Family';
      default:
        return 'Standard';
    }
  }

  IconData get _roomTypeIcon {
    switch (room.type?.name) {
      case 'suite':
        return Icons.star_rounded;
      case 'family':
        return Icons.family_restroom_rounded;
      case 'single':
        return Icons.single_bed_rounded;
      default:
        return Icons.bed_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingActionSuccess) {
            showDialog(
              context: context,
              builder: (ctx) {
                final cs = Theme.of(ctx).colorScheme;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: cs.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Booking Confirmed!',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Your room has been booked for '
                    '$_nights night${_nights > 1 ? 's' : ''}.\n\n'
                    'Total: \$${_total.toStringAsFixed(2)}\n'
                    'Ref: #${state.booking.id?.substring(0, 8) ?? ''}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop(); // back to hotel detail
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (state is BookingActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, style: GoogleFonts.dmSans()),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(context, cs, isDark),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleSection(cs, isDark),
                                const SizedBox(height: 24),
                                _buildInfoChips(cs, isDark),
                                const SizedBox(height: 28),
                                _buildAvailabilityBanner(cs, isDark),
                                const SizedBox(height: 28),
                                _buildAmenitiesSection(cs, isDark),
                                const SizedBox(height: 28),
                                _buildNightSelector(cs, isDark),
                                const SizedBox(height: 28),
                                if (hotel != null)
                                  _buildHotelReference(cs, isDark),
                                if (hotel != null) const SizedBox(height: 28),
                                _buildPaymentMethodSection(cs, isDark),
                                const SizedBox(height: 28),
                                _buildPriceSummary(cs, isDark),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBottomBar(context, cs, isDark),
                ],
              ),
              if (state is BookingActionLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Sliver App Bar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context, ColorScheme cs, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.green700,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _roomImagePath,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Image.asset(
                    'assets/images/default_room.jpg',
                    fit: BoxFit.cover,
                  ),
            ),
            // Bottom gradient for text readability
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Room type badge
            Positioned(
              bottom: 60,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_roomTypeIcon, color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      _roomTypeName.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Room name
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                room.description ?? 'Standard Room',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title Section ─────────────────────────────────────────────────────────
  Widget _buildTitleSection(ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.description ?? 'Standard Room',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color:
                        isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                if (hotel != null)
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 14,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          hotel!.name ?? '',
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${room.price?.round() ?? 0}',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
              Text(
                'per night',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info Chips ────────────────────────────────────────────────────────────
  Widget _buildInfoChips(ColorScheme cs, bool isDark) {
    final chipBg =
        isDark
            ? AppColors.green900.withValues(alpha: 0.4)
            : AppColors.green100.withValues(alpha: 0.6);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Chip(
          icon: Icons.people_outline_rounded,
          label: '${room.capacity ?? 2} Guests',
          bg: chipBg,
          color: cs.primary,
        ),
        _Chip(
          icon: _roomTypeIcon,
          label: _roomTypeName,
          bg: chipBg,
          color: cs.primary,
        ),
        _Chip(
          icon: Icons.inventory_2_outlined,
          label: '${room.roomQuantity ?? 1} Total',
          bg: chipBg,
          color: cs.primary,
        ),
        _Chip(
          icon: Icons.king_bed_rounded,
          label: '1 King Bed',
          bg: chipBg,
          color: cs.primary,
        ),
      ],
    );
  }

  // ── Availability Banner ───────────────────────────────────────────────────
  Widget _buildAvailabilityBanner(ColorScheme cs, bool isDark) {
    final available = room.availableRooms ?? 0;
    final isLow = available > 0 && available <= 2;
    final isNone = available == 0;

    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (isNone) {
      bgColor = Colors.red.withValues(alpha: 0.12);
      textColor = Colors.red.shade700;
      icon = Icons.do_not_disturb_on_rounded;
      label = 'Fully Booked';
    } else if (isLow) {
      bgColor = Colors.orange.withValues(alpha: 0.12);
      textColor = Colors.orange.shade700;
      icon = Icons.warning_amber_rounded;
      label =
          'Only $available room${available > 1 ? 's' : ''} left — book soon!';
    } else {
      bgColor = Colors.green.withValues(alpha: 0.12);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline_rounded;
      label = '$available rooms available';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Amenities Section ─────────────────────────────────────────────────────
  Widget _buildAmenitiesSection(ColorScheme cs, bool isDark) {
    final amenities = [
      _Amenity(Icons.wifi_rounded, 'Free Wi-Fi'),
      _Amenity(Icons.air_rounded, 'Air Conditioning'),
      _Amenity(Icons.tv_rounded, 'Smart TV'),
      _Amenity(Icons.local_parking_rounded, 'Free Parking'),
      _Amenity(Icons.breakfast_dining_rounded, 'Breakfast'),
      _Amenity(Icons.pool_rounded, 'Pool Access'),
      _Amenity(Icons.room_service_rounded, 'Room Service'),
      _Amenity(Icons.spa_rounded, 'Spa Access'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: amenities.length,
          itemBuilder: (_, i) {
            final a = amenities[i];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.green900.withValues(alpha: 0.35)
                            : AppColors.green100.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(a.icon, size: 24, color: cs.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  a.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Night Selector ────────────────────────────────────────────────────────
  Widget _buildNightSelector(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many nights?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus
              _StepButton(
                icon: Icons.remove_rounded,
                enabled: _nights > 1,
                cs: cs,
                isDark: isDark,
                onTap:
                    () => setState(() {
                      if (_nights > 1) _nights--;
                    }),
              ),
              Column(
                children: [
                  Text(
                    '$_nights',
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                    ),
                  ),
                  Text(
                    _nights == 1 ? 'night' : 'nights',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
              // Plus
              _StepButton(
                icon: Icons.add_rounded,
                enabled: _nights < 30,
                cs: cs,
                isDark: isDark,
                onTap:
                    () => setState(() {
                      if (_nights < 30) _nights++;
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Hotel Reference ───────────────────────────────────────────────────────
  Widget _buildHotelReference(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              (hotel!.images?.isNotEmpty == true
                      ? hotel!.images!.first.imageUrl
                      : null) ??
                  'assets/images/default_hotel.jpg',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Image.asset(
                    'assets/images/default_hotel.jpg',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel!.name ?? '',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.green500,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${hotel!.city ?? ''}, ${hotel!.state ?? ''}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
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
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: Color(0xFFF5A623),
              ),
              const SizedBox(width: 3),
              Text(
                '${hotel!.rating ?? 0.0}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Payment Method Section ────────────────────────────────────────────────
  Widget _buildPaymentMethodSection(ColorScheme cs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                title: 'Stripe',
                icon: Icons.credit_card_rounded,
                method: PaymentMethod.stripe,
                cs: cs,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPaymentOption(
                title: 'Cash',
                icon: Icons.money_rounded,
                method: PaymentMethod.cash,
                cs: cs,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required PaymentMethod method,
    required ColorScheme cs,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? cs.primary.withValues(alpha: 0.1)
                  : (isDark
                      ? AppColors.surfaceVariantD
                      : AppColors.surfaceVariantL),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? cs.primary : AppColors.mutedText),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected
                        ? cs.primary
                        : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Price Summary ─────────────────────────────────────────────────────────
  Widget _buildPriceSummary(ColorScheme cs, bool isDark) {
    final pricePerNight = room.price ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Price per night',
            value: '\$${pricePerNight.round()}',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Duration',
            value: '$_nights night${_nights > 1 ? 's' : ''}',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                ),
              ),
              Text(
                '\$${_total.round()}',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, ColorScheme cs, bool isDark) {
    final isAvailable = (room.availableRooms ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : AppColors.green500.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${_total.round()}',
                          style: GoogleFonts.dmSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                          ),
                        ),
                        TextSpan(
                          text: ' / $_nights night${_nights > 1 ? 's' : ''}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed:
                  isAvailable
                      ? () {
                        final userId = AuthCubit.get(context).currentUserId;
                        if (userId != null) {
                          final request = BookingRequest(
                            accommodationId: '3',
                            amount: _total.round(),
                            paymentMethod: _selectedPaymentMethod,
                          );
                          if (_selectedPaymentMethod == PaymentMethod.stripe) {
                            BookingCubit.get(
                              context,
                            ).createBookingAndPay(userId, request);
                          } else {
                            BookingCubit.get(
                              context,
                            ).createBooking(userId, request);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You must be logged in to book.',
                                style: GoogleFonts.dmSans(),
                              ),
                              backgroundColor: AppColors.errorColor,
                            ),
                          );
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mutedText.withValues(
                  alpha: 0.3,
                ),
                minimumSize: const Size(140, 52),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isAvailable ? 'Book Now' : 'Unavailable',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _Amenity {
  final IconData icon;
  final String label;
  const _Amenity(this.icon, this.label);
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color color;
  const _Chip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final ColorScheme cs;
  final bool isDark;
  final VoidCallback onTap;
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.cs,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color:
              enabled
                  ? cs.primary
                  : (isDark
                      ? AppColors.surfaceVariantD
                      : AppColors.borderColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.white : AppColors.mutedText,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _PriceRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.mutedText),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
      ],
    );
  }
}
