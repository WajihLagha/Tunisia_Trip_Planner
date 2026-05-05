import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_itinerary.dart';
import 'package:tunisian_trip_planner/features/places/data/mock_places_data.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class AiItineraryScreen extends StatelessWidget {
  final AiItinerary itinerary;

  const AiItineraryScreen({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final cardColor = isDark ? AppColors.surfaceVariantD : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: isDark ? AppColors.green300 : Colors.white,
        title: Text(
          itinerary.title ?? 'Your Custom Trip',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            onPressed: () {
              navigateTo(context, _TrajectoryMapScreen(itinerary: itinerary));
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.surfaceVariantD : AppColors.primary,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Summary',
                    style: GoogleFonts.nunito(
                        color: isDark ? AppColors.green300 : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    itinerary.summary ?? 'Enjoy your AI generated trip!',
                    style: GoogleFonts.nunito(
                        color: isDark ? textColor.withValues(alpha: 0.8) : Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: isDark ? AppColors.green300 : Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('${itinerary.totalDays ?? itinerary.days.length} Days',
                          style: GoogleFonts.nunito(color: isDark ? textColor : Colors.white)),
                      const SizedBox(width: 16),
                      if (itinerary.estimatedBudget != null) ...[
                        Icon(Icons.account_balance_wallet,
                            color: isDark ? AppColors.green300 : Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('${itinerary.estimatedBudget} TND estimated',
                            style: GoogleFonts.nunito(color: isDark ? textColor : Colors.white)),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dayPlan = itinerary.days[index];
                return _buildDayCard(dayPlan, isDark, cardColor, textColor);
              },
              childCount: itinerary.days.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildDayCard(AiDayPlan dayPlan, bool isDark, Color cardColor, Color textColor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.green800 : AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Day ${dayPlan.day}',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dayPlan.places.map((placeName) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on,
                        color: isDark ? AppColors.green300 : AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        placeName,
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _TrajectoryMapScreen extends StatelessWidget {
  final AiItinerary itinerary;

  const _TrajectoryMapScreen({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    // Collect coordinates from the mock data based on the names in the itinerary
    final List<LatLng> points = [];
    final List<Marker> markers = [];

    int dayIndex = 1;
    for (var day in itinerary.days) {
      for (var placeName in day.places) {
        // Find matching place in mock data (approximate matching)
        final place = MockPlacesData.places.cast<dynamic>().firstWhere(
            (p) =>
                p.name.toLowerCase().contains(placeName.toLowerCase()) ||
                placeName.toLowerCase().contains(p.name.toLowerCase()),
            orElse: () => null);

        if (place != null && place.latitude != null && place.longitude != null) {
          final point = LatLng(place.latitude!, place.longitude!);
          points.add(point);
          markers.add(
            Marker(
              point: point,
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'D$dayIndex',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 30),
                ],
              ),
            ),
          );
        }
      }
      dayIndex++;
    }

    final initialCenter = points.isNotEmpty
        ? points.first
        : const LatLng(36.8065, 10.1815); // Default to Tunis

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Trajectory'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: 6.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tunisian_trip_planner',
          ),
          if (points.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: AppColors.primary,
                  strokeWidth: 4.0,
                ),
              ],
            ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
