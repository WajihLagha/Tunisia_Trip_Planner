import 'package:tunisian_trip_planner/features/accommodation/enums/accommodation_type.dart';
import 'package:tunisian_trip_planner/features/accommodation/enums/room_type.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation_image.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room_image_dto.dart';

class MockAccommodationData {
  static List<AccommodationDto> get accommodations => [
    AccommodationDto(
      id: 1,
      name: 'Dar El Jeld Hotel & Spa',
      description:
      'Experience the authentic charm of the Tunis Medina in this meticulously restored traditional home. Featuring stunning tile work, a peaceful central courtyard, and modern luxury amenities.',
      city: 'Tunis',
      state: 'Tunis',
      address: 'Medina, Tunis, Tunisia',
      accommodationType: AccommodationType.hotel,
      rating: 4.9,
      totalRating: 1240,
      priceMin: 95.0,
      priceMax: 145.0,
      latitude: 36.7992,
      longitude: 10.1706,
      images: [
        AccommodationImageDto(id: 1, imageUrl: 'assets/images/default_hotel.jpg'),
        AccommodationImageDto(id: 2, imageUrl: 'assets/images/default_hotel.jpg'),
      ],
      rooms: [
        RoomDto(
          id: 1,
          type: RoomType.suite,
          price: 145.0,
          capacity: 2,
          roomQuantity: 5,
          availableRooms: 3,
          description: 'Deluxe Courtyard Suite',
          images: [
            RoomImageDto(id: 1, imageUrl: 'assets/images/default_hotel.jpg'),
          ],
        ),
        RoomDto(
          id: 2,
          type: RoomType.double,
          price: 95.0,
          capacity: 2,
          roomQuantity: 10,
          availableRooms: 1,
          description: 'Superior Twin Room',
          images: [
            RoomImageDto(id: 2, imageUrl: 'assets/images/default_hotel.jpg'),
          ],
        ),
      ],
    ),
    AccommodationDto(
      id: 2,
      name: 'Forest Haven Estate',
      description: 'A modern villa surrounded by nature, perfect for a relaxing getaway.',
      city: 'Ain Draham',
      state: 'Jendouba',
      address: 'Forest Road, Ain Draham',
      accommodationType: AccommodationType.villa,
      rating: 4.2,
      totalRating: 320,
      priceMin: 120.0,
      priceMax: 200.0,
      latitude: 36.7766,
      longitude: 8.6874,
      images: [
        AccommodationImageDto(id: 3, imageUrl: 'assets/images/default_hotel.jpg'),
      ],
      rooms: [
        RoomDto(
          id: 3,
          type: RoomType.family,
          price: 120.0,
          capacity: 4,
          roomQuantity: 2,
          availableRooms: 2,
          description: 'Modern Villa',
          images: [
            RoomImageDto(id: 3, imageUrl: 'assets/images/default_hotel.jpg'),
          ],
        ),
      ],
    ),
    AccommodationDto(
      id: 3,
      name: 'La Badira',
      description: 'Luxury adult-only hotel with stunning sea views and exceptional spa.',
      city: 'Hammamet',
      state: 'Nabeul',
      address: 'Hammamet Nord, Tunisia',
      accommodationType: AccommodationType.hotel,
      rating: 4.8,
      totalRating: 2150,
      priceMin: 150.0,
      priceMax: 300.0,
      latitude: 36.4253,
      longitude: 10.6084,
      images: [
        AccommodationImageDto(id: 4, imageUrl: 'assets/images/default_hotel.jpg'),
      ],
      rooms: [
        RoomDto(
          id: 4,
          type: RoomType.double,
          price: 150.0,
          capacity: 2,
          roomQuantity: 20,
          availableRooms: 5,
          description: 'Sea View Double',
          images: [
            RoomImageDto(id: 4, imageUrl: 'assets/images/default_hotel.jpg'),
          ],
        ),
      ],
    ),
    AccommodationDto(
      id: 4,
      name: 'Sidi Bou Said Boutique Guest House',
      description: 'Charming guest house in the heart of the blue and white village.',
      city: 'Sidi Bou Said',
      state: 'Tunis',
      address: 'Rue Habib Thameur, Sidi Bou Said',
      accommodationType: AccommodationType.guesthouse,
      rating: 4.7,
      totalRating: 850,
      priceMin: 80.0,
      priceMax: 120.0,
      latitude: 36.8688,
      longitude: 10.3340,
      images: [
        AccommodationImageDto(id: 5, imageUrl: 'assets/images/default_hotel.jpg'),
      ],
      rooms: [
        RoomDto(
          id: 5,
          type: RoomType.single,
          price: 80.0,
          capacity: 1,
          roomQuantity: 4,
          availableRooms: 2,
          description: 'Cozy Single Room',
          images: [
            RoomImageDto(id: 5, imageUrl: 'assets/images/default_hotel.jpg'),
          ],
        ),
      ],
    ),
  ];

  static List<RoomDto> get topRooms {
    final allRooms = accommodations.expand((acc) => acc.rooms ?? []).toList();
    return allRooms.take(4).cast<RoomDto>().toList();
  }
}
