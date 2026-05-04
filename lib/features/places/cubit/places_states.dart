import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';

abstract class PlacesStates {}

class PlacesInitialState extends PlacesStates {}

class PlacesLoadingState extends PlacesStates {}

class PlacesLoadedState extends PlacesStates {
  final List<PlacesResponse> places;
  final List<PlacesResponse> filteredPlaces;
  final PlacesCategory? selectedCategory;
  final double minRating;

  PlacesLoadedState({
    required this.places,
    required this.filteredPlaces,
    this.selectedCategory,
    this.minRating = 0.0,
  });
}

class PlacesErrorState extends PlacesStates {
  final String message;
  PlacesErrorState(this.message);
}
