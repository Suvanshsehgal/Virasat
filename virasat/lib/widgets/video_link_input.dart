import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class VideoLinkInput extends StatelessWidget {
  final TextEditingController controller;

  const VideoLinkInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'Paste a video URL',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'https://youtube.com/...',
              hintStyle: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              suffixIcon: const Icon(
                Icons.paste,
                size: 20,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
