import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/my_bookings_screen.dart';
import 'package:tunisian_trip_planner/features/favourite_screen.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_cubit.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/features/places/screens/place_details_screen.dart';
import 'package:tunisian_trip_planner/features/places/widgets/places_filter_bottom_sheet.dart';
import 'package:tunisian_trip_planner/features/places/screens/places_search_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';
import 'package:tunisian_trip_planner/shared/widgets/place_image_widget.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlacesCubit()..loadPlaces(),
      child: const _ExploreScreenView(),
    );
  }
}

class _ExploreScreenView extends StatefulWidget {
  const _ExploreScreenView();

  @override
  State<_ExploreScreenView> createState() => _ExploreScreenViewState();
}

class _ExploreScreenViewState extends State<_ExploreScreenView> {
  final ScrollController _scrollController = ScrollController();
  bool _showCollapsed = false;

  static const _heroHeight = 220.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldCollapse = _scrollController.offset > _heroHeight - 80;
      if (shouldCollapse != _showCollapsed) {
        setState(() => _showCollapsed = shouldCollapse);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilters(BuildContext ctx, PlacesLoadedState state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: PlacesCubit.get(ctx),
        child: PlacesFilterBottomSheet(
          initialCategory: state.selectedCategory,
          initialMinRating: state.minRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<PlacesCubit, PlacesStates>(
        builder: (ctx, state) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: _heroHeight,
                pinned: true,
                floating: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: AnimatedOpacity(
                  opacity: _showCollapsed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    'TuniWays',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.green950,
                    ),
                  ),
                ),
                actions: [
                  AnimatedOpacity(
                    opacity: _showCollapsed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_rounded,
                              color: isDark ? Colors.white : AppColors.green950),
                          onPressed: () => navigateTo(
                              ctx, const FavouriteScreen()),
                        ),
                        IconButton(
                          icon: Icon(Icons.bookmark_rounded,
                              color: isDark ? Colors.white : AppColors.green950),
                          onPressed: () => navigateTo(
                              ctx, const MyBookingScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _HeroHeader(
                    isDark: isDark,
                    onFavouritesTap: () =>
                        navigateTo(ctx, const FavouriteScreen()),
                    onBookingsTap: () =>
                        navigateTo(ctx, const MyBookingScreen()),
                  ),
                ),
              ),

              // ── Search + Category Row ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SearchBar(
                          isDark: isDark,
                          colorScheme: cs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (state is PlacesLoadedState)
                        _FilterBadge(
                          hasActiveFilter: state.selectedCategory != null ||
                              state.minRating > 0,
                          onTap: () => _showFilters(ctx, state),
                          colorScheme: cs,
                        ),
                    ],
                  ),
                ),
              ),


              // ── Category Chips ────────────────────────────────
              SliverToBoxAdapter(
                child: _CategoryChipsRow(state: state, ctx: ctx),
              ),

              // ── Results Header ────────────────────────────────
              if (state is PlacesLoadedState)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.selectedCategory != null
                              ? _categoryLabel(state.selectedCategory!)
                              : 'Tunisian Gems',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.filteredPlaces.length} Places',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Loading ───────────────────────────────────────
              if (state is PlacesLoadingState ||
                  state is PlacesInitialState)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),

              // ── Error ─────────────────────────────────────────
              if (state is PlacesErrorState)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.errorColor),
                        const SizedBox(height: 12),
                        Text(state.message),
                      ],
                    ),
                  ),
                ),

              // ── Empty State ───────────────────────────────────
              if (state is PlacesLoadedState &&
                  state.filteredPlaces.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64,
                            color: cs.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No places found',
                            style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onSurface
                                    .withValues(alpha: 0.5))),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              PlacesCubit.get(ctx).resetFilters(),
                          child: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Places Grid ───────────────────────────────────
              if (state is PlacesLoadedState &&
                  state.filteredPlaces.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final place = state.filteredPlaces[index];
                        return _PlaceCard(
                          place: place,
                          index: index,
                          isDark: isDark,
                          theme: theme,
                        );
                      },
                      childCount: state.filteredPlaces.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  String _categoryLabel(PlacesCategory cat) {
    switch (cat) {
      case PlacesCategory.history:    return 'Historical Sites';
      case PlacesCategory.culture:    return 'Cultural Spots';
      case PlacesCategory.nature:     return 'Nature Escapes';
      case PlacesCategory.beach:      return 'Beach Paradises';
      case PlacesCategory.desert:     return 'Desert Adventures';
      case PlacesCategory.mountain:   return 'Mountain Peaks';
      case PlacesCategory.adventure:  return 'Adventure Zones';
      case PlacesCategory.restaurant: return 'Restaurants';
      case PlacesCategory.museum:     return 'Museums';
      case PlacesCategory.park:       return 'Parks';
      case PlacesCategory.shopping:   return 'Shopping';
      case PlacesCategory.nightlife:  return 'Nightlife';
      case PlacesCategory.religious:  return 'Religious Sites';
      case PlacesCategory.entertainment: return 'Entertainment';
      case PlacesCategory.island:     return 'Islands';
      case PlacesCategory.company:    return 'Companies';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onFavouritesTap;
  final VoidCallback? onBookingsTap;

  const _HeroHeader({
    required this.isDark,
    this.onFavouritesTap,
    this.onBookingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.green950, AppColors.surfaceDark]
              : [AppColors.green700, AppColors.green500],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(80),
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back 👋',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'TuniWays',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GlassIconButton(
                            icon: Icons.favorite_rounded,
                            onTap: onFavouritesTap,
                          ),
                          const SizedBox(width: 10),
                          _GlassIconButton(
                            icon: Icons.bookmark_rounded,
                            onTap: onBookingsTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Hero tagline
                  Text(
                    'Discover the Hidden Gems ✨',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ancient ruins to endless dunes — explore it all.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass Icon Button (used in hero header)
// ─────────────────────────────────────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GlassIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;

  const _SearchBar(
      {required this.isDark,
      required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateTo(context, const PlacesSearchScreen()),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantD
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Search places, cities...',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Badge Button
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBadge extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _FilterBadge(
      {required this.hasActiveFilter,
      required this.onTap,
      required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded,
                color: Colors.white, size: 22),
          ),
          if (hasActiveFilter)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chips Row
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChipsRow extends StatelessWidget {
  final PlacesStates state;
  final BuildContext ctx;

  static const _chips = [
    (null, Icons.apps_rounded, 'All'),
    (PlacesCategory.history, Icons.account_balance_rounded, 'History'),
    (PlacesCategory.culture, Icons.palette_rounded, 'Culture'),
    (PlacesCategory.nature, Icons.forest_rounded, 'Nature'),
    (PlacesCategory.beach, Icons.beach_access_rounded, 'Beach'),
    (PlacesCategory.desert, Icons.landscape_rounded, 'Desert'),
    (PlacesCategory.restaurant, Icons.restaurant_rounded, 'Food'),
    (PlacesCategory.museum, Icons.museum_rounded, 'Museum'),
    (PlacesCategory.adventure, Icons.hiking_rounded, 'Adventure'),
  ];

  const _CategoryChipsRow({required this.state, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedCat =
        state is PlacesLoadedState ? (state as PlacesLoadedState).selectedCategory : null;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _chips.length,
        itemBuilder: (_, i) {
          final (cat, icon, label) = _chips[i];
          final isSelected = cat == selectedCat;
          return GestureDetector(
            onTap: () => PlacesCubit.get(ctx).filterByCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 15,
                      color: isSelected ? Colors.white : cs.onSurface),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Place Card
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceCard extends StatelessWidget {
  final PlacesResponse place;
  final int index;
  final bool isDark;
  final ThemeData theme;

  const _PlaceCard(
      {required this.place,
      required this.index,
      required this.isDark,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 80)),
      curve: Curves.easeOutQuart,
      builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
              offset: Offset(0, 30 * (1 - v)), child: child)),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PlaceDetailsScreen(place: place)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? AppColors.surfaceVariantD : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ──
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'place_${place.id}',
                        child: PlaceImageWidget(
                          imageUrl: place.mainImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black38,
                              ],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                place.category?.name.toUpperCase() ?? '',
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Favorite btn
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_border,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),
                      // Rating
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                place.rating?.toStringAsFixed(1) ?? '',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name ?? '',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12, color: cs.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${place.cityName}, ${place.stateName}',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: cs.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if ((place.averagePrice ?? 0) > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'From \$${place.averagePrice?.toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
