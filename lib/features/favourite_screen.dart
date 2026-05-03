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

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavouritesCubit()..loadFavourites(),
      child: const _FavouriteView(),
    );
  }
}

class _FavouriteView extends StatelessWidget {
  const _FavouriteView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor:
                  isDark ? AppColors.green950 : AppColors.green700,
              expandedHeight: 130,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeader(isDark),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle:
                      GoogleFonts.dmSans(fontWeight: FontWeight.w400),
                  tabs: const [
                    Tab(icon: Icon(Icons.place_rounded, size: 18), text: 'Places'),
                    Tab(icon: Icon(Icons.hotel_rounded, size: 18), text: 'Stays'),
                    Tab(icon: Icon(Icons.directions_car_rounded, size: 18), text: 'Transport'),
                  ],
                ),
              ),
            ),
          ],
          body: BlocBuilder<FavouritesCubit, FavouritesStates>(
            builder: (context, state) {
              if (state is! FavouritesLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final favPlaces = MockPlacesData.places
                  .where((p) =>
                      state.favouritePlaceIds.contains(p.id))
                  .toList();

              final favAccoms = MockAccommodationData.accommodations
                  .where((a) =>
                      state.favouriteAccommodationIds.contains(a.id.toString()))
                  .toList();

              return TabBarView(
                children: [
                  _PlacesTab(
                      places: favPlaces, isDark: isDark, state: state),
                  _StaysTab(
                      accommodations: favAccoms, isDark: isDark, state: state),
                  _TransportTab(isDark: isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.green950, AppColors.green900]
              : [AppColors.green800, AppColors.green600],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Favourites',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All the places you love, in one spot',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Places Tab ─────────────────────────────────────────────────────────────────
class _PlacesTab extends StatelessWidget {
  final List<PlacesResponse> places;
  final bool isDark;
  final FavouritesLoaded state;

  const _PlacesTab(
      {required this.places, required this.isDark, required this.state});

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
          onRemove: () =>
              FavouritesCubit.get(context)
                  .togglePlaceFavourite(place.id ?? ''),
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

  const _StaysTab(
      {required this.accommodations, required this.isDark, required this.state});

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
          onTap: () =>
              navigateTo(context, AccommodationDetailScreen(accommodation: accom)),
          onRemove: () =>
              FavouritesCubit.get(context)
                  .toggleAccommodationFavourite(accom.id.toString()),
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
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
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
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  const Icon(Icons.explore_rounded,
                      color: Colors.white, size: 18),
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
                  left: Radius.circular(20)),
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
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.green500),
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
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFFFC107)),
                            const SizedBox(width: 3),
                            Text(
                              '${place.rating?.toStringAsFixed(1)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
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
                            child: const Icon(Icons.favorite_rounded,
                                size: 16, color: Colors.red),
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
    final imgUrl = accommodation.images?.isNotEmpty == true
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
                  left: Radius.circular(20)),
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
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.green500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${accommodation.city}, ${accommodation.state}',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: AppColors.mutedText),
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
                            child: const Icon(Icons.favorite_rounded,
                                size: 16, color: Colors.red),
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
    return Image.asset(url,
        width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
              width: w,
              height: h,
              color: AppColors.green800,
              child: const Icon(Icons.image_rounded, color: Colors.white30),
            ));
  }
  return Container(
    width: w,
    height: h,
    color: AppColors.green800,
    child: const Icon(Icons.image_rounded, color: Colors.white30),
  );
}