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
    _TabData(Icons.camera_alt_outlined, Icons.camera_alt, 'Identify'),
    _TabData(Icons.explore_outlined, Icons.explore, 'Explore'),
    _TabData(Icons.quiz_outlined, Icons.quiz, 'Quiz'),
    _TabData(Icons.map_outlined, Icons.map, 'Plan'),
    _TabData(Icons.smart_toy_outlined, Icons.smart_toy, 'Chatbot'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1C1209),
            Color(0xFF14100A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(flex: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: isActive
                    ? Matrix4.translationValues(0, -1, 0)
                    : Matrix4.translationValues(0, 0, 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : Colors.transparent,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isActive ? tab.activeIcon : tab.icon,
                    size: 22,
                    color: isActive ? AppColors.gold : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.gold : AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
                child: Text(tab.label),
              ),
              const Spacer(flex: 2),
            ],
          ),
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isActive ? 2 : 0),
                  bottomRight: Radius.circular(isActive ? 2 : 0),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabData(this.icon, this.activeIcon, this.label);
}
