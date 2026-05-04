abstract class AddStayStates {}

class AddStayInitial extends AddStayStates {}

class AddStayImageSelected extends AddStayStates {}

class AddStayLoading extends AddStayStates {}

class AddStaySuccess extends AddStayStates {}

class AddStayError extends AddStayStates {
  final String message;
  AddStayError(this.message);
}
