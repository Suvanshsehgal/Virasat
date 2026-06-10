import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with TickerProviderStateMixin {
  final _monumentController = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _timelineData;
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
    _monumentController.dispose();
    _api.dispose();
    _slideController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _generate() async {
    final name = _monumentController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _timelineData = null;
    });

    try {
      _timelineData = await _api.heritageTimeline(name);
      _slideController.forward(from: 0);
    } on ApiException catch (e) {
      _error = '${e.statusCode}: ${e.message}';
    } catch (e) {
      _error = 'Connection failed. Ensure backend is running.';
    }

    if (mounted) setState(() => _loading = false);
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
                      child: _timelineData != null
                          ? _buildTimeline()
                          : _buildSetupForm(),
                    ),
                  ),
                  if (_timelineData == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: GoldButton(
                        label: 'Generate Timeline',
                        onTap: _generate,
                      ),
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
            child: const Icon(Icons.timeline_outlined, color: AppColors.darkBase, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Timeline', style: AppTypography.screenTitle),
              Text(
                'समयरेखा',
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
        _buildMonumentInput(),
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
                Icons.timeline,
                color: AppColors.darkBase,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Heritage Timeline',
              style: AppTypography.sectionHeader.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore the complete chronology of any monument',
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

  Widget _buildMonumentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Choose a Monument',
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
            'एक स्मारक चुनें',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _monumentController,
          decoration: InputDecoration(
            hintText: 'Taj Mahal, Red Fort...',
            hintStyle: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.cardSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.gold, width: 2),
            ),
          ),
          style: TextStyle(
            fontFamily: AppTypography.inter,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final timeline = _timelineData!['timeline'] as List<dynamic>? ?? [];
    final monument = _timelineData!['monument'] as String? ?? '';
    final era = _timelineData!['era'] as String? ?? '';
    final dynastyInfo = _timelineData!['dynasty_info'] as Map<String, dynamic>?;
    final worldContext = _timelineData!['world_context'] as String? ?? '';
    final legacy = _timelineData!['legacy'] as String? ?? '';

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
                      Icon(Icons.timeline, size: 14, color: AppColors.darkBase),
                      const SizedBox(width: 6),
                      Text(
                        'Heritage Timeline',
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
            const SizedBox(height: 4),
            Text(
              'विरासत समयरेखा',
              style: AppTypography.devanagariSubtitle(size: 20),
            ),
            if (monument.isNotEmpty || era.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (monument.isNotEmpty)
                    _MetaPill(
                      icon: Icons.account_balance_outlined,
                      label: monument,
                      color: AppColors.gold,
                    ),
                  if (era.isNotEmpty)
                    _MetaPill(
                      icon: Icons.schedule_outlined,
                      label: era,
                      color: AppColors.terracotta,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (timeline.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Center(
                  child: Text(
                    'No timeline data available.',
                    style: TextStyle(
                      fontFamily: AppTypography.inter,
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              )
            else
              ...timeline.asMap().entries.map((entry) {
                final idx = entry.key;
                final ev = entry.value as Map<String, dynamic>;
                return _TimelineEntry(
                  year: ev['year'] as String? ?? '',
                  title: ev['event'] as String? ?? '',
                  description: ev['significance'] as String? ?? '',
                  isFirst: idx == 0,
                  isLast: idx == timeline.length - 1,
                );
              }),
            if (dynastyInfo != null) ...[
              const SizedBox(height: 20),
              _buildDynastyInfo(dynastyInfo),
            ],
            if (worldContext.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildContextCard(
                label: 'World Context',
                icon: Icons.public_outlined,
                content: worldContext,
                color: AppColors.terracotta,
              ),
            ],
            if (legacy.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildContextCard(
                label: 'Legacy',
                icon: Icons.auto_awesome,
                content: legacy,
                color: AppColors.jade,
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GoldButton(
                label: 'New Timeline',
                onTap: () => setState(() {
                  _timelineData = null;
                  _error = null;
                }),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDynastyInfo(Map<String, dynamic> info) {
    final fields = <MapEntry<String, String>>[];
    if (info['name'] != null) fields.add(MapEntry('Dynasty', info['name'] as String));
    if (info['period'] != null) fields.add(MapEntry('Period', info['period'] as String));
    if (info['capital'] != null) fields.add(MapEntry('Capital', info['capital'] as String));
    if (info['known_for'] != null) fields.add(MapEntry('Known For', info['known_for'] as String));

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
                  child: Icon(Icons.king_bed_outlined, size: 16, color: AppColors.gold),
                ),
                const SizedBox(width: 10),
                Text(
                  'Dynasty Info',
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: fields.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          f.key,
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textMuted,
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
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard({
    required String label,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
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
                  width: 16,
                  height: 16,
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
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
                border: const Border(
                  left: BorderSide(color: AppColors.gold, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          year,
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBase,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.playfairDisplay,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: AppTypography.inter,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
