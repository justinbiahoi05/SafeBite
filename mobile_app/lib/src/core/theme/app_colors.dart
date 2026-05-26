import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF06110C);
  static const Color surface = Color(0xFF0A1A12);
  static const Color accent = Color(0xFF22C55E);
  static const Color accentSoft = Color(0xFF89E8B0);
  static const Color mutedText = Color(0xFF9BA8A1);
  static const Color error = Color(0xFFEF4444);

  static const Color cardBackground = Color(0xFFF9FBF9);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color buttonPrimary = Color(0xFF00B14F);
  static const Color buttonSecondary = Color(0xFF00D166);
  static const Color fieldBackground = Color(0xFFF0F4F1);
  static const Color gradientDark = Color(0xFF0F261B);
  static const Color gradientIntermediate = Color(0xFF0D1F16);
  static const Color blackSoft = Color(0xFF050A07);
  static const Color darkGreen = Color(0xFF040A06);
  static const Color forestGreen = Color(0xFF04542C);
  static const Color grayLight = Color(0xFFEFEFEF);
  static const Color scaffoldBackgroundLight = Color(0xFFF1F4F2);

  // New centralized colors to prevent hardcoding
  static const Color onboardingAccent2 = Color(0xFF48D47D);
  static const Color onboardingAccentSoft2 = Color(0xFFA7F3C1);
  static const Color onboardingAccentSoft3 = Color(0xFF97F0B9);
  static const Color onboardingGradientStart = Color(0xFF101C16);
  static const Color onboardingGradientEnd = Color(0xFF06100B);
  static const Color glassBackground = Color(0xFF0D1812);
  static const Color navbarActive = Color(0xFF2C4C3B);
  static const Color navbarInactive = Color(0x8A000000); // Colors.black54 equivalent

  static const List<Color> mainGradient = [background, gradientIntermediate];
  static const List<Color> authGradient = [gradientDark, background];
  static const List<Color> buttonGradient = [buttonPrimary, buttonSecondary];
}
