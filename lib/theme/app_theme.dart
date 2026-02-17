import 'package:flutter/material.dart';

/// App theme configuration for Bubble
/// Dark navy theme matching reference design with purple/teal/pink accents
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================================
  // COLOR PALETTE - Matching Reference Design
  // ============================================================================
  
  // Background colors - dark navy like reference design
  static const Color backgroundNavy = Color(0xFF1A1F3A); // Dark navy background
  static const Color backgroundDark = Color(0xFF0F1425); // Darker navy
  
  // Primary colors - coral/pink for buttons and accents
  static const Color primaryCoral = Color(0xFFFF6B88); // Coral pink from reference
  static const Color primaryPink = Color(0xFFFF8FA3); // Lighter pink
  
  // Accent colors from friendship illustration
  static const Color accentPurple = Color(0xFF9B4D96); // Deep purple/magenta
  static const Color accentTeal = Color(0xFF2D5F5D); // Dark teal
  static const Color accentLightBlue = Color(0xFFB8E6F0); // Light blue
  static const Color accentDarkPurple = Color(0xFF5C3D6B); // Dark purple
  
  // Text colors
  static const Color textWhite = Color(0xFFFFFFFF); // White text
  static const Color textLight = Color(0xFFE5E7EB); // Light gray
  static const Color textGray = Color(0xFF9CA3AF); // Medium gray
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCoral, primaryPink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundNavy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================
  
  static const String fontFamily = 'Inter'; // Will use system default for now
  
  // App name / logo text
  static const TextStyle appName = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: textWhite,
    letterSpacing: -1.0,
    height: 1.1,
  );
  
  // Tagline text
  static const TextStyle tagline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textWhite,
    letterSpacing: 0.3,
    height: 1.3,
  );
  
  // Subtitle text
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textLight,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  // Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textWhite,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // SPACING & LAYOUT
  // ============================================================================
  
  static const double spacingXS = 8.0;
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 32.0;
  static const double spacingXL = 48.0;
  static const double spacingXXL = 64.0;
  
  static const double borderRadiusS = 12.0;
  static const double borderRadiusM = 16.0;
  static const double borderRadiusL = 24.0;
  static const double borderRadiusXL = 32.0;

  // ============================================================================
  // MATERIAL THEME
  // ============================================================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundNavy,
      colorScheme: const ColorScheme.dark(
        primary: primaryCoral,
        secondary: primaryPink,
        surface: backgroundNavy,
        background: backgroundDark,
      ),
      textTheme: const TextTheme(
        displayLarge: appName,
        headlineMedium: tagline,
        titleMedium: subtitle,
        labelLarge: buttonText,
      ),
      useMaterial3: true,
    );
  }
}
