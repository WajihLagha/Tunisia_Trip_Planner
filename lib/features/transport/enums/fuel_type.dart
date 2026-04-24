enum FuelType {
  PETROL,
  DIESEL,
  ELECTRIC,
  HYBRID;

  static FuelType fromJson(String value) {
    return FuelType.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => FuelType.PETROL,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case FuelType.PETROL:   return 'Petrol';
      case FuelType.DIESEL:   return 'Diesel';
      case FuelType.ELECTRIC: return 'Electric';
      case FuelType.HYBRID:   return 'Hybrid';
    }
  }
}