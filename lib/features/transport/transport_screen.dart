import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/constants/tunisian_cities.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/transport/cubit/transport_cubit.dart';
import 'package:tunisian_trip_planner/features/transport/cubit/transport_states.dart';
import 'package:tunisian_trip_planner/features/transport/transport_detail_screen.dart';
import 'package:tunisian_trip_planner/features/transport/widgets/transport_card.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransportCubit()..loadTransports(),
      child: const _TransportView(),
    );
  }
}

class _TransportView extends StatelessWidget {
  const _TransportView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<TransportCubit, TransportStates>(
        builder: (context, state) {
          final cubit = TransportCubit.get(context);

          return CustomScrollView(
            slivers: [
              // ── Header Section ─────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeader(context, isDark, cs),
              ),

              // ── Pinned City Chips ──────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _CityChipsDelegate(
                  selectedCity: cubit.selectedCity,
                  onCitySelected: (city) => cubit.filterByCity(city),
                  isDark: isDark,
                  cs: cs,
                ),
              ),

              // ── Content ────────────────────────────────────
              if (state is TransportLoadingState)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is TransportLoadedState)
                state.transports.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(cs),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return TransportCard(
                                transport: state.transports[index],
                                onTap: () {
                                  navigateTo(
                                    context,
                                    TransportDetailScreen(
                                      transport: state.transports[index],
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: state.transports.length,
                          ),
                        ),
                      )
              else if (state is TransportErrorState)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.message,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                  child: SizedBox.shrink(),
                ),
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
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover\nAgencies',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find the perfect travel partner for your\nnext adventure.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: cs.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No agencies found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different city',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Persistent Header Delegate for Pinned City Chips ─────────
class _CityChipsDelegate extends SliverPersistentHeaderDelegate {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;
  final bool isDark;
  final ColorScheme cs;

  _CityChipsDelegate({
    required this.selectedCity,
    required this.onCitySelected,
    required this.isDark,
    required this.cs,
  });

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  bool shouldRebuild(covariant _CityChipsDelegate oldDelegate) {
    return oldDelegate.selectedCity != selectedCity ||
        oldDelegate.isDark != isDark;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isScrolled = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppColors.green500.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: tunisianCities.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = index == 0 ? 'All' : tunisianCities[index - 1];
          final isSelected = city == selectedCity;

          return GestureDetector(
            onTap: () => onCitySelected(city),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.green700 : AppColors.green950)
                    : (isDark
                        ? AppColors.surfaceVariantD
                        : AppColors.surfaceVariantL),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                          ? AppColors.green800.withValues(alpha: 0.4)
                          : AppColors.borderColor),
                  width: 1,
                ),
              ),
              child: Text(
                city,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                          : AppColors.onSurfaceLight.withValues(alpha: 0.7)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}