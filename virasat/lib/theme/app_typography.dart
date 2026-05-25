import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Font families
  static const String playfairDisplay = 'Playfair Display';
  static const String inter = 'Inter';
  static const String notoSansDevanagari = 'Noto Sans Devanagari';

  // Display / Hero
  static const TextStyle displayHero = TextStyle(
    fontFamily: playfairDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: Color(0xFF1C1209),
    shadows: [
      Shadow(
        color: Color(0x4DC8922A),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Screen title — Playfair 600
  static const TextStyle screenTitle = TextStyle(
    fontFamily: playfairDisplay,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    color: Color(0xFF1C1209),
  );

  // Monument name — Playfair 600 italic
  static const TextStyle monumentName = TextStyle(
    fontFamily: playfairDisplay,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    fontSize: 20,
    color: Color(0xFF1C1209),
  );

  // Body — Inter 400 15px
  static const TextStyle body = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: Color(0xFF1C1209),
  );

  // Metadata / tags / distances / labels — Inter 500 12px uppercase
  static const TextStyle metadata = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 1.2,
    color: Color(0xFF6B5744),
  );

  // Section header English — Playfair 600
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: playfairDisplay,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: Color(0xFF1C1209),
  );

  // Devanagari subtitle — Noto Sans Devanagari
  static TextStyle devanagariSubtitle({double size = 16}) => TextStyle(
        fontFamily: notoSansDevanagari,
        fontWeight: FontWeight.w400,
        fontSize: size * 0.65,
        color: const Color(0xFFA8937E),
      );

  // Button text
  static const TextStyle buttonGold = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Color(0xFF1C1209),
  );

  static const TextStyle buttonTerracotta = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Color(0xFF8B3A2A),
  );

  static const TextStyle buttonGhost = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: Color(0xFFA8937E),
  );
}
