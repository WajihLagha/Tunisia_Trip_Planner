enum TransportType {
  TAXI,
  CAR_RENTAL,
  BUS,
  OTHER;

  static TransportType fromJson(String value) {
    return TransportType.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => TransportType.OTHER,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case TransportType.TAXI:       return 'Taxi';
      case TransportType.CAR_RENTAL: return 'Car Rental';
      case TransportType.BUS:        return 'Bus';
      case TransportType.OTHER:      return 'Other';
    }
  }
}