import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/transport/car_detail_screen.dart';
import 'package:tunisian_trip_planner/features/transport/all_fleet_screen.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_model.dart';
import 'package:tunisian_trip_planner/features/transport/widgets/vehicle_card.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';
import 'package:tunisian_trip_planner/features/reviews/widgets/reviews_section.dart';
import 'package:tunisian_trip_planner/features/reviews/models/review_target_type.dart';
import 'package:tunisian_trip_planner/shared/widgets/place_image_widget.dart';

class TransportDetailScreen extends StatelessWidget {
  final TransportModel transport;

  const TransportDetailScreen({
    super.key,
    required this.transport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image + Back Button ─────────────────
            _buildHeroSection(context, cs, isDark),

            // ── Agency Info Card (overlapping) ───────────
            _buildInfoCard(context, cs, isDark),

            // ── About Section ────────────────────────────
            _buildAboutSection(cs),

            // ── Our Fleet Section ────────────────────────
            if (transport.vehicles.isNotEmpty)
              _buildFleetSection(context, cs, isDark),
            // ── Reviews ────────────────────────────────────────
            ReviewsSection(
              targetId: transport.id.toString(),
              targetType: ReviewTargetType.transport,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Hero Image with Back Button ──────────────────────────
  Widget _buildHeroSection(
      BuildContext context, ColorScheme cs, bool isDark) {
    return Stack(
      children: [
        // Background image
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PlaceImageWidget(
            imageUrl: transport.imageUrl ?? 'assets/images/default_transport.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        // Agency name overlay on image
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              transport.name.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 3.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Back button — transparent circular container with themed arrow
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

  // ── Info Card (overlapping the hero image) ────────────────
  Widget _buildInfoCard(
      BuildContext context, ColorScheme cs, bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.green500.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agency Name
            Text(
              transport.name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Rating
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: Color(0xFFF5A623),
                ),
                const SizedBox(width: 4),
                Text(
                  transport.averageRating.toString(),
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${transport.totalReviews} reviews)',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Verified Partner badge
            if (transport.stripeOnboarded)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'VERIFIED PARTNER',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

            if (transport.stripeOnboarded) const SizedBox(height: 16),

            // Contact buttons row
            // Contact info rows
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transport.contactPhone != null && transport.contactPhone!.isNotEmpty)
                  _buildContactRow(
                    context: context,
                    icon: Icons.phone_outlined,
                    label: 'PHONE',
                    value: transport.contactPhone!,
                    cs: cs,
                    isDark: isDark,
                  ),
                if (transport.contactEmail != null && transport.contactEmail!.isNotEmpty)
                  _buildContactRow(
                    context: context,
                    icon: Icons.email_outlined,
                    label: 'EMAIL',
                    value: transport.contactEmail!,
                    cs: cs,
                    isDark: isDark,
                  ),
                if (transport.address != null && transport.address!.isNotEmpty)
                  _buildContactRow(
                    context: context,
                    icon: Icons.location_on_outlined,
                    label: 'ADDRESS',
                    value: transport.address!,
                    cs: cs,
                    isDark: isDark,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied to clipboard'),
            duration: const Duration(seconds: 2),
            backgroundColor: cs.primary,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.green900.withValues(alpha: 0.5)
                    : AppColors.surfaceVariantL,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.green800.withValues(alpha: 0.5)
                      : AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.copy_rounded, size: 16, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }

  // ── About Section ────────────────────────────────────────
  Widget _buildAboutSection(ColorScheme cs) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About the Agency',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              transport.description ?? 'No description available.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.mutedText,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fleet Section ────────────────────────────────────────
  Widget _buildFleetSection(BuildContext context, ColorScheme cs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Our Fleet',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  navigateTo(context, AllFleetScreen(transport: transport));
                },
                child: Row(
                  children: [
                    Text(
                      'VIEW ALL',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: cs.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal vehicle list
        SizedBox(
          height: 245,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: transport.vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final v = transport.vehicles[index];
              return VehicleCard(
                vehicle: v,
                onTap: () {
                  navigateTo(
                    context,
                    CarDetailScreen(vehicle: v),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
