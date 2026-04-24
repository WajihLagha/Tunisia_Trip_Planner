abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates {}

class ProfileThemeChangedState extends ProfileStates {
  final bool isDarkMode;
  ProfileThemeChangedState(this.isDarkMode);
}
