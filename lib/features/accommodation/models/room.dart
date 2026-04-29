import 'package:tunisian_trip_planner/features/accommodation/enums/room_type.dart';
import 'room_image_dto.dart';

class RoomDto {
  final int? id;
  final RoomType? type;
  final double? price;
  final int? capacity;
  final int? roomQuantity;
  final String? description;
  final int? availableRooms;
  final List<RoomImageDto>? images;

  RoomDto({
    this.id,
    this.type,
    this.price,
    this.capacity,
    this.roomQuantity,
    this.description,
    this.availableRooms,
    this.images,
  });

  factory RoomDto.fromJson(Map<String, dynamic> json) => RoomDto(
    id: json['id'],
    type: json['type'] != null ? RoomType.fromString(json['type']) : null,
    price: (json['price'] as num?)?.toDouble(),
    capacity: json['capacity'],
    roomQuantity: json['roomQuantity'],
    description: json['description'],
    availableRooms: json['availableRooms'],
    images: (json['images'] as List<dynamic>?)
        ?.map((e) => RoomImageDto.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type?.toJson(),
    'price': price,
    'capacity': capacity,
    'roomQuantity': roomQuantity,
    'description': description,
    'availableRooms': availableRooms,
    'images': images?.map((e) => e.toJson()).toList(),
  };
}