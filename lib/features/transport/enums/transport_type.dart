enum TransportType {
  taxi,
  carRental,
  bus,
  other;

  static TransportType fromJson(String value) {
    return TransportType.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase().replaceAll('_', ''),
      orElse: () => TransportType.other,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case TransportType.taxi:       return 'Taxi';
      case TransportType.carRental: return 'Car Rental';
      case TransportType.bus:        return 'Bus';
      case TransportType.other:      return 'Other';
    }
  }
}