import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'upload_area.dart';
import 'video_link_input.dart';

enum VideoMode { link, upload }

class VideoContent extends StatelessWidget {
  final VideoMode mode;
  final ValueChanged<VideoMode> onModeChanged;
  final TextEditingController urlController;

  const VideoContent({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.urlController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SubTab(
              label: 'Video Link',
              isActive: mode == VideoMode.link,
              onTap: () => onModeChanged(VideoMode.link),
            ),
            const SizedBox(width: 8),
            _SubTab(
              label: 'Upload Video',
              isActive: mode == VideoMode.upload,
              onTap: () => onModeChanged(VideoMode.upload),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (mode == VideoMode.link)
          VideoLinkInput(controller: urlController)
        else
          const UploadArea.video(),
      ],
    );
  }
}

class _SubTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTab({
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.terracotta : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.terracotta : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.inter,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
