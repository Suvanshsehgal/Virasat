import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';

class TravelPlannerScreen extends StatefulWidget {
  const TravelPlannerScreen({super.key});

  @override
  State<TravelPlannerScreen> createState() => _TravelPlannerScreenState();
}

class _TravelPlannerScreenState extends State<TravelPlannerScreen> {
  final _monumentController = TextEditingController();
  final _daysController = TextEditingController(text: '3');
  final _locationController = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _itinerary;
  String? _error;

  @override
  void dispose() {
    _monumentController.dispose();
    _daysController.dispose();
    _locationController.dispose();
    _api.dispose();
    super.dispose();
  }

  void _generate() async {
    final monument = _monumentController.text.trim();
    final daysStr = _daysController.text.trim();
    final location = _locationController.text.trim();

    if (monument.isEmpty) return;

    final days = int.tryParse(daysStr) ?? 3;

    setState(() {
      _loading = true;
      _error = null;
      _itinerary = null;
    });

    try {
      _itinerary = await _api.travelItinerary(
        monumentName: monument,
        location: location,
        days: days,
      );
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
                      child: _itinerary != null
                          ? _buildItinerary()
                          : _buildSetupForm(),
                    ),
                  ),
                  if (_itinerary == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: GoldButton(
                        label: 'Generate Itinerary',
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

  Widget _buildSetupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonumentInput(),
        const SizedBox(height: 24),
        _buildDaysInput(),
        const SizedBox(height: 24),
        _buildLocationInput(),
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

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (optional)',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'स्थान (वैकल्पिक)',
          style: AppTypography.devanagariSubtitle(size: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'e.g. Agra, Uttar Pradesh',
            hintStyle: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
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

  Widget _buildItinerary() {
    final tripTitle = _itinerary!['trip_title'] as String? ?? '';
    final baseCity = _itinerary!['base_city'] as String? ?? '';
    final bestSeason = _itinerary!['best_season'] as String? ?? '';
    final days = _itinerary!['days'] as List<dynamic>? ?? [];
    final practicalInfo = _itinerary!['practical_info'] as Map<String, dynamic>?;
    final heritageHighlights = _itinerary!['heritage_highlights'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_outlined, size: 22, color: AppColors.gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Your Itinerary', style: AppTypography.sectionHeader),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'आपकी यात्रा योजना',
          style: AppTypography.devanagariSubtitle(size: 20),
        ),
        if (tripTitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            tripTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.goldDark,
              fontFamily: AppTypography.playfairDisplay,
            ),
          ),
        ],
        if (baseCity.isNotEmpty || bestSeason.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            [if (baseCity.isNotEmpty) '📍 $baseCity', if (bestSeason.isNotEmpty) '📅 $bestSeason']
                .join(' · '),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: AppTypography.inter,
            ),
          ),
        ],
        const SizedBox(height: 20),
        ...days.asMap().entries.map((entry) {
          final day = entry.value as Map<String, dynamic>;
          final dayNum = entry.key + 1;
          final theme = day['theme'] as String? ?? '';

          final slots = <MapEntry<String, Map<String, dynamic>>>[];
          if (day['morning'] != null) {
            slots.add(MapEntry('Morning', day['morning'] as Map<String, dynamic>));
          }
          if (day['afternoon'] != null) {
            slots.add(MapEntry('Afternoon', day['afternoon'] as Map<String, dynamic>));
          }
          if (day['evening'] != null) {
            slots.add(MapEntry('Evening', day['evening'] as Map<String, dynamic>));
          }
          final localFood = day['local_food'] as String? ?? '';

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
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
                          '$dayNum',
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
                    Expanded(
                      child: Text(
                        theme,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...slots.map((slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.key,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                              fontFamily: AppTypography.inter,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slot.value['activity'] as String? ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontFamily: AppTypography.inter,
                            ),
                          ),
                          if (slot.value['tip'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '💡 ${slot.value['tip']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontFamily: AppTypography.inter,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
                if (localFood.isNotEmpty) ...[
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant_outlined, size: 16, color: AppColors.terracotta),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          localFood,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.terracotta,
                            fontFamily: AppTypography.inter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
        if (practicalInfo != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.terracotta, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practical Info',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 10),
                if (practicalInfo['how_to_reach'] != null)
                  _practicalRow('🚗', practicalInfo['how_to_reach'] as String),
                if (practicalInfo['local_transport'] != null)
                  _practicalRow('🚌', practicalInfo['local_transport'] as String),
                if (practicalInfo['budget_estimate'] != null)
                  _practicalRow('💰', practicalInfo['budget_estimate'] as String),
                if (practicalInfo['must_carry'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Must carry:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      fontFamily: AppTypography.inter,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...(practicalInfo['must_carry'] as List)
                      .map((item) => Text(
                            '• $item',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: AppTypography.inter,
                            ),
                          )),
                ],
                if (practicalInfo['avoid'] != null) ...[
                  const SizedBox(height: 6),
                  _practicalRow('⚠️', practicalInfo['avoid'] as String),
                ],
              ],
            ),
          ),
        ],
        if (heritageHighlights.isNotEmpty) ...[
          const SizedBox(height: 16),
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
                  'Heritage Highlights',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 8),
                ...heritageHighlights.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✨ ',
                            style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            h as String,
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
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: GoldButton(
            label: 'Plan Another Trip',
            onTap: () => setState(() => _itinerary = null),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _practicalRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: AppTypography.inter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
