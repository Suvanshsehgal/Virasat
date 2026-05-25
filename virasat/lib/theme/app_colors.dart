import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Page
  static const Color pageBg = Color(0xFFF7F1E8);
  static const Color deepSurface = Color(0xFFEDE4D6);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Gold
  static const Color gold = Color(0xFFC8922A);
  static const Color goldLight = Color(0xFFE8B84B);
  static const Color goldDark = Color(0xFF8B6318);

  // Terracotta
  static const Color terracotta = Color(0xFF8B3A2A);
  static const Color terracottaLight = Color(0xFFC4603E);

  // Jade
  static const Color jade = Color(0xFF2D6A4F);

  // Base
  static const Color darkBase = Color(0xFF1C1209);

  // Text
  static const Color textPrimary = Color(0xFF1C1209);
  static const Color textSecondary = Color(0xFF6B5744);
  static const Color textMuted = Color(0xFFA8937E);

  // Borders
  static const Color border = Color(0xFFE8DDD0);

  // Glow
  static const Color glow = Color(0x26C8922A);

  // Shadow
  static Color warmShadow = const Color(0x1A8B5A28);

  // Card shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0x1A8B5A28),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  // Tricolor
  static const Color tricolorSaffron = Color(0xFFFF9933);
  static const Color tricolorWhite = Color(0xFFFFFFFF);
  static const Color tricolorGreen = Color(0xFF138808);
}
