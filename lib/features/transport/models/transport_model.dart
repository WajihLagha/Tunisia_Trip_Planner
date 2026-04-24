import 'package:tunisian_trip_planner/features/transport/enums/transport_type.dart';
import 'package:tunisian_trip_planner/features/transport/enums/fuel_type.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';

class TransportModel {
  final int? id;
  final String name;
  final String? description;
  final TransportType type;
  final FuelType fuelType;
  final double rating;
  final int reviewCount;
  final String city;
  final String address;
  final String? imageUrl;
  final double pricePerDay;
  final bool isFeatured;
  final bool isAvailable;
  final bool isVerifiedPartner;
  final String? phone;
  final String? email;
  final List<VehicleModel> vehicles;

  const TransportModel({
    this.id,
    required this.name,
    this.description,
    this.type = TransportType.CAR_RENTAL,
    this.fuelType = FuelType.PETROL,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.city,
    required this.address,
    this.imageUrl,
    this.pricePerDay = 0.0,
    this.isFeatured = false,
    this.isAvailable = true,
    this.isVerifiedPartner = false,
    this.phone,
    this.email,
    this.vehicles = const [],
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] != null
          ? TransportType.fromJson(json['type'] as String)
          : TransportType.OTHER,
      fuelType: json['fuelType'] != null
          ? FuelType.fromJson(json['fuelType'] as String)
          : FuelType.PETROL,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isVerifiedPartner: json['isVerifiedPartner'] as bool? ?? false,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'fuelType': fuelType.toJson(),
      'rating': rating,
      'reviewCount': reviewCount,
      'city': city,
      'address': address,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'isVerifiedPartner': isVerifiedPartner,
      'phone': phone,
      'email': email,
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
    };
  }
}
