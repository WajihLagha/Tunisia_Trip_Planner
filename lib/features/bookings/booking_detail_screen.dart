import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_cubit.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_cubit.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_states.dart';
import 'package:tunisian_trip_planner/features/bookings/enums/booking_state.dart' as model_state;
import 'package:tunisian_trip_planner/shared/widgets/components.dart';

/// Booking data passed from the list — avoids re-fetching.
class BookingDetailArgs {
  final String id;
  final String title;
  final String refNumber;
  final String date;
  final String status;
  final Color statusColor;
  final num? amount;
  final model_state.BookingState? state;

  const BookingDetailArgs({
    required this.id,
    required this.title,
    required this.refNumber,
    required this.date,
    required this.status,
    required this.statusColor,
    this.amount,
    this.state,
  });
}

class BookingDetailScreen extends StatelessWidget {
  final BookingDetailArgs booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCancel = booking.state == model_state.BookingState.pending ||
        booking.state == model_state.BookingState.confirmed;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
          'Booking Details',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.onSurfaceLight,
          ),
        ),
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingActionSuccess) {
            showToast(msg: state.message, state: ToastStates.success);
            Navigator.pop(context);
          }
          if (state is BookingActionError) {
            showToast(msg: state.error, state: ToastStates.error);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status card ──────────────────────────────────────────
              _InfoCard(
                isDark: isDark,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: booking.statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        booking.status == 'CONFIRMED'
                            ? Icons.check_circle_outline_rounded
                            : booking.status == 'CANCELLED'
                                ? Icons.cancel_outlined
                                : Icons.schedule_rounded,
                        color: booking.statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Status',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              booking.status,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: booking.statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Details card ─────────────────────────────────────────
              _InfoCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Information',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Type',
                      value: booking.title,
                      isDark: isDark,
                    ),
                    _DetailRow(
                      label: 'Reference',
                      value: booking.refNumber,
                      isDark: isDark,
                    ),
                    _DetailRow(
                      label: 'Date',
                      value: booking.date,
                      isDark: isDark,
                    ),
                    if (booking.amount != null)
                      _DetailRow(
                        label: 'Amount',
                        value: '\$${booking.amount!.toStringAsFixed(2)}',
                        isDark: isDark,
                        isLast: true,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Cancel button ────────────────────────────────────────
              if (canCancel)
                BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, state) {
                    final isLoading = state is BookingActionLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => _confirmCancel(context),
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.errorColor,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined,
                                color: AppColors.errorColor),
                        label: Text(
                          isLoading ? 'Cancelling...' : 'Cancel Booking',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.errorColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel Booking?',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final userId = AuthCubit.get(context).currentUserId;
              if (userId != null) {
                BookingCubit.get(context).cancelBooking(userId, booking.id);
              }
            },
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.dmSans(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _InfoCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.mutedText,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color:
                isDark ? const Color(0xFF2A4440) : const Color(0xFFEEEEEE),
          ),
      ],
    );
  }
}
