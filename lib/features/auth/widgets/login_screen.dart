import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_states.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/widgets/privacy_screen.dart';
import 'package:tunisian_trip_planner/features/auth/widgets/register_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/components.dart';
import 'package:tunisian_trip_planner/features/home_layout/widgets/home_layout.dart';
import 'package:tunisian_trip_planner/features/admin/admin_home_layout.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the global AuthCubit injected by main.dart via BlocProvider.value.
    // Do NOT create a new local BlocProvider here — that would produce a second
    // isolated cubit whose authenticated state never propagates to the rest of
    // the app (global cubit would still have currentUserId == null).
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          final cubit = AuthCubit.get(context);
          final userId = cubit.currentUserId;
          if (userId != null) {
            BookingCubit.get(context).getUserBookings(userId);
          }
          if (cubit.isAdmin) {
            navigateAndRemoveAll(context, const AdminHomeLayout());
          } else {
            navigateAndRemoveAll(context, const HomeLayout());
          }
        }
        if (state is AuthErrorState) {
          showToast(msg: state.message, state: ToastStates.error);
        }
      },
      builder: (context, state) {
        final cubit = AuthCubit.get(context);
        final isLoading = state is AuthLoadingState;

        return Scaffold(
          backgroundColor: HexColor('#14746f'),
          body: Stack(
            children: [
              // ── Top gradient background ──────────────────────────────
              Container(
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HexColor('#14746f'), HexColor('#036666')],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28, right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'New here?',
                          style: GoogleFonts.dmSans(
                            color: Colors.grey.shade300,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(9),
                          onTap: () => navigateTo(context, RegisterScreen()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF5C9A9C,
                              ).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main scrollable content ──────────────────────────────
              CustomScrollView(
                slivers: [
                  // Logo area
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Image.asset(
                            'assets/images/logo_login.png',
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 35),
                          height: 15,
                          decoration: BoxDecoration(
                            color: HexColor('#469D89'),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(80),
                              topLeft: Radius.circular(80),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White card area
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 36, 25, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Welcome to TuniWays',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: HexColor('#14746f'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to continue your journey',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── Username field ─────────────────────────
                            Text(
                              'Username or Email',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                hint: 'your@email.com',
                                icon: Icons.person_outline_rounded,
                              ),
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Please enter your username or email'
                                          : null,
                            ),
                            const SizedBox(height: 20),

                            // ── Password field ─────────────────────────
                            Text(
                              'Password',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(context, cubit),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () =>
                                            _obscurePassword =
                                                !_obscurePassword,
                                      ),
                                ),
                              ),
                              validator:
                                  (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Please enter your password'
                                          : null,
                            ),
                            const SizedBox(height: 32),

                            // ── Sign in button ─────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => _submit(context, cubit),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#14746f'),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: HexColor(
                                    '#14746f',
                                  ).withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                  shadowColor: HexColor(
                                    '#14746f',
                                  ).withValues(alpha: 0.3),
                                ),
                                child:
                                    isLoading
                                        ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                        : Text(
                                          'Sign In',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                              ),
                            ),

                            const Spacer(),

                            // ── Privacy footer ─────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'By continuing, you agree to our',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showPrivacy(context),
                                    child: Text(
                                      'Privacy Policy',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        color: HexColor('#036666'),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
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
    );
  }

  void _submit(BuildContext context, AuthCubit cubit) {
    if (_formKey.currentState!.validate()) {
      cubit.loginWithPassword(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: HexColor('#14746f'), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: HexColor('#14746f'), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder:
                (ctx, controller) =>
                    PrivacyScreen(scrollController: controller),
          ),
    );
  }
}
