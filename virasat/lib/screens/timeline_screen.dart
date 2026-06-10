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

class _TimelineScreenState extends State<TimelineScreen> {
  final _monumentController = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _timelineData;
  String? _error;

  @override
  void dispose() {
    _monumentController.dispose();
    _api.dispose();
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
                          if (_timelineData != null) ...[
                            const SizedBox(height: 32),
                            _buildTimeline(),
                          ],
                        ],
                      ),
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

  Widget _buildTimeline() {
    final timeline = _timelineData!['timeline'] as List<dynamic>? ?? [];
    final monument = _timelineData!['monument'] as String? ?? '';
    final era = _timelineData!['era'] as String? ?? '';
    final dynastyInfo = _timelineData!['dynasty_info'] as Map<String, dynamic>?;
    final worldContext = _timelineData!['world_context'] as String? ?? '';
    final legacy = _timelineData!['legacy'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timeline, color: AppColors.gold, size: 22),
            const SizedBox(width: 8),
            Text('Heritage Timeline', style: AppTypography.sectionHeader),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'विरासत समयरेखा',
          style: AppTypography.devanagariSubtitle(size: 20),
        ),
        if (monument.isNotEmpty || era.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '$monument · $era',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontFamily: AppTypography.inter,
            ),
          ),
        ],
        const SizedBox(height: 20),
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
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.gold, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dynasty Info',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 8),
                if (dynastyInfo['name'] != null)
                  _metaRow('Dynasty', dynastyInfo['name'] as String),
                if (dynastyInfo['period'] != null)
                  _metaRow('Period', dynastyInfo['period'] as String),
                if (dynastyInfo['capital'] != null)
                  _metaRow('Capital', dynastyInfo['capital'] as String),
                if (dynastyInfo['known_for'] != null)
                  _metaRow('Known For', dynastyInfo['known_for'] as String),
              ],
            ),
          ),
        ],
        if (worldContext.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'World Context',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.terracotta,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  worldContext,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontFamily: AppTypography.inter,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (legacy.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.jade.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legacy',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.jade,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  legacy,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontFamily: AppTypography.inter,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: GoldButton(
            label: 'New Timeline',
            onTap: () => setState(() {
              _timelineData = null;
              _error = null;
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
