enum FuelType {
  petrol,
  diesel,
  electric,
  hybrid;

  static FuelType fromJson(String value) {
    return FuelType.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => FuelType.petrol,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case FuelType.petrol:   return 'Petrol';
      case FuelType.diesel:   return 'Diesel';
      case FuelType.electric: return 'Electric';
      case FuelType.hybrid:   return 'Hybrid';
    }
  }
}