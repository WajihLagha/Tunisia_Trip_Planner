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
          final isDark = cubit.isDarkMode;
          final cs = isDark ? darkTheme.colorScheme : lightTheme.colorScheme;

          return Scaffold(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            body: CustomScrollView(
              slivers: [
                // ── Collapsing Header ─────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ProfileHeaderDelegate(
                    isDark: isDark,
                    cs: cs,
                    statusBarHeight: MediaQuery.of(context).padding.top,
                  ),
                ),

                // ── Stats row ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildStatsRow(isDark),
                ),

                // ── Menu items ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      // ── ACCOUNT section ─────────────────────────────────
                      _buildSectionTitle('ACCOUNT', isDark),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'My Bookings',
                        onTap: () {},
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: '2 unread',
                        onTap: () {},
                        cs: cs,
                        isDark: isDark,
                        showBadge: true,
                      ),

                      const SizedBox(height: 24),

                      // ── PREFERENCES section ──────────────────────────────
                      _buildSectionTitle('PREFERENCES', isDark),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Favorites',
                        onTap: () {
                          navigateTo(context, const FavouriteScreen());
                        },
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {},
                        cs: cs,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 24),

                      // ── SUPPORT section ──────────────────────────────────
                      _buildSectionTitle('SUPPORT', isDark),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.groups_outlined,
                        title: 'Contact Us',
                        subtitle: 'Meet the team',
                        onTap: () => _showContactPanel(context, isDark, cs),
                        cs: cs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),

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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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

                      const SizedBox(height: 32),

                      // Logout Button
                      SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => cubit.logout(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorColor,
                            side: BorderSide(
                              color: AppColors.errorColor.withValues(alpha: 0.3),
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

                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'App Version 2.4.0',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                                : AppColors.mutedText.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Show contact us panel ──────────────────────────────────────────────────
  void _showContactPanel(BuildContext context, bool isDark, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContactUsSheet(isDark: isDark, cs: cs),
    );
  }

  // ── Stats container ────────────────────────────────────────────────────────
  Widget _buildStatsRow(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      transform: Matrix4.translationValues(0, -20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.green500.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.green800.withValues(alpha: 0.3)
              : AppColors.borderColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem('BOOKINGS', '12', isDark),
          _buildDivider(isDark),
          _buildStatItem('REVIEWS', '5', isDark),
          _buildDivider(isDark),
          _buildStatItem('SAVED', '8', isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isDark
                  ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
                  : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      color: isDark
          ? AppColors.green800.withValues(alpha: 0.4)
          : AppColors.borderColor,
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: isDark
              ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
              : AppColors.mutedText.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required ColorScheme cs,
    required bool isDark,
    bool showBadge = false,
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
              child: Icon(icon, color: cs.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
                            : AppColors.mutedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showBadge)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.errorColor,
                  shape: BoxShape.circle,
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

// ── Global navigator key (used to navigate from the sliver context) ───────────
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ─────────────────────────────────────────────────────────────────────────────
//  Collapsing Profile Header Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final ColorScheme cs;
  final double statusBarHeight;

  const _ProfileHeaderDelegate({
    required this.isDark,
    required this.cs,
    required this.statusBarHeight,
  });

  @override
  double get minExtent => statusBarHeight + 62;

  @override
  double get maxExtent => statusBarHeight + 216;

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate old) =>
      old.isDark != isDark || old.statusBarHeight != statusBarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final screenWidth = MediaQuery.of(context).size.width;

    // ── Avatar ─────────────────────────────────────────────────────────
    final avatarSize = lerpDouble(90.0, 42.0, t)!;
    final centeredLeft = (screenWidth - avatarSize) / 2;
    const collapsedLeft = 20.0;
    final avatarLeft = lerpDouble(centeredLeft, collapsedLeft, t)!;
    final expandedAvatarTop = statusBarHeight + 16.0;
    final collapsedAvatarTop = (minExtent - statusBarHeight - avatarSize) / 2 + statusBarHeight;
    final avatarTop = lerpDouble(expandedAvatarTop, collapsedAvatarTop, t)!;

    // ── Text positions ─────────────────────────────────────────────────
    final nameFontSize = lerpDouble(20.0, 15.0, t)!;
    final expandedNameTop = expandedAvatarTop + 90 + 10;
    final collapsedNameTop = collapsedAvatarTop + 2;
    final nameTop = lerpDouble(expandedNameTop, collapsedNameTop, t)!;

    // ── Opacities ──────────────────────────────────────────────────────
    // Centered name/email fades out; collapsed title fades in
    final expandedOpacity = (1.0 - t * 1.8).clamp(0.0, 1.0);
    final collapsedOpacity = ((t - 0.5) * 2).clamp(0.0, 1.0);
    final editOpacity = (1.0 - t * 3).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.green900,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(80),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          Positioned(
            top: avatarTop,
            left: avatarLeft,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/default_profile.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (editOpacity > 0)
                  Opacity(
                    opacity: editOpacity,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B1F),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // ── Name (centered, fades out) ───────────────────────────────
          if (expandedOpacity > 0)
            Positioned(
              top: nameTop,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: expandedOpacity,
                child: Text(
                  'Sarah Ben Ali',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // ── Email (centered, fades out faster) ──────────────────────
          if (expandedOpacity > 0)
            Positioned(
              top: expandedNameTop + 26,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: expandedOpacity,
                child: Text(
                  'sarah.b@example.com',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),

          // ── Collapsed: "My Profile" title beside avatar ──────────────
          if (collapsedOpacity > 0)
            Positioned(
              top: collapsedAvatarTop,
              left: collapsedLeft + 42 + 14,
              child: Opacity(
                opacity: collapsedOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'My Profile',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Sarah Ben Ali',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Simple linear interpolation helper
double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

// ─────────────────────────────────────────────────────────────────────────────
//  Contact Method data model
// ─────────────────────────────────────────────────────────────────────────────
class _ContactMethod {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ContactMethod({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Contact Us Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ContactUsSheet extends StatefulWidget {
  final bool isDark;
  final ColorScheme cs;

  const _ContactUsSheet({required this.isDark, required this.cs});

  @override
  State<_ContactUsSheet> createState() => _ContactUsSheetState();
}

class _ContactUsSheetState extends State<_ContactUsSheet>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _listCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  static const _methods = [
    _ContactMethod(
      title: 'WhatsApp',
      value: '+216 12 345 678',
      icon: Icons.chat_rounded,
      color: Color(0xFF25D366),
    ),
    _ContactMethod(
      title: 'Phone',
      value: '+216 12 345 678',
      icon: Icons.phone_rounded,
      color: Color(0xFF007AFF),
    ),
    _ContactMethod(
      title: 'Email',
      value: 'contact@tuniways.tn',
      icon: Icons.email_rounded,
      color: Color(0xFFEA4335),
    ),
    _ContactMethod(
      title: 'Instagram',
      value: '@tuniways',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFFE1306C),
    ),
    _ContactMethod(
      title: 'Facebook',
      value: 'TuniWays',
      icon: Icons.facebook_rounded,
      color: Color(0xFF1877F2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _listCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag handle ────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),

              // ── Animated Header ────────────────────────────────────────
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(isDark),
                ),
              ),

              const SizedBox(height: 24),

              // ── Contact Cards (scrollable) ────────────────────────────────
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemCount: _methods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    return AnimatedBuilder(
                      animation: _listCtrl,
                      builder: (_, child) {
                        // Staggered entrance per card
                        final staggeredT = (((_listCtrl.value - i * 0.15) /
                                (1.0 - i * 0.15))
                            .clamp(0.0, 1.0));
                        final offset = Offset(0, 40 * (1 - staggeredT));
                        return Opacity(
                          opacity: staggeredT,
                          child: Transform.translate(
                            offset: offset,
                            child: child,
                          ),
                        );
                      },
                      child: _buildContactCard(_methods[i], isDark),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Glowing icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.green500, AppColors.green300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.green500.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Contact Us',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We are here to help! Reach out to us via any of the channels below.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.mutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Divider with label
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'CONNECT',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.07),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(_ContactMethod method, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: method.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: method.color.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: method.color.withValues(alpha: 0.1),
            ),
            child: Icon(method.icon, color: method.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  method.value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.mutedText.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
