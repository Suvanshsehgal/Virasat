import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';

class CompareMonumentsScreen extends StatefulWidget {
  const CompareMonumentsScreen({super.key});

  @override
  State<CompareMonumentsScreen> createState() =>
      _CompareMonumentsScreenState();
}

class _CompareMonumentsScreenState extends State<CompareMonumentsScreen> {
  final _monument1Controller = TextEditingController();
  final _monument2Controller = TextEditingController();

  @override
  void dispose() {
    _monument1Controller.dispose();
    _monument2Controller.dispose();
    super.dispose();
  }

  void _compare() {
    // TODO: navigate to comparison results
  }

  void _selectPair(String m1, String m2) {
    _monument1Controller.text = m1;
    _monument2Controller.text = m2;
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
                      _buildMonumentInputs(),
                      const SizedBox(height: 28),
                      _buildPopularComparisons(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: GoldButton(label: 'Compare', onTap: _compare),
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
              Text('Compare Monuments',
                  style: AppTypography.screenTitle),
              Text(
                'स्मारकों की तुलना',
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

  Widget _buildMonumentInputs() {
    return Column(
      children: [
        TextField(
          controller: _monument1Controller,
          decoration: InputDecoration(
            hintText: 'First monument...',
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontFamily: AppTypography.playfairDisplay,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.gold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _monument2Controller,
          decoration: InputDecoration(
            hintText: 'Second monument...',
            hintStyle: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.account_balance_outlined,
              size: 22,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularComparisons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Comparisons',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'लोकप्रिय तुलनाएँ',
          style: AppTypography.devanagariSubtitle(size: 16),
        ),
        const SizedBox(height: 14),
        _ComparisonChip(
          m1: 'Taj Mahal',
          m2: 'Red Fort',
          onTap: () => _selectPair('Taj Mahal', 'Red Fort'),
        ),
        const SizedBox(height: 10),
        _ComparisonChip(
          m1: 'Qutub Minar',
          m2: 'Charminar',
          onTap: () => _selectPair('Qutub Minar', 'Charminar'),
        ),
        const SizedBox(height: 10),
        _ComparisonChip(
          m1: 'Gateway of India',
          m2: 'India Gate',
          onTap: () =>
              _selectPair('Gateway of India', 'India Gate'),
        ),
        const SizedBox(height: 10),
        _ComparisonChip(
          m1: 'Hawa Mahal',
          m2: 'Mysore Palace',
          onTap: () =>
              _selectPair('Hawa Mahal', 'Mysore Palace'),
        ),
        const SizedBox(height: 10),
        _ComparisonChip(
          m1: 'Ajanta Caves',
          m2: 'Ellora Caves',
          onTap: () =>
              _selectPair('Ajanta Caves', 'Ellora Caves'),
        ),
        const SizedBox(height: 10),
        _ComparisonChip(
          m1: 'Sun Temple',
          m2: 'Meenakshi Temple',
          onTap: () =>
              _selectPair('Sun Temple', 'Meenakshi Temple'),
        ),
      ],
    );
  }
}

class _ComparisonChip extends StatelessWidget {
  final String m1;
  final String m2;
  final VoidCallback onTap;

  const _ComparisonChip({
    required this.m1,
    required this.m2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Text(
              m1,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.goldDark,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'vs',
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              m2,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.terracotta,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
