import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tunisian_trip_planner/features/auth/register_cubit/register_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/register_cubit/register_state.dart';
import 'package:tunisian_trip_planner/shared/widgets/components.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          // Handle Success/Error logic here
        },
        builder: (context, state) {
          var cubit = RegisterCubit.get(context);

          return Scaffold(
            backgroundColor: HexColor("#14746f"),
            body: Stack(
              children: [
                // 1. Top Gradient Background
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

                // 2. Scrollable Content
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          // Back Button & Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                ),
                                const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, left: 25, right: 25, bottom: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Join TuniWays",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Start your journey with us today",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // --- NAME INPUT ---
                              defaultInputField(
                                controler: nameController,
                                keybord: TextInputType.name,
                                text: "Full Name",
                                prefix: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // --- EMAIL INPUT ---
                              defaultInputField(
                                controler: emailController,
                                keybord: TextInputType.emailAddress,
                                text: "Email Address",
                                prefix: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Invalid email format';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // --- PASSWORD INPUT ---
                              defaultInputField(
                                controler: passwordController,
                                keybord: TextInputType.visiblePassword,
                                text: "Password",
                                obsecure: cubit.isPasswordShown,
                                prefix: Icons.lock_outline,
                                sufix: cubit.isPasswordShown
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                sufixFunction: () {
                                  cubit.changePasswordVisibility();
                                },
                                onChange: (value) {
                                  cubit.checkPasswordStrength(value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password is too short';
                                  }
                                  return null;
                                },
                              ),

                              // --- PASSWORD STRENGTH INDICATOR ---
                              if (passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _buildStrengthIndicator(cubit.passwordStrengthLevel),
                              ],

                              const SizedBox(height: 20),

                              // --- CONFIRM PASSWORD INPUT ---
                              defaultInputField(
                                controler: confirmPasswordController,
                                keybord: TextInputType.visiblePassword,
                                text: "Confirm Password",
                                obsecure: cubit.isConfirmShown,
                                prefix: Icons.lock_reset,
                                sufix: cubit.isConfirmShown
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                sufixFunction: () {
                                  cubit.changeConfirmVisibility();
                                },
                                validator: (value) {
                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 40),

                              // --- SIGN UP BUTTON ---
                              GestureDetector(
                                onTap: () {
                                  if (formKey.currentState!.validate()) {
                                    // Perform Registration Logic
                                    print("Register Validated");
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        HexColor("#14746f"),
                                        HexColor("#469d89"),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: HexColor("#14746f").withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Create Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an account? "),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: HexColor("#14746f"),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
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

  // Helper Widget for Password Strength
  Widget _buildStrengthIndicator(int level) {
    Color color;
    String text;
    double widthFactor;

    switch (level) {
      case 1:
        color = Colors.red;
        text = "Weak";
        widthFactor = 0.33;
        break;
      case 2:
        color = Colors.orange;
        text = "Medium";
        widthFactor = 0.66;
        break;
      case 3:
        color = Colors.green;
        text = "Strong";
        widthFactor = 1.0;
        break;
      default:
        color = Colors.grey;
        text = "";
        widthFactor = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}