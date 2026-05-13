import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';
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
                  _buildContactInfo(isDark),
                  const SizedBox(height: 24),
                  _buildAboutSection(isDark),
                  const SizedBox(height: 32),
                  _buildAvailableRooms(context, isDark),
                  const SizedBox(height: 32),
                  if (accommodation.id != null)
                    Transform.translate(
                      offset: const Offset(
                        -24,
                        0,
                      ), // Adjust for the parent padding
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
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black45 : Colors.white70,
            shape: BoxShape.circle,
          ),
          child: BlocBuilder<FavouritesCubit, FavouritesStates>(
            builder: (context, state) {
              final accommodationId = accommodation.id?.toString();
              final isFav =
                  accommodationId != null &&
                  FavouritesCubit.get(
                    context,
                  ).isAccommodationFavourite(accommodationId);

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
                    FavouritesCubit.get(
                      context,
                    ).toggleAccommodationFavourite(accommodationId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot favourite: missing ID'),
                      ),
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
            String? safeUrl;
            if (accommodation.images != null &&
                accommodation.images!.isNotEmpty) {
              safeUrl = accommodation.images!.first.imageUrl;
            }
            if (safeUrl == null || safeUrl.isEmpty) {
              safeUrl = null;
            }
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
    final locationText = [
      accommodation.address,
      accommodation.city,
      accommodation.state,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

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
                          'ACCOMMODATION',
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
                    accommodation.name ?? 'Unnamed Place',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                locationText.isEmpty ? 'Unknown Location' : locationText,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfo(bool isDark) {
    if ((accommodation.contactPhone?.isEmpty ?? true) &&
        (accommodation.contactEmail?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTACT INFO',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (accommodation.contactPhone != null &&
              accommodation.contactPhone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16, color: AppColors.green500),
                  const SizedBox(width: 8),
                  Text(
                    accommodation.contactPhone ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          if (accommodation.contactEmail != null &&
              accommodation.contactEmail!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.email, size: 16, color: AppColors.green500),
                const SizedBox(width: 8),
                Text(
                  accommodation.contactEmail!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark) {
    if (accommodation.description?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

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
          accommodation.description ?? '',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
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

  Widget _buildRoomCard(BuildContext context, RoomDto room, bool isDark) {
    final availableCount = room.availableRooms ?? 0;
    final roomImageUrl = (room.images?.isNotEmpty == true)
        ? room.images!.first.imageUrl
        : 'assets/images/default_hotel.jpg';

    return GestureDetector(
      onTap: () => navigateTo(
        context,
        RoomDetailScreen(room: room, accommodation: accommodation),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Fixed-size image (no double.infinity) ──────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: SizedBox(
                width: 110,
                height: 120,
                child: PlaceImageWidget(
                  imageUrl: roomImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // ── Details ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          room.type?.name.toUpperCase() ?? 'ROOM',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green500,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (availableCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: availableCount <= 2
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              availableCount <= 2
                                  ? '$availableCount LEFT'
                                  : 'AVAIL.',
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.description ?? 'Standard Room',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 13, color: AppColors.mutedText),
                        const SizedBox(width: 3),
                        Text(
                          '${room.capacity ?? 2} Guests',
                          style: GoogleFonts.dmSans(color: AppColors.mutedText, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${room.price?.round() ?? 0}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.green500,
                                ),
                              ),
                              TextSpan(
                                text: '/night',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.green500.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppColors.green500,
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

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
                onPressed: () {
                  final rooms = accommodation.rooms;
                  if (rooms != null && rooms.isNotEmpty) {
                    navigateTo(
                      context,
                      RoomDetailScreen(
                        room: rooms.first,
                        accommodation: accommodation,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No rooms currently available.'),
                      ),
                    );
                  }
                },
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
