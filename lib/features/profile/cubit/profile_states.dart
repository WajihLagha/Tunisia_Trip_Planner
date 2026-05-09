import 'package:tunisian_trip_planner/features/profile/models/user_model.dart';

abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates {}

class ProfileThemeChangedState extends ProfileStates {
  final bool isDarkMode;
  ProfileThemeChangedState(this.isDarkMode);
}

class ProfileLoadingState extends ProfileStates {}

class ProfileLoadedState extends ProfileStates {
  final UserModel user;
  ProfileLoadedState(this.user);
}

class ProfileErrorState extends ProfileStates {
  final String message;
  ProfileErrorState(this.message);
}

class ProfileImageUpdatedState extends ProfileStates {}
