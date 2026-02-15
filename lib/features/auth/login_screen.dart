import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tunisian_trip_planner/features/auth/login_cubit/login_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/login_cubit/login_states.dart';
import 'package:tunisian_trip_planner/features/auth/privacy_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/components.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {},
        builder: (context, state) {
          LoginCubit cubit = LoginCubit.get(context);
          bool isShown = cubit.isShown;
          return Scaffold(
            backgroundColor: HexColor("#14746f"),
            body: Stack(
              children: [
                // 1. Top Gradient Background (Fixed)
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HexColor("#14746f"), HexColor("#036666")],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // 2. The Scrollable Content
                CustomScrollView(
                  slivers: [
                    // Part A: The Top Header (Logo, Get Started button)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                "Don't have account?",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(width: 5),

                              Container(
                                height: 40,
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsetsDirectional.only(
                                  end: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Get Started",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Image.asset(
                              "assets/images/logo_login.png",
                              height: 160,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // The small bridge connector
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            height: 15,
                            decoration: BoxDecoration(
                              color: HexColor("#469D89"),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(80),
                                topLeft: Radius.circular(80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Part B: The White Container (Fills remaining space)
                    SliverFillRemaining(
                      hasScrollBody: false, // This allows Spacer() to work!
                      child: Container(
                        padding: const EdgeInsets.only(top: 20, left: 25,right: 25),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Enter your details below",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Inputs
                              defaultInputField(
                                controler: nameController,
                                keybord: TextInputType.name,
                                text: "Full name",
                                maxLine: 1,
                                prefix: Icons.person_outline_outlined,
                                prefixColor: Colors.teal,
                              ),

                              const SizedBox(height: 20),
                              defaultInputField(
                                controler: passwordController,
                                keybord: TextInputType.text,
                                text: "Password",
                                sufix:
                                    isShown
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                obsecure: isShown,
                                prefix: Icons.lock_outline,
                                sufixFunction: () {
                                  cubit.changePasswordVisibility();
                                },
                              ),

                              const SizedBox(height: 30),

                              // Sign In Button
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      HexColor("#14746f"),
                                      HexColor("#469d89"),
                                      HexColor("#78c6a3"),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forgot your password?",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),

                              const Spacer(),

                              // Privacy Section
                              Column(
                                children: [
                                  const Text(
                                    "By continuing, you agree to our",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        showDragHandle: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) {
                                          return DraggableScrollableSheet(
                                            initialChildSize: 0.5,
                                            minChildSize: 0.5,
                                            maxChildSize: 1.0,
                                            builder: (
                                              context,
                                              scrollController,
                                            ) {
                                              return PrivacyScreen(
                                                scrollController:
                                                    scrollController,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        color: HexColor("#036666"),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Add padding for bottom safe area
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
