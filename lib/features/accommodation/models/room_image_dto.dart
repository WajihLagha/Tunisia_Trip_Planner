// room_image_dto.dart
class RoomImageDto {
  final int? id;
  final String? imageUrl;

  RoomImageDto({this.id, this.imageUrl});

  factory RoomImageDto.fromJson(Map<String, dynamic> json) => RoomImageDto(
    id: json['id'],
    imageUrl: json['imageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
  };
}