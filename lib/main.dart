import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tunisian_trip_planner/modules/onboardingScreen.dart';
import 'package:tunisian_trip_planner/modules/splash_screen.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await DioHelper.inti();

  await Hive.initFlutter();
  await CacheHelper.init();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TuniWays',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins.toString(),
        primaryColor: HexColor("#67b99a"),
        primarySwatch: Colors.teal,
      ),
      home: OnboardingScreen(),
    );
  }
}


