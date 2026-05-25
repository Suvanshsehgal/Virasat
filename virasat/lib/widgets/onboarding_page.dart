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
          // Icon with decorative ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.displayHero.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 10),
          // Devanagari subtitle
          Text(
            devanagariTitle,
            textAlign: TextAlign.center,
            style: AppTypography.devanagariSubtitle(size: 28),
          ),
          const SizedBox(height: 28),
          // Tricolor divider
          SizedBox(
            width: 60,
            height: 3,
            child: Container(
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
          ),
          const SizedBox(height: 28),
          // Description
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
