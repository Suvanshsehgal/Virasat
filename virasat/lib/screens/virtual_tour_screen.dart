import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';

enum NarrativeStyle { narrative, documentary, poetic }

class VirtualTourScreen extends StatefulWidget {
  const VirtualTourScreen({super.key});

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  final _monumentController = TextEditingController();
  NarrativeStyle _style = NarrativeStyle.narrative;

  @override
  void dispose() {
    _monumentController.dispose();
    super.dispose();
  }

  void _beginTour() {
    // TODO: navigate to virtual tour experience
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
                      const SizedBox(height: 32),
                      _buildStyleSelector(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: GoldButton(
                  label: 'Begin Virtual Tour',
                  onTap: _beginTour,
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
              Text('Virtual Tour', style: AppTypography.screenTitle),
              Text(
                'आभासी भ्रमण',
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
            hintText: 'e.g. Taj Mahal, Qutub Minar...',
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

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Narrative Style',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'कथा शैली',
          style: AppTypography.devanagariSubtitle(size: 16),
        ),
        const SizedBox(height: 14),
        _StyleCard(
          icon: Icons.auto_stories_outlined,
          label: 'Narrative',
          devanagari: 'कथा',
          description:
              'A storytelling journey through history and culture',
          isSelected: _style == NarrativeStyle.narrative,
          onTap: () => setState(() => _style = NarrativeStyle.narrative),
        ),
        const SizedBox(height: 12),
        _StyleCard(
          icon: Icons.document_scanner_outlined,
          label: 'Documentary',
          devanagari: 'वृत्तचित्र',
          description:
              'Factual, detailed exploration with historical accuracy',
          isSelected: _style == NarrativeStyle.documentary,
          onTap: () =>
              setState(() => _style = NarrativeStyle.documentary),
        ),
        const SizedBox(height: 12),
        _StyleCard(
          icon: Icons.auto_awesome,
          label: 'Poetic',
          devanagari: 'काव्यात्मक',
          description:
              'Lyrical and evocative descriptions of heritage',
          isSelected: _style == NarrativeStyle.poetic,
          onTap: () => setState(() => _style = NarrativeStyle.poetic),
        ),
      ],
    );
  }
}

class _StyleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String devanagari;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.icon,
    required this.label,
    required this.devanagari,
    required this.description,
    required this.isSelected,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.gold : Colors.transparent,
              width: 4,
            ),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.glow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  ...AppColors.cardShadow,
                ]
              : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.darkBase
                    : AppColors.gold,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: AppTypography.inter,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.goldDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        devanagari,
                        style: TextStyle(
                          fontFamily: AppTypography.notoSansDevanagari,
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.metadata.copyWith(
                      fontSize: 12,
                      letterSpacing: 0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.darkBase,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
