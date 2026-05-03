import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tunisian_trip_planner/core/notifications/notification_service.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/home_layout/widgets/home_layout.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_cubit.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DioHelper.inti();

  await Hive.initFlutter();
  await CacheHelper.init();

  // Initialise local notifications
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Schedule re-engagement notifications on first launch
    NotificationService.scheduleReEngagement();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Re-schedule whenever the user comes back to the app
      NotificationService.scheduleReEngagement();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          final cubit = ProfileCubit.get(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TuniWays',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: cubit.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeLayout(),
          );
        },
      ),
    );
  }
}
