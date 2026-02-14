import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tunisian_trip_planner/features/auth/login_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';
import 'package:tunisian_trip_planner/shared/widgets/next_button.dart';

class OnBoardingModel {
  final String title;
  final String title2;
  final String image;
  final String description;

  OnBoardingModel({
    required this.title,
    required this.image,
    required this.description,
    required this.title2,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  bool isLast = false;

  final List<OnBoardingModel> onBoardings = [
    OnBoardingModel(
      title2: "Hidden Gems",
      title: "Discover Tunisia's",
      image: "assets/images/onboarding.jpg",
      description:
      "Explore local hotels, guest houses, and\nattractive matches to your taste",
    ),
    OnBoardingModel(
      title2: "With Ease",
      title: "Rent Vehicles",
      image: "assets/images/onboarding1.jpg",
      description:
      "Book cars and bus tickets instantly to move\naround the city without limits",
    ),
    OnBoardingModel(
      title2: "Trip Plans",
      title: "AI-Powered",
      image: "assets/images/onboarding2.jpg",
      description:
      "Let our smart recommendations build the\nperfect itinerary for you",
    ),
  ];

  // Keep a read of the current page (can be fractional while swiping)
  double currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();

    // set initial page value
    currentPageValue = pageController.initialPage.toDouble();

    // listen to pageController to compute parallax & fade in real time
    pageController.addListener(() {
      if (!mounted) return;
      setState(() {
        // page can be null if no clients yet, so guard
        currentPageValue =
        pageController.hasClients ? pageController.page ?? currentPageValue : currentPageValue;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (isLast) {
      // Use your routing helper to remove onboarding from stack
      // Replace LoginScreen with your actual screen
      navigateAndRemoveAll(context, const LoginScreen());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkipPressed() {
    navigateAndRemoveAll(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        itemCount: onBoardings.length,
        onPageChanged: (index) {
          setState(() {
            isLast = index == onBoardings.length - 1;
          });
        },
        itemBuilder: (context, index) {
          final model = onBoardings[index];

          // compute a relative position of this page to current page for animations:
          // when user is on page 0 and index=1 → delta = 1.0 (page is to right)
          final double delta = (currentPageValue - index);
          // clamp for safety
          final double clamped = delta.clamp(-1.0, 1.0);

          // Parallax offset for the image. Positive delta means this page is left of current,
          // so translate image slightly to the left (subtle parallax).
          final double parallax = clamped * 40; // tweak 40 for stronger/weaker parallax

          // Opacity for text and button: full when page is centered (delta=0), fade as abs(delta) increases
          final double textOpacity = (1.0 - clamped.abs()).clamp(0.0, 1.0);

          // Slight vertical slide for text as it fades
          final double textSlideY = (clamped.abs() * 20);

          return Stack(
            children: [
              // Parallax Background Image
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(parallax, 0),
                  child: Image.asset(
                    model.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Gradient overlay and content
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromRGBO(0, 0, 0, 0.9),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Title (two lines with different colors) -> fade + slide
                      Opacity(
                        opacity: textOpacity,
                        child: Transform.translate(
                          offset: Offset(0, textSlideY),
                          child: Column(
                            children: [
                              Text(
                                model.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                model.title2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  color: HexColor("#56AB91"),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Opacity(
                        opacity: textOpacity,
                        child: Transform.translate(
                          offset: Offset(0, textSlideY),
                          child: Text(
                            model.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HexColor("#E0E0E0"),
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Page indicator
                      Opacity(
                        opacity: textOpacity,
                        child: SmoothPageIndicator(
                          controller: pageController,
                          count: onBoardings.length,
                          effect: const ExpandingDotsEffect(
                            activeDotColor: Color(0xFF67B99A),
                            dotColor: Color(0xFF9E9E9E),
                            dotHeight: 10,
                            dotWidth: 10,
                            expansionFactor: 3,
                            spacing: 8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Next button (keeps same fade)
                      Opacity(
                        opacity: textOpacity,
                        child: nextButton(
                          onTap: _onNextPressed,
                          // Optionally change label based on isLast inside your nextButton implementation,
                          // or receive a parameter. If nextButton doesn't support text change, keep visual as is.
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Skip button top-right
              Positioned(
                right: 30,
                top: 70,
                child: GestureDetector(
                  onTap: _onSkipPressed,
                  child: Container(
                    height: 40,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black26,
                    ),
                    child: const Center(
                      child: Text(
                        "Skip",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

