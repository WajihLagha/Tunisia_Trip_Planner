// room_type.dart
enum RoomType {
  single,
  double,
  suite,
  family,
  other;

  static RoomType fromString(String value) =>
      RoomType.values.firstWhere(
            (e) => e.name.toUpperCase() == value.toUpperCase(),
        orElse: () => RoomType.single,
      );

  String toJson() => name.toUpperCase();
}