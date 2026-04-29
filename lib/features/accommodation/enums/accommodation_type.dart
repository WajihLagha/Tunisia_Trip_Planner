// accommodation_type.dart
enum AccommodationType {
  hotel,
  motel,
  apartment,
  villa,
  guesthouse;

  static AccommodationType fromString(String value) =>
      AccommodationType.values.firstWhere(
            (e) => e.name.toUpperCase() == value.toUpperCase(),
        orElse: () => AccommodationType.hotel,
      );

  String toJson() => name.toUpperCase();
}