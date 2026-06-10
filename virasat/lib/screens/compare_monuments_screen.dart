import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';

class CompareMonumentsScreen extends StatefulWidget {
  const CompareMonumentsScreen({super.key});

  @override
  State<CompareMonumentsScreen> createState() =>
      _CompareMonumentsScreenState();
}

class _CompareMonumentsScreenState extends State<CompareMonumentsScreen> {
  final _monument1Controller = TextEditingController();
  final _monument2Controller = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _comparison;
  String? _error;

  @override
  void dispose() {
    _monument1Controller.dispose();
    _monument2Controller.dispose();
    _api.dispose();
    super.dispose();
  }

  void _compare() async {
    final m1 = _monument1Controller.text.trim();
    final m2 = _monument2Controller.text.trim();
    if (m1.isEmpty || m2.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _comparison = null;
    });

    try {
      _comparison = await _api.compareMonuments(monument1: m1, monument2: m2);
    } on ApiException catch (e) {
      _error = '${e.statusCode}: ${e.message}';
    } catch (e) {
      _error = 'Connection failed. Ensure backend is running.';
    }

    if (mounted) setState(() => _loading = false);
  }

  void _selectPair(String m1, String m2) {
    _monument1Controller.text = m1;
    _monument2Controller.text = m2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LinenBackground(
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
                      child: _comparison != null
                          ? _buildComparisonResult()
                          : _buildSetupForm(),
                    ),
                  ),
                  if (_comparison == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: GoldButton(label: 'Compare', onTap: _compare),
                    ),
                ],
              ),
            ),
          ),
          if (_loading) const LoadingOverlay(),
        ],
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

  Widget _buildSetupForm() {
    return Column(
      children: [
        _buildMonumentInputs(),
        const SizedBox(height: 28),
        _buildPopularComparisons(),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _error!,
              style: TextStyle(color: AppColors.terracotta, fontSize: 13),
            ),
          ),
        ],
      ],
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

  Widget _buildComparisonResult() {
    final m1 = _comparison!['monument1'] as Map<String, dynamic>? ?? {};
    final m2 = _comparison!['monument2'] as Map<String, dynamic>? ?? {};
    final comp = _comparison!['comparison'] as Map<String, dynamic>? ?? {};
    final funFacts = _comparison!['fun_facts'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.compare_arrows, color: AppColors.gold, size: 22),
            const SizedBox(width: 8),
            Text('Comparison Result', style: AppTypography.sectionHeader),
          ],
        ),
        const SizedBox(height: 20),
        _buildMonumentCard(m1, AppColors.gold, 'Monument 1'),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                fontFamily: AppTypography.playfairDisplay,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMonumentCard(m2, AppColors.terracotta, 'Monument 2'),

        if (comp.isNotEmpty) ...[
          const SizedBox(height: 28),
          _buildComparisonSection(comp),
        ],

        if (funFacts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fun Facts',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 8),
                ...funFacts.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✨ ',
                              style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: Text(
                              f as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                                fontFamily: AppTypography.inter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        Center(
          child: GoldButton(
            label: 'Compare New Pair',
            onTap: () => setState(() => _comparison = null),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMonumentCard(Map<String, dynamic> m, Color accent, String label) {
    final name = m['name'] as String? ?? '';
    final location = m['location'] as String? ?? '';
    final builtYear = m['built_year'] as String? ?? '';
    final builtBy = m['built_by'] as String? ?? '';
    final architecture = m['architecture'] as String? ?? '';
    final material = m['material'] as String? ?? '';
    final unesco = m['unesco'] as String? ?? '';
    final height = m['height_or_size'] as String? ?? '';
    final significance = m['significance'] as String? ?? '';
    final unique = m['unique_feature'] as String? ?? '';
    final bestTime = m['best_time'] as String? ?? '';
    final entryFee = m['entry_fee'] as String? ?? '';
    final visitors = m['visitors_per_year'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 4)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty)
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accent,
                fontFamily: AppTypography.playfairDisplay,
              ),
            ),
          const SizedBox(height: 12),
          if (location.isNotEmpty)
            _detailRow('📍', 'Location', location),
          if (builtYear.isNotEmpty)
            _detailRow('📅', 'Built', builtYear),
          if (builtBy.isNotEmpty)
            _detailRow('👑', 'Built by', builtBy),
          if (architecture.isNotEmpty)
            _detailRow('🏛️', 'Architecture', architecture),
          if (material.isNotEmpty)
            _detailRow('🧱', 'Material', material),
          if (unesco.isNotEmpty)
            _detailRow('🏆', 'UNESCO', unesco),
          if (height.isNotEmpty)
            _detailRow('📏', 'Size', height),
          if (significance.isNotEmpty)
            _detailRow('💫', 'Significance', significance),
          if (unique.isNotEmpty)
            _detailRow('✨', 'Unique', unique),
          if (bestTime.isNotEmpty)
            _detailRow('📅', 'Best time', bestTime),
          if (entryFee.isNotEmpty)
            _detailRow('💰', 'Entry fee', entryFee),
          if (visitors.isNotEmpty)
            _detailRow('👥', 'Visitors/yr', visitors),
        ],
      ),
    );
  }

  Widget _detailRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji  ', style: TextStyle(fontSize: 13)),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                fontFamily: AppTypography.inter,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.inter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(Map<String, dynamic> comp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.playfairDisplay,
            ),
          ),
          const SizedBox(height: 16),
          if (comp['similarities'] != null) ...[
            Text(
              'Similarities',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.jade,
                fontFamily: AppTypography.inter,
              ),
            ),
            const SizedBox(height: 6),
            ...(comp['similarities'] as List).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✓ ',
                        style: TextStyle(color: AppColors.jade, fontSize: 13)),
                    Expanded(
                      child: Text(
                        s as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: AppTypography.inter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (comp['differences'] != null) ...[
            Text(
              'Differences',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.terracotta,
                fontFamily: AppTypography.inter,
              ),
            ),
            const SizedBox(height: 6),
            ...(comp['differences'] as List).map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✗ ',
                        style: TextStyle(color: AppColors.terracotta, fontSize: 13)),
                    Expanded(
                      child: Text(
                        d as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: AppTypography.inter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (comp['which_older'] != null)
            _compareItem('Older', comp['which_older'] as String),
          if (comp['architectural_contrast'] != null)
            _compareItem('Architecture', comp['architectural_contrast'] as String),
          if (comp['cultural_contrast'] != null)
            _compareItem('Culture', comp['cultural_contrast'] as String),
          if (comp['verdict_history'] != null)
            _compareItem('History Verdict', comp['verdict_history'] as String),
          if (comp['verdict_architecture'] != null)
            _compareItem('Architecture Verdict', comp['verdict_architecture'] as String),
          if (comp['verdict_tourism'] != null)
            _compareItem('Tourism Verdict', comp['verdict_tourism'] as String),
          if (comp['combined_visit'] != null)
            _compareItem('Combined Visit', comp['combined_visit'] as String),
        ],
      ),
    );
  }

  Widget _compareItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: AppTypography.inter,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
              fontFamily: AppTypography.inter,
            ),
          ),
        ],
      ),
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
