import 'package:tunisian_trip_planner/features/transport/enums/transport_type.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_image_model.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';

class TransportModel {
  final int? id;
  final String? ownerId;
  final String cityId;
  final TransportType type;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double priceMin;
  final double priceMax;
  final String? contactPhone;
  final String? contactEmail;
  final double averageRating;
  final int totalReviews;
  final String? stripeAccount;
  final bool stripeOnboarded;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final List<TransportImageModel> images;
  final List<VehicleModel> vehicles;

  // Helper getter to match old code if needed
  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;
  double get pricePerDay => priceMin;

  const TransportModel({
    this.id,
    this.ownerId,
    required this.cityId,
    this.type = TransportType.carRental,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.priceMin = 0.0,
    this.priceMax = 0.0,
    this.contactPhone,
    this.contactEmail,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.stripeAccount,
    this.stripeOnboarded = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.images = const [],
    this.vehicles = const [],
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'] as int?,
      ownerId: json['ownerId'] as String?,
      cityId: json['cityId'] as String? ?? '',
      type: json['type'] != null
          ? TransportType.fromJson(json['type'] as String)
          : TransportType.other,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      priceMin: (json['priceMin'] as num?)?.toDouble() ?? 0.0,
      priceMax: (json['priceMax'] as num?)?.toDouble() ?? 0.0,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      stripeAccount: json['stripeAccount'] as String?,
      stripeOnboarded: json['stripeOnboarded'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((i) => TransportImageModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cityId': cityId,
      'type': type.toJson(),
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      // Note: Output lists aren't normally sent in TransportDto but left here for caching if needed
      'images': images.map((i) => i.toJson()).toList(),
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
    };
  }

  TransportModel copyWith({
    int? id,
    String? ownerId,
    String? cityId,
    TransportType? type,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    double? priceMin,
    double? priceMax,
    String? contactPhone,
    String? contactEmail,
    double? averageRating,
    int? totalReviews,
    String? stripeAccount,
    bool? stripeOnboarded,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    List<TransportImageModel>? images,
    List<VehicleModel>? vehicles,
  }) {
    return TransportModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      cityId: cityId ?? this.cityId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      stripeAccount: stripeAccount ?? this.stripeAccount,
      stripeOnboarded: stripeOnboarded ?? this.stripeOnboarded,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}
