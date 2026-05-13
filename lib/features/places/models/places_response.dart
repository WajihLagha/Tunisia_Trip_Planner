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
      'id': id ?? '',
      'ownerId': ownerId ?? '',
      'cityName': cityName ?? '',
      'stateName': stateName ?? '',
      'category': category?.name.toUpperCase() ?? '',
      'name': name ?? '',
      'description': description ?? '',
      'address': address ?? '',
      'latitude': latitude ?? 0,
      'longitude': longitude ?? 0,
      'phoneNumber': phoneNumber ?? '',
      'email': email ?? '',
      'rating': rating ?? 0,
      'totalRatings': totalRatings ?? 0,
      'averagePrice': averagePrice ?? 0,
      'mainImageUrl': mainImageUrl ?? '',
      'images': images?.map((e) => e.toJson()).toList() ?? [],
      if (createdDate != null) 'createdDate': createdDate?.toIso8601String(),
    };
  }
}
