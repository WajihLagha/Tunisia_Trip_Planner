// vehicle_model.dart

import 'package:tunisian_trip_planner/features/transport/enums/fuel_type.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_availability_model.dart';

class VehicleModel {
  final int? id;
  final int? transportId;
  final String vehicleType;
  final String vehicleModel;
  final int? vehicleYear;
  final String? vehiclePlate;
  final String? vehicleColor;
  final int? vehicleCapacity;
  final double? vehiclePrice;
  final String? vehicleImage;
  final FuelType? fuelType;
  final int? quantity;
  final List<VehicleAvailabilityModel> availabilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleModel({
    this.id,
    this.transportId,
    required this.vehicleType,
    required this.vehicleModel,
    this.vehicleYear,
    this.vehiclePlate,
    this.vehicleColor,
    this.vehicleCapacity,
    this.vehiclePrice,
    this.vehicleImage,
    this.fuelType,
    this.quantity,
    this.availabilities = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int?,
      transportId: json['transportId'] as int?,
      vehicleType: (json['vehicleType'] as String?) ?? '',
      vehicleModel: (json['vehicleModel'] as String?) ?? '',
      vehicleYear: json['vehicleYear'] as int?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehicleCapacity: json['vehicleCapacity'] as int?,
      vehiclePrice: (json['vehiclePrice'] as num?)?.toDouble(),
      vehicleImage: json['vehicleImage'] as String?,
      fuelType: json['fuelType'] != null
          ? FuelType.fromJson(json['fuelType'] as String)
          : null,
      quantity: json['quantity'] as int?,
      availabilities: (json['availabilities'] as List<dynamic>?)
          ?.map((e) => VehicleAvailabilityModel.fromJson(
          e as Map<String, dynamic>))
          .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  static List<VehicleModel> fromJsonList(List<dynamic> jsonList) =>
      jsonList
          .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (transportId != null) 'transportId': transportId,
    'vehicleType': vehicleType,
    'vehicleModel': vehicleModel,
    if (vehicleYear != null) 'vehicleYear': vehicleYear,
    if (vehiclePlate != null) 'vehiclePlate': vehiclePlate,
    if (vehicleColor != null) 'vehicleColor': vehicleColor,
    if (vehicleCapacity != null) 'vehicleCapacity': vehicleCapacity,
    if (vehiclePrice != null) 'vehiclePrice': vehiclePrice,
    if (vehicleImage != null) 'vehicleImage': vehicleImage,
    if (fuelType != null) 'fuelType': fuelType!.toJson(),
    if (quantity != null) 'quantity': quantity,
    'availabilities': availabilities.map((e) => e.toJson()).toList(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  VehicleModel copyWith({
    int? id,
    int? transportId,
    String? vehicleType,
    String? vehicleModel,
    int? vehicleYear,
    String? vehiclePlate,
    String? vehicleColor,
    int? vehicleCapacity,
    double? vehiclePrice,
    String? vehicleImage,
    FuelType? fuelType,
    int? quantity,
    List<VehicleAvailabilityModel>? availabilities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      VehicleModel(
        id: id ?? this.id,
        transportId: transportId ?? this.transportId,
        vehicleType: vehicleType ?? this.vehicleType,
        vehicleModel: vehicleModel ?? this.vehicleModel,
        vehicleYear: vehicleYear ?? this.vehicleYear,
        vehiclePlate: vehiclePlate ?? this.vehiclePlate,
        vehicleColor: vehicleColor ?? this.vehicleColor,
        vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
        vehiclePrice: vehiclePrice ?? this.vehiclePrice,
        vehicleImage: vehicleImage ?? this.vehicleImage,
        fuelType: fuelType ?? this.fuelType,
        quantity: quantity ?? this.quantity,
        availabilities: availabilities ?? this.availabilities,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// true if at least one availability slot is marked available.
  bool get isAvailable =>
      availabilities.any((a) => a.isAvailable == true);

  String get fuelTypeLabel => fuelType?.label ?? '—';

  String get formattedPrice => vehiclePrice != null
      ? '${vehiclePrice!.toStringAsFixed(2)} TND / day'
      : 'Price not set';

  String get imageOrPlaceholder =>
      (vehicleImage != null && vehicleImage!.isNotEmpty)
          ? vehicleImage!
          : 'https://via.placeholder.com/400x240?text=Vehicle';

  @override
  String toString() =>
      'VehicleModel(id: $id, model: $vehicleModel, year: $vehicleYear)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VehicleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}