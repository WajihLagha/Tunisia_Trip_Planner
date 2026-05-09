import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';

abstract class AccommodationStates {}

class AccommodationInitialState extends AccommodationStates {}

class AccommodationLoadingState extends AccommodationStates {}

class AccommodationSearchingState extends AccommodationStates {}

class AccommodationLoadedState extends AccommodationStates {
  final List<AccommodationDto> accommodations;
  final List<AccommodationDto> filteredAccommodations;

  AccommodationLoadedState({
    required this.accommodations,
    required this.filteredAccommodations,
  });
}

class AccommodationSearchLoadedState extends AccommodationStates {
  final List<AccommodationDto> filteredAccommodations;

  AccommodationSearchLoadedState({required this.filteredAccommodations});
}

class AccommodationErrorState extends AccommodationStates {
  final String message;
  AccommodationErrorState(this.message);
}
