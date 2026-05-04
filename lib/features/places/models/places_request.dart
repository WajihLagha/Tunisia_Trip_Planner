import 'places_category.dart';
import 'place_image.dart';

class PlacesRequest {
  final String ownerId;
  final String cityName;
  final String stateName;
  final PlacesCategory? category;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? email;
  final double averagePrice;
  final String mainImageUrl;
  final List<PlaceImage>? images;

  PlacesRequest({
    required this.ownerId,
    required this.cityName,
    required this.stateName,
    this.category,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.email,
    required this.averagePrice,
    required this.mainImageUrl,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'cityName': cityName,
      'stateName': stateName,
      if (category != null) 'category': category?.name,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'averagePrice': averagePrice,
      'mainImageUrl': mainImageUrl,
      if (images != null) 'images': images?.map((e) => e.toJson()).toList(),
    };
  }
}
