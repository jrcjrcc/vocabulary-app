import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryDark = Color(0xFF357ABD);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color knownGreen = Color(0xFF27AE60);
  static const Color unknownRed = Color(0xFFE74C3C);
  static const Color badgeEn = Color(0xFF3498DB);
  static const Color badgeJp = Color(0xFFE74C3C);
  static const Color badgeEs = Color(0xFFE67E22);
  static const Color badgeFr = Color(0xFF9B59B6);
  static const Color progressStart = Color(0xFF3498DB);
  static const Color progressEnd = Color(0xFF2ECC71);

  static Color badgeFor(String lang) {
    switch (lang) {
      case 'en': return badgeEn;
      case 'jp': return badgeJp;
      case 'es': return badgeEs;
      case 'fr': return badgeFr;
      default: return primary;
    }
  }

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
        ),
      );
}
