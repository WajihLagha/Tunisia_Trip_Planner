import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tunisian_trip_planner/core/notifications/notification_service.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/auth/onboarding_screen.dart';
import 'package:tunisian_trip_planner/features/auth/widgets/login_screen.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_cubit.dart';
import 'package:tunisian_trip_planner/features/home_layout/widgets/home_layout.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_cubit.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _initialized = false;
  Widget _startWidget = const SplashScreen();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for at least 2 seconds for the splash animation to feel right
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _performInit(),
    ]);

    if (mounted) {
      setState(() {
        _initialized = true;
      });
      NotificationService.scheduleReEngagement();
    }
  }

  Future<void> _performInit() async {
    DioHelper.init();
    await Hive.initFlutter();
    await CacheHelper.init();
    await NotificationService.init();

    // ── Step 2: Retrieve state from cache ────────────────────────────────────
    final bool onBoardingDone = CacheHelper.getData('onBoarding') == true;
    final String? token = CacheHelper.getData('token') as String?;

    // ── Step 3: Determine start widget ───────────────────────────────────────
    // Condition A: Brand-new user – show onboarding
    if (!onBoardingDone) {
      _startWidget = const OnboardingScreen();
    }
    // Condition B: Seen intro but not logged in – go to login
    else if (token == null || token.isEmpty) {
      _startWidget = LoginScreen();
    }
    // Condition C: Already authenticated – go straight to home
    else {
      // ── Step 5: Inject token globally into DioHelper ──────────────────────
      DioHelper.setToken(token);
      _startWidget = const HomeLayout();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _initialized) {
      NotificationService.scheduleReEngagement();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash while initialising
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    // ── Step 4: Inject the resolved start widget into MaterialApp ─────────────
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => FavouritesCubit()..loadFavourites()),
      ],
      child: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          final cubit = ProfileCubit.get(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TuniWays',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: cubit.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: _startWidget,
          );
        },
      ),
    );
  }
}
