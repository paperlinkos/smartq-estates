import 'package:flutter/material.dart';

/// App color palette strictly adhering to minimal monochrome visual language:
/// - Black: #000000
/// - White: #FFFFFF
/// - Neutral grays for subtle backgrounds, borders, secondary text, and disabled states.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Neutral grays
  static const Color gray900 = Color(0xFF18181B);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray50 = Color(0xFFFAFAFA);

  // Semantic mappings
  static const Color background = white;
  static const Color surface = white;
  static const Color surfaceSubtle = gray50;
  static const Color textPrimary = black;
  static const Color textSecondary = gray500;
  static const Color textTertiary = gray400;
  static const Color border = gray200;
  static const Color borderSubtle = gray100;
  static const Color divider = gray100;
}
