import 'places_category.dart';
import 'place_image.dart';

class PlacesResponse {
  final String? id;
  final String? ownerId;
  final String? cityName;
  final String? stateName;
  final PlacesCategory? category;
  final String? name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final double? rating;
  final int? totalRatings;
  final double? averagePrice;
  final String? mainImageUrl;
  final List<PlaceImage>? images;
  final DateTime? createdDate;

  PlacesResponse({
    this.id,
    this.ownerId,
    this.cityName,
    this.stateName,
    this.category,
    this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.rating,
    this.totalRatings,
    this.averagePrice,
    this.mainImageUrl,
    this.images,
    this.createdDate,
  });

  factory PlacesResponse.fromJson(Map<String, dynamic> json) {
    return PlacesResponse(
      id: json['id']?.toString(),
      ownerId: json['ownerId'] as String?,
      cityName: json['cityName'] as String?,
      stateName: json['stateName'] as String?,
      // Backend sends 'Category' with capital C
      category: (json['Category'] ?? json['category']) != null
          ? PlacesCategory.values.firstWhere(
              (e) => e.name.toUpperCase() == (json['Category'] ?? json['category']).toString().toUpperCase(),
              orElse: () => PlacesCategory.history,
            )
          : null,
      name: json['name'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRatings: json['totalRatings'] as int?,
      averagePrice: (json['averagePrice'] as num?)?.toDouble(),
      mainImageUrl: json['mainImageUrl'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => PlaceImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdDate: json['createdDate'] != null 
          ? DateTime.tryParse(json['createdDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      if (cityName != null) 'cityName': cityName,
      if (stateName != null) 'stateName': stateName,
      if (category != null) 'category': category?.name,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (rating != null) 'rating': rating,
      if (totalRatings != null) 'totalRatings': totalRatings,
      if (averagePrice != null) 'averagePrice': averagePrice,
      if (mainImageUrl != null) 'mainImageUrl': mainImageUrl,
      if (images != null) 'images': images?.map((e) => e.toJson()).toList(),
      if (createdDate != null) 'createdDate': createdDate?.toIso8601String(),
    };
  }
}
