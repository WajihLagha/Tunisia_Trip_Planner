import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  PASTEL GREENERY COLOR PALETTE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppColors {
  AppColors._();

  // Brand greens
  static const Color green100 = Color(0xFF99E2B4);
  static const Color green200 = Color(0xFF88D4AB);
  static const Color green300 = Color(0xFF78C6A3);
  static const Color green400 = Color(0xFF67B99A);
  static const Color green500 = Color(0xFF56AB91);
  static const Color green600 = Color(0xFF469D89);
  static const Color green700 = Color(0xFF358F80);
  static const Color green800 = Color(0xFF248277);
  static const Color green900 = Color(0xFF14746F);
  static const Color green950 = Color(0xFF036666);

  // Semantic aliases
  static const Color primary      = green600;   // #469D89
  static const Color primaryDark  = green950;   // #036666 â€“ dark mode primary
  static const Color secondary    = green300;   // #78C6A3
  static const Color accent       = green100;   // #99E2B4

  // Neutrals
  static const Color surfaceLight     = Color(0xFFF4FAF8);
  static const Color surfaceVariantL  = Color(0xFFE8F5F1);
  static const Color onSurfaceLight   = Color(0xFF0D2B25);

  static const Color surfaceDark      = Color(0xFF0B1F1C);
  static const Color surfaceVariantD  = Color(0xFF142E29);
  static const Color onSurfaceDark    = Color(0xFFD6F0EB);

  static const Color navBarLight      = Color(0xFFFFFFFF);
  static const Color navBarDark       = Color(0xFF036666); // deep teal

  static const Color errorColor       = Color(0xFFD94F3D);

  // Semantic UI helpers
  static const Color mutedText        = Color(0xFF5A8A80); // labels, hints
  static const Color borderColor      = Color(0xFFD4EDE5); // card / input borders
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  TYPOGRAPHY
//  Display  â†’ Playfair Display (editorial, travel-magazine feel)
//  Body     â†’ DM Sans (clean, modern, highly legible)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppTextTheme {
  AppTextTheme._();

  static TextTheme _build(Color primary, Color secondary) {
    return TextTheme(
      // â”€â”€ Display / Hero â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 57, fontWeight: FontWeight.w700, color: primary, letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 45, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w600, color: primary,
      ),

      // â”€â”€ Headlines â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w600, color: primary,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w600, color: primary,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: primary,
      ),

      // â”€â”€ Titles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      titleLarge: GoogleFonts.dmSans(
        fontSize: 22, fontWeight: FontWeight.w600, color: primary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w500, color: primary, letterSpacing: 0.1,
      ),

      // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: secondary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: secondary, height: 1.5,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.4,
      ),

      // â”€â”€ Labels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: primary, letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.5,
      ),
    );
  }

  static final TextTheme light = _build(
    AppColors.onSurfaceLight,
    AppColors.onSurfaceLight.withValues(alpha: 0.6),
  );

  static final TextTheme dark = _build(
    AppColors.onSurfaceDark,
    AppColors.onSurfaceDark.withValues(alpha: 0.6),
  );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  LIGHT THEME
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
ThemeData get lightTheme {
  final ColorScheme cs = ColorScheme(
    brightness: Brightness.light,
    primary:          AppColors.primary,
    onPrimary:        Colors.white,
    primaryContainer: AppColors.green200,
    onPrimaryContainer: AppColors.green950,
    secondary:        AppColors.secondary,
    onSecondary:      Colors.white,
    secondaryContainer: AppColors.accent,
    onSecondaryContainer: AppColors.green950,
    tertiary:         AppColors.green700,
    onTertiary:       Colors.white,
    error:            AppColors.errorColor,
    onError:          Colors.white,
    surface:          AppColors.surfaceLight,
    onSurface:        AppColors.onSurfaceLight,
    surfaceContainerHighest: AppColors.surfaceVariantL,
    onSurfaceVariant: AppColors.onSurfaceLight.withValues(alpha: 0.7),
    outline:          AppColors.green300,
    shadow:           Colors.black12,
    inverseSurface:   AppColors.surfaceDark,
    onInverseSurface: AppColors.onSurfaceDark,
    inversePrimary:   AppColors.green300,
  );

  return ThemeData(
    useMaterial3:   true,
    colorScheme:    cs,
    textTheme:      AppTextTheme.light,
    scaffoldBackgroundColor: AppColors.surfaceLight,

    // â”€â”€ AppBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    appBarTheme: AppBarTheme(
      backgroundColor:    AppColors.surfaceLight,
      foregroundColor:    AppColors.onSurfaceLight,
      elevation:          0,
      centerTitle:        true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurfaceLight,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),

    // â”€â”€ BottomNavigationBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.navBarLight,
      selectedItemColor:    AppColors.primary,
      unselectedItemColor:  Color(0xFFADC8C3),
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
    ),

    // â”€â”€ FloatingActionButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation:       6,
      shape:           CircleBorder(),
    ),

    // â”€â”€ ElevatedButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        elevation:       0,
      ),
    ),

    // â”€â”€ OutlinedButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side:            const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // â”€â”€ TextButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // â”€â”€ InputDecoration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    inputDecorationTheme: InputDecorationTheme(
      filled:           true,
      fillColor:        AppColors.surfaceVariantL,
      contentPadding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(color: AppColors.onSurfaceLight.withValues(alpha: 0.4)),
    ),

    // â”€â”€ Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    cardTheme: CardThemeData(
      color:     Colors.white,
      elevation: 0,
      shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin:    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // â”€â”€ Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    chipTheme: ChipThemeData(
      backgroundColor:  AppColors.surfaceVariantL,
      selectedColor:    AppColors.primary,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
      shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding:          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),

    // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    dividerTheme: DividerThemeData(
      color:     AppColors.green200.withValues(alpha: 0.4),
      thickness: 1,
    ),
  );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  DARK THEME
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
ThemeData get darkTheme {
  final ColorScheme cs = ColorScheme(
    brightness: Brightness.dark,
    primary:          AppColors.green300,
    onPrimary:        AppColors.green950,
    primaryContainer: AppColors.green800,
    onPrimaryContainer: AppColors.green100,
    secondary:        AppColors.green400,
    onSecondary:      AppColors.green950,
    secondaryContainer: AppColors.green900,
    onSecondaryContainer: AppColors.green100,
    tertiary:         AppColors.green200,
    onTertiary:       AppColors.green950,
    error:            const Color(0xFFFF6B6B),
    onError:          AppColors.surfaceDark,
    surface:          AppColors.surfaceDark,
    onSurface:        AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantD,
    onSurfaceVariant: AppColors.onSurfaceDark.withValues(alpha: 0.7),
    outline:          AppColors.green800,
    shadow:           Colors.black54,
    inverseSurface:   AppColors.surfaceLight,
    onInverseSurface: AppColors.onSurfaceLight,
    inversePrimary:   AppColors.primary,
  );

  return ThemeData(
    useMaterial3:   true,
    colorScheme:    cs,
    textTheme:      AppTextTheme.dark,
    scaffoldBackgroundColor: AppColors.surfaceDark,

    // â”€â”€ AppBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    appBarTheme: AppBarTheme(
      backgroundColor:  AppColors.surfaceDark,
      foregroundColor:  AppColors.onSurfaceDark,
      elevation:        0,
      centerTitle:      true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurfaceDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.green300),
    ),

    // â”€â”€ BottomNavigationBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.navBarDark,
      selectedItemColor:    AppColors.green100,
      unselectedItemColor:  AppColors.green700,
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
    ),

    // â”€â”€ FloatingActionButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.green300,
      foregroundColor: AppColors.green950,
      elevation:       6,
      shape:           CircleBorder(),
    ),

    // â”€â”€ ElevatedButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green300,
        foregroundColor: AppColors.green950,
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        elevation:       0,
      ),
    ),

    // â”€â”€ OutlinedButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green300,
        side:            const BorderSide(color: AppColors.green300, width: 1.5),
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // â”€â”€ TextButton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.green300,
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // â”€â”€ InputDecoration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    inputDecorationTheme: InputDecorationTheme(
      filled:         true,
      fillColor:      AppColors.surfaceVariantD,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.green300, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(color: AppColors.onSurfaceDark.withValues(alpha: 0.4)),
    ),

    // â”€â”€ Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    cardTheme: CardThemeData(
      color:     AppColors.surfaceVariantD,
      elevation: 0,
      shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin:    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // â”€â”€ Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    chipTheme: ChipThemeData(
      backgroundColor:  AppColors.surfaceVariantD,
      selectedColor:    AppColors.green700,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceDark),
      shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding:          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),

    // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    dividerTheme: DividerThemeData(
      color:     AppColors.green800.withValues(alpha: 0.5),
      thickness: 1,
    ),
  );
}
