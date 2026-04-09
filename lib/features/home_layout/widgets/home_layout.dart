import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/booking_screen.dart';
import 'package:tunisian_trip_planner/features/home_layout/cubit/home_cubit.dart';
import 'package:tunisian_trip_planner/features/home_layout/cubit/home_states.dart';
import 'package:tunisian_trip_planner/features/home_layout/widgets/trip_nav_bar.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (BuildContext context) => HomeCubit(),
      child: BlocConsumer<HomeCubit,HomeStates>(
        listener: (context, state) {

        },
        builder: (context, state) {
          final cubit = HomeCubit.get(context);
          return Scaffold(
            extendBody: true,
            body: cubit.bottomScreen[cubit.currentIndex],
            bottomNavigationBar: TripBottomNavBar(
                currentIndex: cubit.currentIndex,
                onTap: cubit.changeTripNavBar,
                onFabTap: () {
                  navigateTo(context, BookingScreen());
                },
            ),
          );
        },
      ),
    );
  }
}
