import 'package:tunisian_trip_planner/features/auth/models/login_model.dart';

abstract class LoginState{}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginModel loginModel;
  LoginSuccess(this.loginModel);
}

class LoginError extends LoginState {
  final String error;
  LoginError(this.error);
}

class LoginShowPasswordState extends LoginState{}