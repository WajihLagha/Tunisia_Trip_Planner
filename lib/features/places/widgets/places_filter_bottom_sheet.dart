import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_cubit.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';

class PlacesFilterBottomSheet extends StatefulWidget {
  final PlacesCategory? initialCategory;
  final double initialMinRating;

  const PlacesFilterBottomSheet({
    super.key,
    this.initialCategory,
    this.initialMinRating = 0.0,
  });

  @override
  State<PlacesFilterBottomSheet> createState() =>
      _PlacesFilterBottomSheetState();
}

class _PlacesFilterBottomSheetState extends State<PlacesFilterBottomSheet> {
  PlacesCategory? _selectedCategory;
  double _minRating = 0.0;

  static const _categories = [
    (PlacesCategory.history, Icons.account_balance_rounded, 'History'),
    (PlacesCategory.culture, Icons.palette_rounded, 'Culture'),
    (PlacesCategory.nature, Icons.forest_rounded, 'Nature'),
    (PlacesCategory.beach, Icons.beach_access_rounded, 'Beach'),
    (PlacesCategory.desert, Icons.landscape_rounded, 'Desert'),
    (PlacesCategory.mountain, Icons.terrain_rounded, 'Mountain'),
    (PlacesCategory.adventure, Icons.hiking_rounded, 'Adventure'),
    (PlacesCategory.restaurant, Icons.restaurant_rounded, 'Restaurant'),
    (PlacesCategory.museum, Icons.museum_rounded, 'Museum'),
    (PlacesCategory.park, Icons.park_rounded, 'Park'),
    (PlacesCategory.shopping, Icons.shopping_bag_rounded, 'Shopping'),
    (PlacesCategory.nightlife, Icons.nightlife_rounded, 'Nightlife'),
    (PlacesCategory.religious, Icons.mosque_rounded, 'Religious'),
    (PlacesCategory.entertainment, Icons.attractions_rounded, 'Entertainment'),
    (PlacesCategory.island, Icons.water_rounded, 'Island'),
    (PlacesCategory.company, Icons.business_rounded, 'Company'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _minRating = widget.initialMinRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Search Filters',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _minRating = 0.0;
                  });
                },
                child: Text('Reset',
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Section
          Text('Category',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.45,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final (cat, icon, label) = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() =>
                      _selectedCategory = isSelected ? null : cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon,
                            size: 16,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Rating Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Minimum Rating',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _minRating == 0.0 ? 'Any' : _minRating.toStringAsFixed(1),
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.1),
              inactiveTrackColor:
                  colorScheme.surfaceContainerHighest,
              trackHeight: 4,
            ),
            child: Slider(
              min: 0.0,
              max: 5.0,
              divisions: 10,
              value: _minRating,
              onChanged: (val) => setState(() => _minRating = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Any', style: theme.textTheme.bodySmall),
              Text('5.0 ★', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 28),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                PlacesCubit.get(context).applyFilters(
                  category: _selectedCategory,
                  rating: _minRating,
                );
                Navigator.pop(context);
              },
              child: Text('Show Results',
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
