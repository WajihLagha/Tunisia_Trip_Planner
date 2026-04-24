import 'package:tunisian_trip_planner/features/transport/models/transport_model.dart';

abstract class TransportStates {}

class TransportInitialState extends TransportStates {}

class TransportLoadingState extends TransportStates {}

class TransportLoadedState extends TransportStates {
  final List<TransportModel> transports;
  final String selectedCity;

  TransportLoadedState({
    required this.transports,
    required this.selectedCity,
  });
}

class TransportErrorState extends TransportStates {
  final String message;

  TransportErrorState(this.message);
}
