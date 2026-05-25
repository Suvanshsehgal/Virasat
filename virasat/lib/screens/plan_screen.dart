import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import 'virtual_tour_screen.dart';
import 'timeline_screen.dart';
import 'travel_planner_screen.dart';
import 'compare_monuments_screen.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _PanelCard(
                        icon: Icons.vrpano_outlined,
                        title: 'Virtual Tour',
                        devanagari: 'आभासी भ्रमण',
                        description:
                            'Explore monuments in immersive 360°',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VirtualTourScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PanelCard(
                        icon: Icons.timeline_outlined,
                        title: 'Timeline',
                        devanagari: 'समयरेखा',
                        description:
                            'Journey through India\'s heritage timeline',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TimelineScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PanelCard(
                        icon: Icons.map_outlined,
                        title: 'Travel Planner',
                        devanagari: 'यात्रा योजना',
                        description:
                            'Plan your heritage travel itinerary',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TravelPlannerScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PanelCard(
                        icon: Icons.compare_arrows_outlined,
                        title: 'Compare Monuments',
                        devanagari: 'स्मारकों की तुलना',
                        description:
                            'Compare heritage sites side by side',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const CompareMonumentsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan', style: AppTypography.screenTitle),
          const SizedBox(height: 4),
          Text(
            'योजना',
            style: AppTypography.devanagariSubtitle(size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 3,
      decoration: AppDecorations.tricolorDivider,
      width: double.infinity,
    );
  }
}

class _PanelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String devanagari;
  final String description;
  final VoidCallback onTap;

  const _PanelCard({
    required this.icon,
    required this.title,
    required this.devanagari,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: AppColors.gold, width: 4),
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: AppColors.gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    devanagari,
                    style: AppTypography.devanagariSubtitle(size: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.metadata.copyWith(
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
