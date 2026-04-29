class AccommodationImageDto {
  final int? id;
  final String? imageUrl;

  AccommodationImageDto({this.id, this.imageUrl});

  factory AccommodationImageDto.fromJson(Map<String, dynamic> json) =>
      AccommodationImageDto(
        id: json['id'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
  };
}