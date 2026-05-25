import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/linen_background.dart';
import '../widgets/ashoka_chakra.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _TabPlaceholder(
      title: 'Explore',
      devanagari: 'अन्वेषण',
      icon: Icons.explore_outlined,
      description: 'Discover heritage sites near you.',
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  final String title;
  final String devanagari;
  final IconData icon;
  final String description;

  const _TabPlaceholder({
    required this.title,
    required this.devanagari,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinenBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decorative icon ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, size: 44, color: AppColors.gold),
                ),
                const SizedBox(height: 28),
                Text(title, style: AppTypography.displayHero),
                const SizedBox(height: 8),
                Text(
                  devanagari,
                  style: AppTypography.devanagariSubtitle(size: 32),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const AshokaChakra(size: 32, animate: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
