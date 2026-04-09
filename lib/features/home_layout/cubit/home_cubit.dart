import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/cars_screen.dart';
import 'package:tunisian_trip_planner/features/explore_screen.dart';
import 'package:tunisian_trip_planner/features/favourite_screen.dart';
import 'package:tunisian_trip_planner/features/home_layout/cubit/home_states.dart';
import 'package:tunisian_trip_planner/features/profile_screen.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> bottomScreen = [
    const ExploreScreen(),
    const FavouriteScreen(),
    const CarsScreen(),
    const ProfileScreen(),
  ];

  void changeTripNavBar(index) {
    currentIndex = index;
    emit(ChangeButtomNavbarState());
  }
}
