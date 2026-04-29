import 'package:tunisian_trip_planner/features/accommodation/enums/accommodation_type.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation_image.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';


class AccommodationDto {
  final int? id;
  final String? ownerId;
  final String? name;
  final String? description;
  final String? city;
  final String? state;
  final String? address;
  final AccommodationType? accommodationType;
  final double? latitude;
  final double? longitude;
  final double? priceMin;
  final double? priceMax;
  final String? stripeAccount;
  final bool? stripeOnboarded;
  final String? contactPhone;
  final String? contactEmail;
  final double? rating;
  final int? totalRating;
  final List<RoomDto>? rooms;
  final List<AccommodationImageDto>? images;

  AccommodationDto({
    this.id,
    this.ownerId,
    this.name,
    this.description,
    this.city,
    this.state,
    this.address,
    this.accommodationType,
    this.latitude,
    this.longitude,
    this.priceMin,
    this.priceMax,
    this.stripeAccount,
    this.stripeOnboarded,
    this.contactPhone,
    this.contactEmail,
    this.rating,
    this.totalRating,
    this.rooms,
    this.images,
  });

  factory AccommodationDto.fromJson(Map<String, dynamic> json) =>
      AccommodationDto(
        id: json['id'],
        ownerId: json['ownerId'],
        name: json['name'],
        description: json['description'],
        city: json['city'],
        state: json['state'],
        address: json['address'],
        accommodationType: json['accommodationType'] != null
            ? AccommodationType.fromString(json['accommodationType'])
            : null,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        priceMin: (json['priceMin'] as num?)?.toDouble(),
        priceMax: (json['priceMax'] as num?)?.toDouble(),
        stripeAccount: json['stripeAccount'],
        stripeOnboarded: json['stripeOnboarded'],
        contactPhone: json['contactPhone'],
        contactEmail: json['contactEmail'],
        rating: (json['rating'] as num?)?.toDouble(),
        totalRating: json['totalRating'],
        rooms: (json['rooms'] as List<dynamic>?)
            ?.map((e) => RoomDto.fromJson(e))
            .toList(),
        images: (json['images'] as List<dynamic>?)
            ?.map((e) => AccommodationImageDto.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'description': description,
    'city': city,
    'state': state,
    'address': address,
    'accommodationType': accommodationType?.toJson(),
    'stripeAccount': stripeAccount,
    'stripeOnboarded': stripeOnboarded,
    'contactPhone': contactPhone,
    'contactEmail': contactEmail,
    'rating': rating,
    'totalRating': totalRating,
    'latitude': latitude,
    'longitude': longitude,
    'priceMin': priceMin,
    'priceMax': priceMax,
    'rooms': rooms?.map((e) => e.toJson()).toList(),
    'images': images?.map((e) => e.toJson()).toList(),
  };
}