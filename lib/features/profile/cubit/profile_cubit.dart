import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());

  static ProfileCubit get(context) => BlocProvider.of(context);

  bool isDarkMode = false;

  void toggleTheme(bool value) {
    isDarkMode = value;
    emit(ProfileThemeChangedState(isDarkMode));
  }

  void logout() {
    // TODO: implement logout logic
  }
}
