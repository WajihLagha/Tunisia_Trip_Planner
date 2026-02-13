import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tunisian_trip_planner/shared/widgets/next_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/onboarding.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromRGBO(0, 0, 0, 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Discover Tunisia's", style: TextStyle(fontSize: 35,color: Colors.white, fontWeight: FontWeight.bold),),
                    Text("Hidden Gems", style: TextStyle(fontSize: 35,color: HexColor("#56AB91"), fontWeight: FontWeight.bold),),
                    SizedBox(height: 16,),
                    Text("Explore local hotels, guest houses, and \n attractive matched  to your taste",
                      style:TextStyle(color: HexColor("#E0E0E0 "), fontSize: 16) ,
                    ),
                    SizedBox(height: 40,),
                    SmoothPageIndicator(
                      controller: pageController,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Color(0xFF67B99A),
                        dotColor: Color(0xFF9E9E9E),
                        dotHeight: 10,
                        dotWidth: 10,
                        expansionFactor: 3,
                        spacing: 8,
                      ),
                    ),
                    SizedBox(height: 35,),
                    nextButton(),
                  ],
                ),
              ),
          ),
          Positioned(
            right: 30,
            top: 80,
            child: Container(
              height: 40,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black26,
              ),
              child: Center(child: Text("Skip", style: TextStyle(color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }
}
