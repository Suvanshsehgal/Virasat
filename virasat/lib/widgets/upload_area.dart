import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class UploadArea extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String formats;

  const UploadArea({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.formats = '',
  });

  const UploadArea.image({super.key})
      : icon = Icons.image_outlined,
        title = 'Upload an image',
        subtitle = 'Tap to select or take a photo',
        formats = 'Supported: JPG, PNG, WEBP';

  const UploadArea.video({super.key})
      : icon = Icons.videocam_outlined,
        title = 'Upload a video',
        subtitle = 'Tap to select a video file',
        formats = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              width: 2,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.1),
                ),
                child: Icon(icon, size: 36, color: AppColors.gold),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Choose File',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (formats.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            formats,
            style: AppTypography.metadata.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0,
            ),
          ),
        ],
      ],
    );
  }
}
