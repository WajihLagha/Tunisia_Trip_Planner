import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/accommodation_detail_screen.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_cubit.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_states.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/accommodation/widgets/hotel_horizontal_card.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class AllAccommodationScreen extends StatelessWidget {
  const AllAccommodationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccommodationCubit(),
      child: const _AllAccommodationView(),
    );
  }
}

class _AllAccommodationView extends StatefulWidget {
  const _AllAccommodationView();

  @override
  State<_AllAccommodationView> createState() => _AllAccommodationViewState();
}

class _AllAccommodationViewState extends State<_AllAccommodationView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      AccommodationCubit.get(context).searchAccommodations(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 46,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantD : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            style: GoogleFonts.dmSans(fontSize: 15, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search hotels, villas, guest houses...',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.mutedText,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedText, size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            ),
          ),
        ),
      ),
      body: BlocBuilder<AccommodationCubit, AccommodationStates>(
        builder: (context, state) {
          // ── Initial / empty query ─────────────────────────────────────────
          if (state is AccommodationInitialState || _controller.text.isEmpty) {
            return _buildEmptyPrompt(cs);
          }

          // ── Searching ─────────────────────────────────────────────────────
          if (state is AccommodationSearchingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green500),
            );
          }

          // ── Error ─────────────────────────────────────────────────────────
          if (state is AccommodationErrorState) {
            return _buildMessage(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              subtitle: state.message,
              cs: cs,
            );
          }

          // ── Search results ────────────────────────────────────────────────
          if (state is AccommodationSearchLoadedState) {
            if (state.filteredAccommodations.isEmpty) {
              return _buildMessage(
                icon: Icons.search_off_rounded,
                title: 'No Results Found',
                subtitle:
                    'We couldn\'t find any accommodations matching\n"${_controller.text}".',
                cs: cs,
              );
            }
            return _buildResultsList(state.filteredAccommodations, isDark, context);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildResultsList(
      List<AccommodationDto> results, bool isDark, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final hotel = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HotelHorizontalCard(
            hotel: hotel,
            onTap: () => navigateTo(
              context,
              AccommodationDetailScreen(accommodation: hotel),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyPrompt(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.green500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hotel_rounded,
                  size: 56, color: AppColors.green500),
            ),
            const SizedBox(height: 24),
            Text(
              'Find Your Perfect Stay',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Search by hotel name, city, or neighbourhood to discover the best accommodations in Tunisia.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.55),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme cs,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.55),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
