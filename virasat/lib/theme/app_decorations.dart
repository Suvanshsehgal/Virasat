import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  // Card decoration
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: AppColors.cardShadow,
  );

  // Card with gold left border (active/selected state)
  static BoxDecoration cardActive = BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(16),
    border: const Border(
      left: BorderSide(color: AppColors.gold, width: 4),
    ),
    boxShadow: AppColors.cardShadow,
  );

  // Card inner glow (active state)
  static BoxDecoration cardWithGlow = BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      ...AppColors.cardShadow,
      BoxShadow(
        color: AppColors.glow,
        blurRadius: 16,
        offset: const Offset(0, 0),
      ),
    ],
  );

  // Primary button — gold filled
  static BoxDecoration buttonPrimary = BoxDecoration(
    color: AppColors.gold,
    borderRadius: BorderRadius.circular(12),
  );

  // Secondary button — terracotta outlined
  static BoxDecoration buttonSecondary = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.terracotta, width: 2),
  );

  // Input field
  static BoxDecoration inputField = BoxDecoration(
    color: AppColors.deepSurface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  );

  // Input field focused
  static BoxDecoration inputFieldFocused = BoxDecoration(
    color: AppColors.deepSurface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.gold, width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.glow,
        blurRadius: 8,
        offset: const Offset(0, 0),
      ),
    ],
  );

  // Filter pill — inactive (terracotta outlined)
  static BoxDecoration filterPillInactive = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.terracotta, width: 1.5),
  );

  // Filter pill — active (gold filled)
  static BoxDecoration filterPillActive = BoxDecoration(
    color: AppColors.gold,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.glow,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Distance chip
  static BoxDecoration distanceChip = BoxDecoration(
    color: AppColors.goldLight.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(12),
  );

  // Skeleton shimmer (gold diagonal)
  static BoxDecoration skeleton = BoxDecoration(
    color: const Color(0xFFEDE4D6),
    borderRadius: BorderRadius.circular(8),
  );

  // Ashoka Chakra watermark
  static BoxDecoration watermark = BoxDecoration(
    color: const Color(0xFFF7F1E8),
    borderRadius: BorderRadius.circular(16),
  );

  // Tricolor divider (3px, saffron → white → green)
  static BoxDecoration tricolorDivider = BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFFFF9933),
        Color(0xFFFFFFFF),
        Color(0xFF138808),
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  // Tab bar
  static BoxDecoration tabBar = const BoxDecoration(
    color: Color(0xFF1C1209),
  );

  // Badge — gold (monuments)
  static BoxDecoration badgeGold = BoxDecoration(
    color: AppColors.gold,
    borderRadius: BorderRadius.circular(8),
  );

  // Badge — jade (nature/gardens)
  static BoxDecoration badgeJade = BoxDecoration(
    color: AppColors.jade,
    borderRadius: BorderRadius.circular(8),
  );

  // Badge — terracotta (forts/historical)
  static BoxDecoration badgeTerracotta = BoxDecoration(
    color: AppColors.terracotta,
    borderRadius: BorderRadius.circular(8),
  );

  // Badge — amber (active/featured)
  static BoxDecoration badgeAmber = BoxDecoration(
    color: const Color(0xFFFFBF00),
    borderRadius: BorderRadius.circular(8),
  );
}
