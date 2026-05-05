class AiPlace {
  final String? id;
  final String? name;
  final String? cityName;
  final double? latitude;
  final double? longitude;
  final String? category;

  const AiPlace({
    this.id,
    this.name,
    this.cityName,
    this.latitude,
    this.longitude,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (cityName != null) 'cityName': cityName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (category != null) 'category': category,
      };

  factory AiPlace.fromJson(Map<String, dynamic> json) => AiPlace(
        id: json['id'] as String?,
        name: json['name'] as String?,
        cityName: json['cityName'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        category: json['category'] as String?,
      );
}
