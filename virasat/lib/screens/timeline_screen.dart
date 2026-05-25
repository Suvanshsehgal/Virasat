import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _monumentController = TextEditingController();
  bool _generated = false;

  @override
  void dispose() {
    _monumentController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_monumentController.text.trim().isEmpty) return;
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
                      const SizedBox(height: 20),
                      GoldButton(
                        label: 'Generate Timeline',
                        onTap: _generate,
                      ),
                      if (_generated) ...[
                        const SizedBox(height: 32),
                        _buildTimelinePreview(),
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
              Text('Timeline', style: AppTypography.screenTitle),
              Text(
                'समयरेखा',
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
            hintText: 'e.g. Taj Mahal, Red Fort...',
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

  Widget _buildTimelinePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heritage Timeline',
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 4),
        Text(
          'विरासत समयरेखा',
          style: AppTypography.devanagariSubtitle(size: 20),
        ),
        const SizedBox(height: 20),
        _TimelineEntry(
          year: '1632',
          title: 'Construction Begins',
          description:
              'Emperor Shah Jahan orders the construction of the Taj Mahal in memory of Mumtaz Mahal.',
          isFirst: true,
        ),
        _TimelineEntry(
          year: '1643',
          title: 'Main Structure Completed',
          description:
              'The main mausoleum is completed after 11 years of construction.',
        ),
        _TimelineEntry(
          year: '1653',
          title: 'Full Complex Completed',
          description:
              'The entire complex including gardens, mosque, and guest house is finished.',
        ),
        _TimelineEntry(
          year: '1983',
          title: 'UNESCO World Heritage Site',
          description:
              'Taj Mahal is designated as a UNESCO World Heritage Site.',
        ),
        _TimelineEntry(
          year: '2007',
          title: 'New Seven Wonders',
          description:
              'Taj Mahal is declared one of the New Seven Wonders of the World.',
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final String year;
  final String title;
  final String description;
  final bool isFirst;
  final bool isLast;

  const _TimelineEntry({
    required this.year,
    required this.title,
    required this.description,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (isFirst)
                  const SizedBox(height: 6)
                else
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cardSurface,
                      width: 3,
                    ),
                  ),
                ),
                if (isLast)
                  const SizedBox(height: 6)
                else
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      year,
                      style: TextStyle(
                        fontFamily: AppTypography.inter,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.body.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
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
