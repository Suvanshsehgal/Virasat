import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.pageBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.gold,
          secondary: AppColors.terracotta,
          tertiary: AppColors.jade,
          surface: AppColors.cardSurface,
          onPrimary: Color(0xFF1C1209),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1C1209),
        ),
        fontFamily: AppTypography.inter,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.screenTitle,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.cardSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: const Color(0x1A8B5A28),
        ),

        // Elevated Button (primary)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.darkBase,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTypography.buttonGold,
          ),
        ),

        // Outlined Button (secondary)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.terracotta,
            side: const BorderSide(color: AppColors.terracotta, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTypography.buttonTerracotta,
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.deepSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gold, width: 2),
          ),
          labelStyle: const TextStyle(
            fontFamily: AppTypography.inter,
            color: AppColors.textMuted,
          ),
          hintStyle: const TextStyle(
            fontFamily: AppTypography.inter,
            color: AppColors.textMuted,
          ),
        ),

        // Bottom navigation bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1C1209),
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),

        // Chip / filter pills
        chipTheme: ChipThemeData(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.terracotta, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          labelStyle: const TextStyle(
            fontFamily: AppTypography.inter,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        // Progress indicator (circular)
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.gold,
          linearTrackColor: AppColors.border,
        ),

        // Bottom sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
        ),
      );
}
