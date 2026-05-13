import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tunisian_trip_planner/core/notifications/notification_service.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/admin/admin_home_layout.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_states.dart';
import 'package:tunisian_trip_planner/features/auth/onboarding_screen.dart';
import 'package:tunisian_trip_planner/features/auth/widgets/login_screen.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_cubit.dart';
import 'package:tunisian_trip_planner/features/home_layout/widgets/home_layout.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_cubit.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/widgets/splash_screen.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_cubit.dart';
import 'package:tunisian_trip_planner/features/bookings/repositories/booking_repository.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Initialize a global instance of AuthCubit
final authCubit = AuthCubit();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with your test publishable key
  Stripe.publishableKey =
      'pk_test_51TKM7QHM6rOm7ObP8RRg5JMisYhEnPJRbjdGmYsYmDOu28AgisZW071e0CJCP5tW4XxFFc2YhWbFPS92ZFaiKXIF009Ik8Dq9z';
  await Stripe.instance.applySettings();

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
    DioHelper.onTokenRefresh = () => authCubit.getValidAccessToken();
    DioHelper.init();
    await Hive.initFlutter();
    await CacheHelper.init();
    await NotificationService.init();

    // ── Check Auth using PKCE & JWT Decoder ──────────────────────────────────
    await authCubit.checkExistingAuth();

    final bool onBoardingDone = CacheHelper.getData('onBoarding') == true;

    // ── Determine start widget ───────────────────────────────────────
    // Condition A: Brand-new user – show onboarding
    if (!onBoardingDone) {
      _startWidget = const OnboardingScreen();
    }
    // Condition B: Authenticated successfully
    else if (authCubit.state is AuthSuccessState) {
      if (authCubit.isAdmin) {
        _startWidget = const AdminHomeLayout();
      } else {
        _startWidget = const HomeLayout();
      }
    }
    // Condition C: Not authenticated
    else {
      _startWidget = const LoginScreen();
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

    // Inject the resolved start widget into MaterialApp
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(
          create:
              (context) =>
                  FavouritesCubit(userId: authCubit.currentUserId)
                    ..loadFavourites(),
        ),
        BlocProvider(
          create: (context) {
            final cubit = BookingCubit(BookingRepository());
            final userId = authCubit.currentUserId;
            if (userId != null) {
              cubit.getUserBookings(userId);
            }
            return cubit;
          },
        ),
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
