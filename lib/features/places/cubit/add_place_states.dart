abstract class AddPlaceStates {}

class AddPlaceInitial extends AddPlaceStates {}

class AddPlaceImageSelected extends AddPlaceStates {}

class AddPlaceLoading extends AddPlaceStates {}

class AddPlaceSuccess extends AddPlaceStates {}

class AddPlaceError extends AddPlaceStates {
  final String message;
  AddPlaceError(this.message);
}
