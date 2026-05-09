import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_cubit.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/features/places/screens/place_details_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/place_image_widget.dart';

class PlacesSearchScreen extends StatelessWidget {
  const PlacesSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlacesCubit(),
      child: const _PlacesSearchScreenView(),
    );
  }
}

class _PlacesSearchScreenView extends StatefulWidget {
  const _PlacesSearchScreenView();

  @override
  State<_PlacesSearchScreenView> createState() => _PlacesSearchScreenViewState();
}

class _PlacesSearchScreenViewState extends State<_PlacesSearchScreenView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    PlacesCubit.get(context).searchPlaces(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            style: GoogleFonts.dmSans(fontSize: 15, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search places, cities...',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(Icons.search_rounded, color: cs.primary, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 20, color: cs.onSurface),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
      body: BlocBuilder<PlacesCubit, PlacesStates>(
        builder: (context, state) {
          if (state is PlacesInitialState || _searchController.text.isEmpty) {
            return _buildEmptyState(
              icon: Icons.travel_explore_rounded,
              title: 'Find Your Next Destination',
              message: 'Type the name of a place, city, or monument to begin.',
              colorScheme: cs,
            );
          }

          if (state is PlacesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlacesErrorState) {
            return Center(
              child: Text(state.message, style: TextStyle(color: AppColors.errorColor)),
            );
          }

          if (state is PlacesLoadedState) {
            if (state.filteredPlaces.isEmpty) {
              return _buildEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No Results Found',
                message: 'We couldn\'t find any places matching "${_searchController.text}".',
                colorScheme: cs,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: state.filteredPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _PlaceHorizontalCard(
                  place: state.filteredPlaces[index],
                  isDark: isDark,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required ColorScheme colorScheme,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _PlaceHorizontalCard extends StatelessWidget {
  final PlacesResponse place;
  final bool isDark;

  const _PlaceHorizontalCard({required this.place, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // Hide keyboard when navigating
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                color: cs.surfaceContainerHighest,
              ),
              clipBehavior: Clip.hardEdge,
              child: PlaceImageWidget(
                imageUrl: place.mainImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      place.name ?? 'Unknown Place',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.cityName ?? 'Unknown City',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Rating and Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              place.rating?.toStringAsFixed(1) ?? 'N/A',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${place.totalRatings ?? 0})',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        
                        // Category Badge
                        if (place.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              place.category!.name.toUpperCase(),
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
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
