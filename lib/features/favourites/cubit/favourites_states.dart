abstract class FavouritesStates {}

class FavouritesInitial extends FavouritesStates {}

class FavouritesLoaded extends FavouritesStates {
  final Set<String> favouritePlaceIds;
  final Set<String> favouriteAccommodationIds;
  final Set<String> favouriteTransportIds;

  FavouritesLoaded({
    required this.favouritePlaceIds,
    required this.favouriteAccommodationIds,
    required this.favouriteTransportIds,
  });

  FavouritesLoaded copyWith({
    Set<String>? favouritePlaceIds,
    Set<String>? favouriteAccommodationIds,
    Set<String>? favouriteTransportIds,
  }) {
    return FavouritesLoaded(
      favouritePlaceIds: favouritePlaceIds ?? this.favouritePlaceIds,
      favouriteAccommodationIds:
          favouriteAccommodationIds ?? this.favouriteAccommodationIds,
      favouriteTransportIds:
          favouriteTransportIds ?? this.favouriteTransportIds,
    );
  }
}
