import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'ashoka_chakra.dart';

class LoadingOverlay extends StatelessWidget {
  final String title;
  final String devanagari;

  const LoadingOverlay({
    super.key,
    this.title = 'Analyzing...',
    this.devanagari = 'विश्लेषण कर रहा है',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBg.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AshokaChakra(size: 64, animate: true),
            const SizedBox(height: 28),
            Text(
              title,
              style: AppTypography.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              devanagari,
              style: AppTypography.devanagariSubtitle(size: 20),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  color: AppColors.gold,
                  backgroundColor: AppColors.border,
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
