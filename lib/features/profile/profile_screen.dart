import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_cubit.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';
import 'package:tunisian_trip_planner/features/favourite_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          final cubit = ProfileCubit.get(context);
          // For local UI purposes, use the cubit's dark mode state
          // if we want to preview dark mode in the profile screen itself
          final isDark = cubit.isDarkMode;
          final cs = isDark ? darkTheme.colorScheme : lightTheme.colorScheme;
          
          return Scaffold(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            body: Column(
              children: [
                _buildHeader(context, isDark, cs),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Details',
                        onTap: () {},
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'My Bookings',
                        onTap: () {},
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Favorites',
                        onTap: () {
                          navigateTo(context, const FavouriteScreen());
                        },
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Methods',
                        onTap: () {},
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      
                      // Theme Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantD : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : AppColors.green500.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          title: Text(
                            'Dark Mode',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? AppColors.green800.withValues(alpha: 0.3)
                                  : AppColors.green100.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.dark_mode_outlined,
                              color: cs.primary,
                              size: 22,
                            ),
                          ),
                          value: cubit.isDarkMode,
                          onChanged: (val) => cubit.toggleTheme(val),
                          activeThumbColor: Colors.white,
                          activeTrackColor: cs.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.borderColor,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Logout Button
                      SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            cubit.logout();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorColor,
                            side: BorderSide(
                              color: AppColors.errorColor.withValues(alpha: 0.5), 
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Log Out',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.green900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // App bar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {},
                ),
                Text(
                  'Profile',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                _buildCircularIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/default_profile.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1F),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            'Sarah Ben Ali',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            'sarah.b@example.com',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantD : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.green500.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.green800.withValues(alpha: 0.3)
                    : AppColors.green100.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
