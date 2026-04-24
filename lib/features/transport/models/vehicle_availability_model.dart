class VehicleAvailabilityModel {
  final int? id;
  final int? vehicleId;
  final bool? isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleAvailabilityModel({
    this.id,
    this.vehicleId,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return VehicleAvailabilityModel(
      id: json['id'] as int?,
      vehicleId: json['vehicleId'] as int?,
      isAvailable: json['isAvailable'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  static List<VehicleAvailabilityModel> fromJsonList(List<dynamic> jsonList) =>
      jsonList
          .map((e) => VehicleAvailabilityModel.fromJson(e as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (vehicleId != null) 'vehicleId': vehicleId,
    if (isAvailable != null) 'isAvailable': isAvailable,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  VehicleAvailabilityModel copyWith({
    int? id,
    int? vehicleId,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      VehicleAvailabilityModel(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        isAvailable: isAvailable ?? this.isAvailable,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'VehicleAvailabilityModel(id: $id, vehicleId: $vehicleId, isAvailable: $isAvailable)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VehicleAvailabilityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}