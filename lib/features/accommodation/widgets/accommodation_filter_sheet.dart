import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';

class AccommodationFilterSheet extends StatefulWidget {
  const AccommodationFilterSheet({super.key});

  @override
  State<AccommodationFilterSheet> createState() =>
      _AccommodationFilterSheetState();
}

class _AccommodationFilterSheetState extends State<AccommodationFilterSheet> {
  RangeValues _priceRange = const RangeValues(50, 500);
  final List<String> _selectedAmenities = [];

  final List<String> _amenities = [
    'Wi-Fi',
    'Pool',
    'Breakfast',
    'Spa',
    'Gym',
    'Parking',
    'Restaurant',
    'Air Conditioning',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Price Range',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.green500,
            inactiveColor: isDark ? AppColors.green900 : AppColors.green100,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Amenities',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.map((amenity) {
              final isSelected = _selectedAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAmenities.add(amenity);
                    } else {
                      _selectedAmenities.remove(amenity);
                    }
                  });
                },
                selectedColor: AppColors.green500.withValues(alpha: 0.2),
                checkmarkColor: AppColors.green500,
                labelStyle: GoogleFonts.dmSans(
                  color: isSelected
                      ? AppColors.green500
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: isDark ? AppColors.surfaceVariantD : AppColors.surfaceVariantL,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.green500
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
