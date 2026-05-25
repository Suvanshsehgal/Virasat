import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ModePill extends StatelessWidget {
  final String label;
  final String devanagari;
  final bool isActive;
  final VoidCallback onTap;

  const ModePill({
    super.key,
    required this.label,
    required this.devanagari,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.terracotta,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.darkBase : AppColors.terracotta,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              devanagari,
              style: TextStyle(
                fontFamily: AppTypography.notoSansDevanagari,
                fontSize: 10,
                color: isActive
                    ? AppColors.darkBase.withValues(alpha: 0.6)
                    : AppColors.terracotta.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
