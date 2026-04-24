import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';

class RentalConfirmScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const RentalConfirmScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<RentalConfirmScreen> createState() => _RentalConfirmScreenState();
}

class _RentalConfirmScreenState extends State<RentalConfirmScreen> {
  int _rentalDays = 1;
  bool _isUploaded = false;

  double get _totalPrice => (widget.vehicle.vehiclePrice ?? 0) * _rentalDays;

  void _incrementDays() {
    setState(() {
      if (_rentalDays < 30) _rentalDays++;
    });
  }

  void _decrementDays() {
    setState(() {
      if (_rentalDays > 1) _rentalDays--;
    });
  }

  void _simulateUpload() {
    // Simulates a file pick — in production use image_picker / file_picker
    setState(() {
      _isUploaded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Driver\'s license uploaded successfully',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmRental() {
    if (!_isUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload your driver\'s license first',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // TODO: Submit rental via API
    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: cs.primary, size: 28),
              const SizedBox(width: 10),
              Text(
                'Rental Confirmed!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Your ${widget.vehicle.vehicleModel} has been booked for '
            '$_rentalDays day${_rentalDays > 1 ? 's' : ''}.\n\n'
            'Total: \$${_totalPrice.toStringAsFixed(2)}',
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
                Navigator.of(context).pop(); // back to car detail
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      // ── AppBar ─────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: cs.onSurface,
              size: 24,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Confirm Rental',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── License Upload Section ─────────────
                  _buildSectionHeader(
                    icon: Icons.card_membership_outlined,
                    title: 'License Upload',
                    cs: cs,
                  ),
                  const SizedBox(height: 16),
                  _buildLicenseUpload(cs, isDark),

                  const SizedBox(height: 32),

                  // ── Rental Summary Section ─────────────
                  _buildSectionHeader(
                    icon: Icons.event_note_outlined,
                    title: 'Rental Summary',
                    cs: cs,
                  ),
                  const SizedBox(height: 16),
                  _buildRentalSummary(cs, isDark),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── Bottom bar ─────────────────────────────────
          _buildBottomBar(cs, isDark),
        ],
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required ColorScheme cs,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: cs.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  // ── License Upload Area ─────────────────────────────────
  Widget _buildLicenseUpload(ColorScheme cs, bool isDark) {
    return GestureDetector(
      onTap: _simulateUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantD.withValues(alpha: 0.5)
              : AppColors.surfaceVariantL.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isUploaded
                ? cs.primary
                : (isDark ? AppColors.green800 : AppColors.borderColor),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _isUploaded
                ? cs.primary.withValues(alpha: 0.4)
                : (isDark
                    ? AppColors.green700.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.3)),
            borderRadius: 16,
            dashWidth: 8,
            dashGap: 5,
            strokeWidth: 1.5,
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isUploaded
                        ? cs.primary.withValues(alpha: 0.1)
                        : (isDark
                            ? AppColors.green900.withValues(alpha: 0.4)
                            : AppColors.surfaceVariantL),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isUploaded
                        ? Icons.check_circle_outline_rounded
                        : Icons.cloud_upload_outlined,
                    size: 28,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isUploaded
                      ? 'License Uploaded ✓'
                      : 'Upload Driver\'s License',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isUploaded
                      ? 'Tap to replace document'
                      : 'Ensure all details on the document are clearly visible',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.mutedText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Rental Summary Card ─────────────────────────────────
  Widget _buildRentalSummary(ColorScheme cs, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.green500.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle info row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/default_transport.png',
                  width: 60,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.vehicleModel,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.vehicle.vehicleType} • ${widget.vehicle.vehicleYear ?? ''}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: isDark
                ? AppColors.green800.withValues(alpha: 0.3)
                : AppColors.borderColor,
          ),

          const SizedBox(height: 20),

          // Number of days selector
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: cs.primary),
              const SizedBox(width: 10),
              Text(
                'RENTAL DURATION',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceVariantL,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minus
                _buildStepperButton(
                  icon: Icons.remove_rounded,
                  onTap: _decrementDays,
                  cs: cs,
                  isDark: isDark,
                  enabled: _rentalDays > 1,
                ),

                // Day count
                Column(
                  children: [
                    Text(
                      '$_rentalDays',
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      _rentalDays == 1 ? 'day' : 'days',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),

                // Plus
                _buildStepperButton(
                  icon: Icons.add_rounded,
                  onTap: _incrementDays,
                  cs: cs,
                  isDark: isDark,
                  enabled: _rentalDays < 30,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: isDark
                ? AppColors.green800.withValues(alpha: 0.3)
                : AppColors.borderColor,
          ),

          const SizedBox(height: 20),

          // Price breakdown
          _buildPriceRow(
            'Price per day',
            '\$${widget.vehicle.vehiclePrice?.toStringAsFixed(2) ?? '0.00'}',
            cs,
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Duration',
            '$_rentalDays day${_rentalDays > 1 ? 's' : ''}',
            cs,
            isBold: false,
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: isDark
                ? AppColors.green800.withValues(alpha: 0.3)
                : AppColors.borderColor,
          ),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                ),
              ),
              Row(
                children: [
                  Text(
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Small car icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.green900.withValues(alpha: 0.4)
                          : AppColors.surfaceVariantL,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_outlined,
                      size: 18,
                      color: cs.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme cs,
    required bool isDark,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? cs.primary
              : (isDark
                  ? AppColors.surfaceVariantD
                  : AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.white : AppColors.mutedText,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, ColorScheme cs,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.mutedText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  // ── Bottom Bar ──────────────────────────────────────────
  Widget _buildBottomBar(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
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
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.mutedText.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Your data is secured with 256-bit encryption',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.mutedText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmRental,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm Rental',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed border painter ──────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final len = dashWidth.clamp(0, metric.length - distance);
        result.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
        distance += dashWidth + dashGap;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
