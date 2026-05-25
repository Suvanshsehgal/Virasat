import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class VirasatBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const VirasatBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const tabs = [
    _TabData(Icons.camera_alt_outlined, 'Identify'),
    _TabData(Icons.explore_outlined, 'Explore'),
    _TabData(Icons.quiz_outlined, 'Quiz'),
    _TabData(Icons.map_outlined, 'Plan'),
    _TabData(Icons.smart_toy_outlined, 'Chatbot'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(color: Color(0xFF1C1209)),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == currentIndex;
          final tab = tabs[i];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: _TabItem(isActive: isActive, tab: tab),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final bool isActive;
  final _TabData tab;

  const _TabItem({required this.isActive, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gold pill indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: isActive ? 24 : 0,
          height: 3,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Spacer(),
        // Icon
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: isActive
              ? Matrix4.translationValues(0, -2, 0)
              : Matrix4.translationValues(0, 0, 0),
          child: Icon(
            tab.icon,
            size: 24,
            color: isActive ? AppColors.gold : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tab.label,
          style: TextStyle(
            fontFamily: AppTypography.inter,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.gold : AppColors.textMuted,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _TabData {
  final IconData icon;
  final String label;

  const _TabData(this.icon, this.label);
}
