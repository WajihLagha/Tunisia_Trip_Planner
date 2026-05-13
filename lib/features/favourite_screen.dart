import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/data/mock_accommodation_data.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_cubit.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_states.dart';
import 'package:tunisian_trip_planner/features/places/data/mock_places_data.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';
import 'package:tunisian_trip_planner/features/places/screens/place_details_screen.dart';
import 'package:tunisian_trip_planner/features/accommodation/accommodation_detail_screen.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_cubit.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_states.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_cubit.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_states.dart';
import 'package:tunisian_trip_planner/features/home_layout/cubit/home_cubit.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PlacesCubit()..loadPlaces()),
        BlocProvider(create: (_) => AccommodationCubit()..loadAccommodations()),
      ],
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'My Favourites',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            body: BlocBuilder<FavouritesCubit, FavouritesStates>(
              builder: (context, state) {
                if (state is! FavouritesLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final placesState = context.watch<PlacesCubit>().state;
                final allPlaces = {
                  ...MockPlacesData.places,
                  if (placesState is PlacesLoadedState) ...placesState.places,
                };

                final favPlaces =
                    allPlaces
                        .where((p) => state.favouritePlaceIds.contains(p.id))
                        .toList();

                final accommodationState =
                    context.watch<AccommodationCubit>().state;
                final allAccoms = {
                  ...MockAccommodationData.accommodations,
                  if (accommodationState is AccommodationLoadedState)
                    ...accommodationState.accommodations,
                };

                final favAccoms =
                    allAccoms
                        .where(
                          (a) => state.favouriteAccommodationIds.contains(
                            a.id.toString(),
                          ),
                        )
                        .toList();

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    // Segmented Control
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.surfaceVariantD : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTab(0, 'Places', isDark),
                            _buildTab(1, 'Stays', isDark),
                            _buildTab(2, 'Transport', isDark),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tab Content
                    Expanded(
                      child: _buildSelectedTab(
                        favPlaces,
                        favAccoms,
                        isDark,
                        state,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
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
                color:
                    isSelected
                        ? Colors.black87
                        : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTab(
    List<PlacesResponse> places,
    List<AccommodationDto> accoms,
    bool isDark,
    FavouritesLoaded state,
  ) {
    if (_selectedIndex == 0) {
      return _PlacesTab(places: places, isDark: isDark, state: state);
    } else if (_selectedIndex == 1) {
      return _StaysTab(accommodations: accoms, isDark: isDark, state: state);
    } else {
      return _TransportTab(isDark: isDark);
    }
  }
}

// ── Places Tab ─────────────────────────────────────────────────────────────────
class _PlacesTab extends StatelessWidget {
  final List<PlacesResponse> places;
  final bool isDark;
  final FavouritesLoaded state;

  const _PlacesTab({
    required this.places,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return _EmptyState(
        icon: '🗺️',
        title: 'No Favourite Places Yet',
        subtitle:
            'Explore Tunisia and tap the heart icon on any place to save it here.',
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _FavPlaceCard(
          place: place,
          isDark: isDark,
          onTap: () => navigateTo(context, PlaceDetailsScreen(place: place)),
          onRemove:
              () => FavouritesCubit.get(
                context,
              ).togglePlaceFavourite(place.id ?? ''),
        );
      },
    );
  }
}

// ── Stays Tab ──────────────────────────────────────────────────────────────────
class _StaysTab extends StatelessWidget {
  final List<AccommodationDto> accommodations;
  final bool isDark;
  final FavouritesLoaded state;

  const _StaysTab({
    required this.accommodations,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (accommodations.isEmpty) {
      return _EmptyState(
        icon: '🏨',
        title: 'No Favourite Stays Yet',
        subtitle:
            'Find the perfect hotel or villa and save it here for your next trip.',
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: accommodations.length,
      itemBuilder: (context, index) {
        final accom = accommodations[index];
        return _FavStayCard(
          accommodation: accom,
          isDark: isDark,
          onTap:
              () => navigateTo(
                context,
                AccommodationDetailScreen(accommodation: accom),
              ),
          onRemove:
              () => FavouritesCubit.get(
                context,
              ).toggleAccommodationFavourite(accom.id.toString()),
        );
      },
    );
  }
}

// ── Transport Tab ──────────────────────────────────────────────────────────────
class _TransportTab extends StatelessWidget {
  final bool isDark;
  const _TransportTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: '🚗',
      title: 'No Favourite Transport Yet',
      subtitle:
          'Browse transport agencies and save your preferred travel options here.',
      isDark: isDark,
    );
  }
}

// ── Creative Empty State ───────────────────────────────────────────────────────
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
            // Animated pulsing icon container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.05),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder:
                  (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.green900.withValues(alpha: 0.4)
                          : AppColors.green100.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isDark
                            ? AppColors.green700.withValues(alpha: 0.5)
                            : AppColors.green300.withValues(alpha: 0.8),
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
                color:
                    isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color:
                    isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                // Navigate back and switch to Explore tab in HomeLayout
                Navigator.pop(context);
                final homeCubit = HomeCubit.get(context);
                homeCubit.changeTripNavBar(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green600, AppColors.green400],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green500.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Exploring',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
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

// ── Favourite Place Card ───────────────────────────────────────────────────────
class _FavPlaceCard extends StatelessWidget {
  final PlacesResponse place;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavPlaceCard({
    required this.place,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: _buildImage(place.mainImageUrl, 100, 100),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name ?? 'Unknown',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.green500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${place.cityName}, ${place.stateName}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${place.rating?.toStringAsFixed(1)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? AppColors.onSurfaceDark
                                        : AppColors.onSurfaceLight,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ── Favourite Stay Card ────────────────────────────────────────────────────────
class _FavStayCard extends StatelessWidget {
  final AccommodationDto accommodation;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavStayCard({
    required this.accommodation,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl =
        accommodation.images?.isNotEmpty == true
            ? accommodation.images!.first.imageUrl
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: _buildImage(imgUrl, 100, 100),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accommodation.name ?? 'Unknown',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.green500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${accommodation.city}, ${accommodation.state}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${accommodation.priceMin?.toStringAsFixed(0)} / night',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green500,
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ── Shared Image Helper ────────────────────────────────────────────────────────
Widget _buildImage(String? url, double w, double h) {
  if (url == null) {
    return Container(
      width: w,
      height: h,
      color: AppColors.green800,
      child: const Icon(Icons.image_rounded, color: Colors.white30),
    );
  }
  if (url.startsWith('assets/')) {
    return Image.asset(
      url,
      width: w,
      height: h,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            width: w,
            height: h,
            color: AppColors.green800,
            child: const Icon(Icons.image_rounded, color: Colors.white30),
          ),
    );
  }
  return Container(
    width: w,
    height: h,
    color: AppColors.green800,
    child: const Icon(Icons.image_rounded, color: Colors.white30),
  );
}
