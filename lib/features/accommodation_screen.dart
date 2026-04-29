import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_cubit.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_states.dart';
import 'package:tunisian_trip_planner/features/accommodation/enums/accommodation_type.dart';
import 'package:tunisian_trip_planner/features/accommodation/widgets/accommodation_filter_sheet.dart';
import 'package:tunisian_trip_planner/features/accommodation/widgets/hotel_horizontal_card.dart';
import 'package:tunisian_trip_planner/features/accommodation/widgets/stacked_room_carousel.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';
import 'package:tunisian_trip_planner/features/accommodation/accommodation_detail_screen.dart';

class AccommodationScreen extends StatelessWidget {
  const AccommodationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccommodationCubit()..loadAccommodations(),
      child: const _AccommodationView(),
    );
  }
}

class _AccommodationView extends StatelessWidget {
  const _AccommodationView();

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccommodationFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: BlocBuilder<AccommodationCubit, AccommodationStates>(
        builder: (context, state) {
          final cubit = AccommodationCubit.get(context);

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context, isDark, cs),
              ),

              // Search Bar & Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantD : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search accommodations...',
                              hintStyle: GoogleFonts.dmSans(
                                color: AppColors.mutedText,
                              ),
                              prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            style: GoogleFonts.dmSans(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _openFilterSheet(context),
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: AppColors.green500,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.green500.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Accommodation Type Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: AccommodationType.values.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final type = isAll ? null : AccommodationType.values[index - 1];
                      final isSelected = cubit.selectedType == type;
                      final label = isAll
                          ? 'All'
                          : type!.name[0].toUpperCase() + type.name.substring(1);

                      return GestureDetector(
                        onTap: () => cubit.filterByType(type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.green500
                                : (isDark ? AppColors.surfaceVariantD : Colors.white),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green500
                                  : (isDark ? AppColors.surfaceVariantD : AppColors.borderColor),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Content based on state
              if (state is AccommodationLoadingState)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.green500)),
                )
              else if (state is AccommodationLoadedState) ...[
                // Most Rated Rooms Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Most Rated Rooms',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: StackedRoomCarousel(rooms: cubit.topRooms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Top Rated Hotels Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Rated Hotels',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                          ),
                        ),
                        Text(
                          'See all',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 280,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 24, right: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.filteredAccommodations.length,
                      itemBuilder: (context, index) {
                        final hotel = state.filteredAccommodations[index];
                        return HotelHorizontalCard(
                          hotel: hotel,
                          onTap: () {
                            navigateTo(
                              context,
                              AccommodationDetailScreen(accommodation: hotel),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ] else if (state is AccommodationErrorState)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.dmSans(
                        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                      ),
                    ),
                  ),
                )
              else
                const SliverFillRemaining(child: SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, ColorScheme cs) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.green950,
                  AppColors.green900,
                  AppColors.surfaceDark,
                ]
              : [
                  AppColors.green950,
                  AppColors.green800,
                  AppColors.green700,
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your\nPerfect Stay',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover luxury hotels, cozy villas, and everything in between.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
