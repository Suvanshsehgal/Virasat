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

class _CompareMonumentsScreenState extends State<CompareMonumentsScreen>
    with TickerProviderStateMixin {
  final _monument1Controller = TextEditingController();
  final _monument2Controller = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _comparison;
  String? _error;

  late AnimationController _slideController;
  late AnimationController _breatheController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _breatheController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _monument1Controller.dispose();
    _monument2Controller.dispose();
    _api.dispose();
    _slideController.dispose();
    _breatheController.dispose();
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
      _slideController.forward(from: 0);
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
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _comparison != null
                          ? _buildComparisonResult()
                          : _buildSetupForm(),
                    ),
                  ),
                  if (_comparison == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.compare_arrows_outlined, color: AppColors.darkBase, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compare Monuments', style: AppTypography.screenTitle),
              Text(
                'स्मारकों की तुलना',
                style: AppTypography.devanagariSubtitle(size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 3,
      decoration: AppDecorations.tricolorDivider,
      width: double.infinity,
    );
  }

  Widget _buildError() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.terracotta.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: AppColors.terracotta),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  color: AppColors.terracotta,
                  fontSize: 13,
                  fontFamily: AppTypography.inter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroSection(),
        const SizedBox(height: 28),
        _buildMonumentInputs(),
        const SizedBox(height: 28),
        _buildPopularComparisons(),
        _buildError(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.08),
              AppColors.gold.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.compare_arrows,
                color: AppColors.darkBase,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Compare Monuments',
              style: AppTypography.sectionHeader.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Side-by-side analysis of heritage sites',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonumentInputs() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
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
                  prefixIcon: Icon(Icons.looks_one_outlined, size: 20, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.pageBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gold, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontFamily: AppTypography.playfairDisplay,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _monument2Controller,
                decoration: InputDecoration(
                  hintText: 'Second monument...',
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: Icon(Icons.looks_two_outlined, size: 20, color: AppColors.terracotta),
                  filled: true,
                  fillColor: AppColors.pageBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.terracotta, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularComparisons() {
    final pairs = [
      ('Taj Mahal', 'Red Fort'),
      ('Qutub Minar', 'Charminar'),
      ('Gateway of India', 'India Gate'),
      ('Hawa Mahal', 'Mysore Palace'),
      ('Ajanta Caves', 'Ellora Caves'),
      ('Sun Temple', 'Meenakshi Temple'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Popular Comparisons',
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            'लोकप्रिय तुलनाएँ',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 12),
        ...pairs.map((pair) => _ComparisonChip(
              m1: pair.$1,
              m2: pair.$2,
              onTap: () => _selectPair(pair.$1, pair.$2),
            )),
      ],
    );
  }

  Widget _buildComparisonResult() {
    final m1 = _comparison!['monument1'] as Map<String, dynamic>? ?? {};
    final m2 = _comparison!['monument2'] as Map<String, dynamic>? ?? {};
    final comp = _comparison!['comparison'] as Map<String, dynamic>? ?? {};
    final funFacts = _comparison!['fun_facts'] as List<dynamic>? ?? [];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.compare_arrows, size: 14, color: AppColors.darkBase),
                      const SizedBox(width: 6),
                      Text(
                        'Comparison Result',
                        style: TextStyle(
                          fontFamily: AppTypography.inter,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.darkBase,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMonumentCard(m1, AppColors.gold),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.compare_arrows, color: AppColors.gold, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            _buildMonumentCard(m2, AppColors.terracotta),
            if (comp.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildComparisonSection(comp),
            ],
            if (funFacts.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildFunFacts(funFacts),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GoldButton(
                label: 'Compare New Pair',
                onTap: () => setState(() => _comparison = null),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMonumentCard(Map<String, dynamic> m, Color accent) {
    final name = m['name'] as String? ?? '';
    final location = m['location'] as String? ?? '';
    final builtYear = m['built_year'] as String? ?? '';
    final builtBy = m['built_by'] as String? ?? '';
    final architecture = m['architecture'] as String? ?? '';
    final unesco = m['unesco'] as String? ?? '';
    final significance = m['significance'] as String? ?? '';
    final unique = m['unique_feature'] as String? ?? '';

    final detailFields = <MapEntry<String, String>>[];
    if (location.isNotEmpty) detailFields.add(MapEntry('Location', location));
    if (builtYear.isNotEmpty) detailFields.add(MapEntry('Built', builtYear));
    if (builtBy.isNotEmpty) detailFields.add(MapEntry('Built by', builtBy));
    if (architecture.isNotEmpty) detailFields.add(MapEntry('Architecture', architecture));
    if (unesco.isNotEmpty) detailFields.add(MapEntry('UNESCO', unesco));
    if (significance.isNotEmpty) detailFields.add(MapEntry('Significance', significance));
    if (unique.isNotEmpty) detailFields.add(MapEntry('Unique Feature', unique));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
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
          const SizedBox(height: 14),
          ...detailFields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        f.key,
                        style: TextStyle(
                          fontFamily: AppTypography.inter,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        f.value,
                        style: TextStyle(
                          fontFamily: AppTypography.inter,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(Map<String, dynamic> comp) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.analytics_outlined, size: 16, color: AppColors.gold),
                ),
                const SizedBox(width: 10),
                Text(
                  'Comparison',
                  style: TextStyle(
                    fontFamily: AppTypography.playfairDisplay,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comp['similarities'] != null)
                  _buildListSection(
                    'Similarities',
                    comp['similarities'] as List,
                    AppColors.jade,
                    Icons.check_circle_outline,
                  ),
                if (comp['differences'] != null) ...[
                  const SizedBox(height: 16),
                  _buildListSection(
                    'Differences',
                    comp['differences'] as List,
                    AppColors.terracotta,
                    Icons.remove_circle_outline,
                  ),
                ],
                if (comp['which_older'] != null)
                  _buildVerdictItem('Older', comp['which_older'] as String, Icons.schedule_outlined, AppColors.gold),
                if (comp['architectural_contrast'] != null)
                  _buildVerdictItem('Architecture', comp['architectural_contrast'] as String, Icons.account_balance_outlined, AppColors.gold),
                if (comp['cultural_contrast'] != null)
                  _buildVerdictItem('Culture', comp['cultural_contrast'] as String, Icons.public_outlined, AppColors.gold),
                if (comp['verdict_history'] != null)
                  _buildVerdictItem('History', comp['verdict_history'] as String, Icons.menu_book_outlined, AppColors.jade),
                if (comp['verdict_architecture'] != null)
                  _buildVerdictItem('Architecture', comp['verdict_architecture'] as String, Icons.account_balance_outlined, AppColors.jade),
                if (comp['verdict_tourism'] != null)
                  _buildVerdictItem('Tourism', comp['verdict_tourism'] as String, Icons.flight_outlined, AppColors.jade),
                if (comp['combined_visit'] != null)
                  _buildVerdictItem('Combined Visit', comp['combined_visit'] as String, Icons.map_outlined, AppColors.terracotta),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item as String,
                      style: TextStyle(
                        fontFamily: AppTypography.inter,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildVerdictItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunFacts(List<dynamic> facts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.06),
            AppColors.gold.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, size: 16, color: AppColors.gold),
                ),
                const SizedBox(width: 10),
                Text(
                  'Fun Facts',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: facts.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontFamily: AppTypography.inter,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value as String,
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.looks_one_outlined, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                m1,
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'vs',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Icon(Icons.looks_two_outlined, size: 14, color: AppColors.terracotta),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  m2,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
