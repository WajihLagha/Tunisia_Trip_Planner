abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class AuthLoadingState extends AuthStates {}

class AuthSuccessState extends AuthStates {
  final List<String> roles;
  final String? userId;

  AuthSuccessState({required this.roles, this.userId});
}

class AuthErrorState extends AuthStates {
  final String message;

  AuthErrorState(this.message);
}

class AuthUnauthenticatedState extends AuthStates {}
