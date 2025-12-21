import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.blue;
  static const background = Colors.white;

  static const border = Color(0xFFBDBDBD); // grey.shade400
  static const overlay = Colors.black26;

  static const textPrimary = Colors.black;
  static const textSecondary = Colors.grey;

  // Neutrals
  static const Color borderGrey = Color(0xFFBDBDBD);
  static const Color cardBackground = Colors.white;

  // Primary theme
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0x661976D2); // 40% opacity

  // Chart colors (extendable later)
  static const Color chartBorder = primaryBlue;
  static const Color chartFill = primaryBlueLight;

  // Base
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Greys
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF616161);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
  );

  static const Color errorRed = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);

  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);

  static const Color shadow = Colors.black12;

  // Backgrounds
  static const scaffoldBg = Color(0xFFF6F7FB);
  static const cardBg = Colors.white;

  // Greys
  static const grey300 = Color(0xFFD1D5DB);

  // Primary & accents
  static const primaryAccent = Color(0xFF60A5FA);

  // Status
  static const warning = Color(0xFFEA580C);
}
