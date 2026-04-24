import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';
import 'package:tunisian_trip_planner/features/transport/rental_confirm_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class CarDetailScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const CarDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: Column(
        children: [
          // ── Scrollable content ─────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(context, cs, isDark),
                  const SizedBox(height: 24),
                  _buildTitle(cs),
                  const SizedBox(height: 12),
                  _buildAvailabilityBadge(cs),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 32),

                  // Specifications title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Specifications',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSpecGrid(cs, isDark),

                  // Plate number (if available)
                  if (vehicle.vehiclePlate != null &&
                      vehicle.vehiclePlate!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildPlateRow(cs, isDark),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom price bar ───────────────────────────
          _buildBottomBar(context, cs, isDark),
        ],
      ),
    );
  }

  // ── Hero Image ──────────────────────────────────────────
  Widget _buildHeroImage(BuildContext context, ColorScheme cs, bool isDark) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantD : const Color(0xFFE8EDEA),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/default_transport.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: cs.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Title ───────────────────────────────────────────────
  Widget _buildTitle(ColorScheme cs) {
    final yearStr =
        vehicle.vehicleYear != null ? ' ${vehicle.vehicleYear}' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        '${vehicle.vehicleModel}$yearStr',
        style: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          height: 1.2,
        ),
      ),
    );
  }

  // ── Availability Badge ──────────────────────────────────
  Widget _buildAvailabilityBadge(ColorScheme cs) {
    final available = vehicle.isAvailable;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: available
              ? AppColors.accent.withValues(alpha: 0.3)
              : AppColors.errorColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          available ? 'AVAILABLE' : 'UNAVAILABLE',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: available ? cs.primary : AppColors.errorColor,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  // ── Description ─────────────────────────────────────────
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        _generateDescription(),
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedText,
          height: 1.7,
        ),
      ),
    );
  }

  String _generateDescription() {
    final model = vehicle.vehicleModel;
    final type = vehicle.vehicleType.toLowerCase();
    final fuel = vehicle.fuelTypeLabel.toLowerCase();
    final capacity = vehicle.vehicleCapacity ?? 5;
    final color = vehicle.vehicleColor ?? 'classic';

    return 'Experience the perfect blend of rugged capability and refined luxury. '
        'The $model offers unparalleled comfort with premium leather seating, '
        'advanced navigation, and a commanding presence on both city streets '
        'and desert highways. Ideal for VIP transport or exploring the diverse '
        'landscapes of the Mediterranean. This $color $type features a $fuel '
        'engine and seats up to $capacity passengers.';
  }

  // ── Spec Grid (6 items) ─────────────────────────────────
  Widget _buildSpecGrid(ColorScheme cs, bool isDark) {
    final specs = [
      _SpecItem(
        icon: Icons.people_outline_rounded,
        label: 'CAPACITY',
        value: '${vehicle.vehicleCapacity ?? '—'} Seats',
      ),
      _SpecItem(
        icon: Icons.local_gas_station_outlined,
        label: 'FUEL',
        value: vehicle.fuelTypeLabel,
      ),
      _SpecItem(
        icon: Icons.palette_outlined,
        label: 'COLOR',
        value: vehicle.vehicleColor ?? '—',
      ),
      _SpecItem(
        icon: Icons.directions_car_outlined,
        label: 'TYPE',
        value: vehicle.vehicleType,
      ),
      _SpecItem(
        icon: Icons.calendar_today_outlined,
        label: 'YEAR',
        value: '${vehicle.vehicleYear ?? '—'}',
      ),
      _SpecItem(
        icon: Icons.inventory_2_outlined,
        label: 'IN STOCK',
        value: '${vehicle.quantity ?? '—'} units',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.45,
        ),
        itemCount: specs.length,
        itemBuilder: (context, index) {
          return _buildSpecCard(specs[index], cs, isDark);
        },
      ),
    );
  }

  Widget _buildSpecCard(_SpecItem spec, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.green500.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            spec.icon,
            size: 28,
            color: cs.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            spec.label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            spec.value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Plate Row ───────────────────────────────────────────
  Widget _buildPlateRow(ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.green500.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 22,
              color: cs.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLATE NUMBER',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle.vehiclePlate!,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ──────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.green500.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL PRICE',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${vehicle.vehiclePrice?.toInt() ?? 0}',
                        style: GoogleFonts.dmSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' /day',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: vehicle.isAvailable
                    ? () {
                        navigateTo(
                          context,
                          RentalConfirmScreen(vehicle: vehicle),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.mutedText.withValues(alpha: 0.3),
                  disabledForegroundColor: AppColors.mutedText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  elevation: 0,
                ),
                child: Text(
                  'Book Now',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
