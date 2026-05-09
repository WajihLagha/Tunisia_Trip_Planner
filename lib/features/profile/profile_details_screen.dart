import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_cubit.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        final cubit = ProfileCubit.get(context);
        final isDark = cubit.isDarkMode;
        final cs = isDark ? darkTheme.colorScheme : lightTheme.colorScheme;
        final user = cubit.user;

        return Scaffold(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            elevation: 0,
            iconTheme: IconThemeData(color: cs.onSurface),
            title: Text(
              'Profile Details',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          body: user == null
              ? Center(child: CircularProgressIndicator(color: cs.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, isDark, cs, cubit.selectedProfileImage, user.userName, user.email),
                      const SizedBox(height: 32),
                      _buildSectionTitle('PERSONAL INFO', isDark),
                      const SizedBox(height: 16),
                      _buildInfoCard(isDark, cs, [
                        _buildInfoRow('Phone', user.phoneNumber ?? 'Not set', Icons.phone_outlined, cs, isDark),
                        _buildDivider(isDark),
                        _buildInfoRow('Address', user.address ?? 'Not set', Icons.location_on_outlined, cs, isDark),
                        _buildDivider(isDark),
                        _buildInfoRow('Age Group', user.ageGroup ?? 'Not set', Icons.cake_outlined, cs, isDark),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('TRAVEL PREFERENCES', isDark),
                      const SizedBox(height: 16),
                      _buildInfoCard(isDark, cs, [
                        _buildInfoRow('Group Size', user.groupSize ?? 'Not set', Icons.group_outlined, cs, isDark),
                        _buildDivider(isDark),
                        _buildInfoRow('Budget', user.budget ?? 'Not set', Icons.account_balance_wallet_outlined, cs, isDark),
                        _buildDivider(isDark),
                        _buildInfoRow('Transport', user.transportType ?? 'Not set', Icons.directions_car_outlined, cs, isDark),
                        _buildDivider(isDark),
                        _buildInfoRow('Accommodation', user.accommodationType ?? 'Not set', Icons.hotel_outlined, cs, isDark),
                      ]),
                      if (user.travelStyles != null && user.travelStyles!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('TRAVEL STYLES', isDark),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.travelStyles!.map((style) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                style,
                                style: GoogleFonts.dmSans(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, ColorScheme cs, String imagePath, String? name, String? email) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary, width: 3),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : cs.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name ?? 'Guest User',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email ?? 'No email provided',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: isDark ? AppColors.onSurfaceDark.withValues(alpha: 0.6) : AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: isDark ? AppColors.onSurfaceDark.withValues(alpha: 0.4) : AppColors.mutedText.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, ColorScheme cs, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.green800.withValues(alpha: 0.3) : AppColors.green100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isDark ? AppColors.onSurfaceDark.withValues(alpha: 0.5) : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      color: isDark ? Colors.white24 : AppColors.borderColor,
    );
  }
}
