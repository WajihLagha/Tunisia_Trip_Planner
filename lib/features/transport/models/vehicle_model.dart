import 'package:tunisian_trip_planner/features/transport/enums/fuel_type.dart';

class VehicleModel {
  final int? id;
  final int? transportId;
  final String vehicleType;
  final String vehicleModel;
  final int? vehicleYear;
  final String? vehiclePlate;
  final String? vehicleColor;
  final int vehicleCapacity;
  final double vehiclePrice;
  final String? vehicleImage;
  final FuelType fuelType;
  final int quantity;
  final String? createdAt;
  final String? updatedAt;

  const VehicleModel({
    this.id,
    this.transportId,
    required this.vehicleType,
    required this.vehicleModel,
    this.vehicleYear,
    this.vehiclePlate,
    this.vehicleColor,
    this.vehicleCapacity = 1,
    this.vehiclePrice = 0.0,
    this.vehicleImage,
    this.fuelType = FuelType.petrol,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int?,
      transportId: json['transportId'] as int?,
      vehicleType: json['vehicleType'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleYear: json['vehicleYear'] as int?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehicleCapacity: json['vehicleCapacity'] as int? ?? 1,
      vehiclePrice: (json['vehiclePrice'] as num?)?.toDouble() ?? 0.0,
      vehicleImage: json['vehicleImage'] as String?,
      fuelType: json['fuelType'] != null
          ? FuelType.fromJson(json['fuelType'] as String)
          : FuelType.petrol,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transportId': transportId,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehiclePlate': vehiclePlate,
      'vehicleColor': vehicleColor,
      'vehicleCapacity': vehicleCapacity,
      'vehiclePrice': vehiclePrice,
      'vehicleImage': vehicleImage,
      'fuelType': fuelType.toJson(),
      'quantity': quantity,
    };
  }
}