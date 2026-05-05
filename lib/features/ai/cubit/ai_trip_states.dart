import 'package:tunisian_trip_planner/features/ai/models/ai_itinerary.dart';

abstract class AiTripStates {}

class AiTripInitial extends AiTripStates {}

class AiTripFormUpdated extends AiTripStates {}

class AiTripLoading extends AiTripStates {}

class AiTripSuccess extends AiTripStates {
  final AiItinerary itinerary;
  AiTripSuccess(this.itinerary);
}

class AiTripError extends AiTripStates {
  final String message;
  AiTripError(this.message);
}
