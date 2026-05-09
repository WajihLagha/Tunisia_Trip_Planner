import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_cubit.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_states.dart';
import 'package:tunisian_trip_planner/features/accommodation/room_detail_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';
import 'package:tunisian_trip_planner/features/reviews/widgets/reviews_section.dart';
import 'package:tunisian_trip_planner/features/reviews/models/review_target_type.dart';
import 'package:tunisian_trip_planner/shared/widgets/place_image_widget.dart';

class AccommodationDetailScreen extends StatelessWidget {
  final AccommodationDto accommodation;

  const AccommodationDetailScreen({super.key, required this.accommodation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(isDark),
                  const SizedBox(height: 24),
                  _buildHostInfo(isDark),
                  const SizedBox(height: 24),
                  _buildAboutSection(isDark),
                  const SizedBox(height: 32),
                  _buildAvailableRooms(context, isDark),
                  const SizedBox(height: 32),
                  _buildLocationSection(isDark),
                  const SizedBox(height: 32),
                  if (accommodation.id != null)
                    Transform.translate(
                      offset: const Offset(-24, 0), // Adjust for the parent padding
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ReviewsSection(
                          targetId: accommodation.id.toString(),
                          targetType: ReviewTargetType.accommodation,
                        ),
                      ),
                    ),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black45 : Colors.white70,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black45 : Colors.white70,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black45 : Colors.white70,
            shape: BoxShape.circle,
          ),
          child: BlocBuilder<FavouritesCubit, FavouritesStates>(
            builder: (context, state) {
              final accommodationId = accommodation.id?.toString();
              final isFav = accommodationId != null &&
                  FavouritesCubit.get(context)
                      .isAccommodationFavourite(accommodationId);

              return IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color:
                      isFav
                          ? Colors.red
                          : (isDark ? Colors.white : Colors.black),
                ),
                onPressed: () {
                  if (accommodationId != null) {
                    FavouritesCubit.get(context).toggleAccommodationFavourite(
                      accommodationId,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot favourite: missing ID')),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Builder(
          builder: (context) {
            final url = accommodation.images?.isNotEmpty == true
                ? accommodation.images!.first.imageUrl
                : null;
            final safeUrl = (url != null && url.isNotEmpty) ? url : null;
            return PlaceImageWidget(
              imageUrl: safeUrl ?? 'assets/images/default_hotel.jpg',
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      accommodation.accommodationType?.name.toUpperCase() ??
                          'HOTEL',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    accommodation.name ?? 'Unknown Accommodation',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${accommodation.rating ?? 0.0}',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                accommodation.address ?? 'Unknown Address',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            Text(
              'View on map',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.green500,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.green500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: const AssetImage(
              'assets/images/default_profile.jpg',
            ), // Placeholder
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOSTED BY',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Amina K.',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
              foregroundColor: isDark ? Colors.white : Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this place',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          accommodation.description ?? 'No description available.',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Read more',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.green500,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.green500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableRooms(BuildContext context, bool isDark) {
    final rooms = accommodation.rooms;
    if (rooms == null || rooms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Rooms',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 16),
        ...rooms.map((room) => _buildRoomCard(context, room, isDark)),
      ],
    );
  }

  Widget _buildRoomCard(BuildContext context, var room, bool isDark) {
    return GestureDetector(
      onTap: () => navigateTo(
        context,
        RoomDetailScreen(
          room: room,
          accommodation: accommodation,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: PlaceImageWidget(
                imageUrl: (room.images?.isNotEmpty == true
                        ? room.images!.first.imageUrl
                        : null) ??
                    'assets/images/default_room.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        room.description ?? 'Standard Room',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    if (room.availableRooms != null && room.availableRooms! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              room.availableRooms! <= 2
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          room.availableRooms! <= 2
                              ? '${room.availableRooms} LEFT'
                              : 'AVAILABLE',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                room.availableRooms! <= 2
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity ?? 2} Guests',
                      style: GoogleFonts.dmSans(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.bed_outlined,
                      size: 16,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '1 King Bed',
                      style: GoogleFonts.dmSans(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price per night',
                          style: GoogleFonts.dmSans(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${room.price?.round() ?? 0}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Select Room'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),   // closes Container
    );   // closes GestureDetector
  }

  Widget _buildLocationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 200,
            width: double.infinity,
            color: isDark ? Colors.grey[800] : Colors.blue[100],
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  color: isDark ? Colors.grey[800] : Colors.blue[100],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 60,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map View',
                          style: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.location_on, color: Colors.red, size: 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Located in the heart of the historic Medina, a UNESCO World Heritage site.',
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.mutedText),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starting from',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${accommodation.priceMin?.round() ?? 0}',
                          style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                          ),
                        ),
                        Text(
                          ' /night',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green900,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Book Now',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
