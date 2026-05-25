import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';

enum Difficulty { easy, medium, hard }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _monumentController = TextEditingController();
  Difficulty _difficulty = Difficulty.easy;

  @override
  void dispose() {
    _monumentController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    // TODO: navigate to quiz questions
  }

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonumentInput(),
                      const SizedBox(height: 32),
                      _buildDifficulty(),
                      const SizedBox(height: 32),
                      _buildFeatures(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: GoldButton(label: 'Start Quiz', onTap: _startQuiz),
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
          Text('Quiz', style: AppTypography.screenTitle),
          const SizedBox(height: 4),
          Text(
            'प्रश्नोत्तरी',
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

  Widget _buildDifficulty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _DifficultyPill(
              label: 'Easy',
              isActive: _difficulty == Difficulty.easy,
              onTap: () => setState(() => _difficulty = Difficulty.easy),
            ),
            const SizedBox(width: 10),
            _DifficultyPill(
              label: 'Medium',
              isActive: _difficulty == Difficulty.medium,
              onTap: () => setState(() => _difficulty = Difficulty.medium),
            ),
            const SizedBox(width: 10),
            _DifficultyPill(
              label: 'Hard',
              isActive: _difficulty == Difficulty.hard,
              onTap: () => setState(() => _difficulty = Difficulty.hard),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz features',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeatureBox(
              icon: Icons.format_list_numbered,
              label: '5 Questions',
            ),
            _FeatureBox(
              icon: Icons.timer_outlined,
              label: '30s per question',
            ),
            _FeatureBox(
              icon: Icons.auto_awesome,
              label: 'AI-powered',
            ),
            _FeatureBox(
              icon: Icons.bolt,
              label: 'Instant feedback',
            ),
          ],
        ),
      ],
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DifficultyPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  Color _color() {
    switch (label) {
      case 'Easy':
        return AppColors.jade;
      case 'Medium':
        return AppColors.gold;
      case 'Hard':
        return AppColors.terracotta;
      default:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _FeatureBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 24 * 2 - 10) / 2,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 22, color: AppColors.gold),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
