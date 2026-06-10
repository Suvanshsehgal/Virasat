import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String devanagariTitle;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.devanagariTitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.08),
                  AppColors.gold.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.06),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(icon, size: 56, color: AppColors.darkBase),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.displayHero.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            devanagariTitle,
            textAlign: TextAlign.center,
            style: AppTypography.devanagariSubtitle(size: 28),
          ),
          const SizedBox(height: 32),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF9933),
                  Color(0xFFFFFFFF),
                  Color(0xFF138808),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
