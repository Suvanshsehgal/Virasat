import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';

class TravelPlannerScreen extends StatefulWidget {
  const TravelPlannerScreen({super.key});

  @override
  State<TravelPlannerScreen> createState() => _TravelPlannerScreenState();
}

class _TravelPlannerScreenState extends State<TravelPlannerScreen> {
  final _monumentController = TextEditingController();
  final _daysController = TextEditingController();
  bool _generated = false;

  @override
  void dispose() {
    _monumentController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_monumentController.text.trim().isEmpty) return;
    if (_daysController.text.trim().isEmpty) return;
    setState(() => _generated = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 12),
              _buildDivider(),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonumentInput(),
                      const SizedBox(height: 24),
                      _buildDaysInput(),
                      const SizedBox(height: 24),
                      GoldButton(
                        label: 'Generate Itinerary',
                        onTap: _generate,
                      ),
                      if (_generated) ...[
                        const SizedBox(height: 32),
                        _buildItineraryPreview(),
                      ],
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Travel Planner', style: AppTypography.screenTitle),
              Text(
                'यात्रा योजना',
                style: AppTypography.devanagariSubtitle(size: 24),
              ),
            ],
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

  Widget _buildMonumentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which monument?',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'कौन सा स्मारक?',
          style: AppTypography.devanagariSubtitle(size: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _monumentController,
          decoration: InputDecoration(
            hintText: 'e.g. Taj Mahal, Agra...',
            hintStyle: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.account_balance_outlined,
              size: 22,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of days',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'दिनों की संख्या',
          style: AppTypography.devanagariSubtitle(size: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _daysController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 3',
            hintStyle: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.gold,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  color: AppColors.gold,
                  onPressed: () {
                    final current =
                        int.tryParse(_daysController.text) ?? 0;
                    if (current > 1) {
                      _daysController.text =
                          (current - 1).toString();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  color: AppColors.gold,
                  onPressed: () {
                    final current =
                        int.tryParse(_daysController.text) ?? 0;
                    _daysController.text =
                        (current + 1).toString();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_outlined, size: 22, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'Your Itinerary',
              style: AppTypography.sectionHeader,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'आपकी यात्रा योजना',
          style: AppTypography.devanagariSubtitle(size: 20),
        ),
        const SizedBox(height: 20),
        _DayCard(
          day: 1,
          title: 'Arrival & Sightseeing',
          activities: [
            'Arrive in Agra',
            'Visit Taj Mahal at sunrise',
            'Explore Agra Fort',
            'Local cuisine dinner',
          ],
        ),
        const SizedBox(height: 12),
        _DayCard(
          day: 2,
          title: 'Heritage Exploration',
          activities: [
            'Visit Fatehpur Sikri',
            'Explore Itmad-ud-Daulah',
            'Mehtab Bagh sunset view',
          ],
        ),
        const SizedBox(height: 12),
        _DayCard(
          day: 3,
          title: 'Departure',
          activities: [
            'Morning visit to local markets',
            'Visit Sikandra',
            'Departure',
          ],
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final int day;
  final String title;
  final List<String> activities;

  const _DayCard({
    required this.day,
    required this.title,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.gold, width: 4),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: AppTypography.inter,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBase,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a,
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
