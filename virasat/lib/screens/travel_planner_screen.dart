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

class _TravelPlannerScreenState extends State<TravelPlannerScreen>
    with TickerProviderStateMixin {
  final _monumentController = TextEditingController();
  int _days = 3;
  final _locationController = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _itinerary;
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
    _locationController.dispose();
    _api.dispose();
    _slideController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _generate() async {
    final monument = _monumentController.text.trim();
    final location = _locationController.text.trim();

    if (monument.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _itinerary = null;
    });

    try {
      _itinerary = await _api.travelItinerary(
        monumentName: monument,
        location: location,
        days: _days,
      );
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
                  _buildAppBar(),
                  const SizedBox(height: 12),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _itinerary != null
                          ? _buildItinerary()
                          : _buildSetupForm(),
                    ),
                  ),
                  if (_itinerary == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: GoldButton(
                        label: 'Generate Itinerary',
                        onTap: _generate,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_loading)
            const LoadingOverlay(
              title: 'Planning your trip...',
              devanagari: 'आपकी यात्रा की योजना बना रहा है',
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
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
            child: const Icon(Icons.map_outlined, color: AppColors.darkBase, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Travel Planner', style: AppTypography.screenTitle),
              Text(
                'यात्रा योजना',
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
        const SizedBox(height: 24),
        _buildLocationInput(),
        const SizedBox(height: 24),
        _buildDaysSelector(),
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
                Icons.explore_outlined,
                color: AppColors.darkBase,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Plan Your Journey',
              style: AppTypography.sectionHeader.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'AI-crafted heritage travel itineraries tailored to you',
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
              'Destination Monument',
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
            'गंतव्य स्मारक',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _monumentController,
          decoration: InputDecoration(
            hintText: 'Taj Mahal, Qutub Minar...',
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

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Location',
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
            'स्थान (वैकल्पिक)',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Agra, Uttar Pradesh',
            hintStyle: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(Icons.public_outlined, size: 20, color: AppColors.textMuted),
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

  Widget _buildDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Duration',
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
            'यात्रा की अवधि',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              _DayOption(
                label: '1 Day',
                days: 1,
                isActive: _days == 1,
                onTap: () => setState(() => _days = 1),
              ),
              const SizedBox(width: 4),
              _DayOption(
                label: '2 Days',
                days: 2,
                isActive: _days == 2,
                onTap: () => setState(() => _days = 2),
              ),
              const SizedBox(width: 4),
              _DayOption(
                label: '3 Days',
                days: 3,
                isActive: _days == 3,
                onTap: () => setState(() => _days = 3),
              ),
              const SizedBox(width: 4),
              _DayOption(
                label: '4 Days',
                days: 4,
                isActive: _days == 4,
                onTap: () => setState(() => _days = 4),
              ),
              const SizedBox(width: 4),
              _DayOption(
                label: '5 Days',
                days: 5,
                isActive: _days == 5,
                onTap: () => setState(() => _days = 5),
              ),
            ],
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

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItineraryHeader(tripTitle, baseCity, bestSeason),
            const SizedBox(height: 24),
            ...days.asMap().entries.map((entry) => _buildDayCard(entry)),
            if (practicalInfo != null) ...[
              const SizedBox(height: 20),
              _buildPracticalInfo(practicalInfo),
            ],
            if (heritageHighlights.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildHeritageHighlights(heritageHighlights),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GoldButton(
                label: 'Plan Another Trip',
                onTap: () => setState(() => _itinerary = null),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryHeader(String title, String city, String season) {
    return Column(
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
                  Icon(Icons.map_outlined, size: 14, color: AppColors.darkBase),
                  const SizedBox(width: 6),
                  Text(
                    'Your Itinerary',
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
          'आपकी यात्रा योजना',
          style: AppTypography.devanagariSubtitle(size: 20),
        ),
        if (title.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.playfairDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
        if (city.isNotEmpty || season.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (city.isNotEmpty)
                _MetaChip(
                  icon: Icons.location_on_outlined,
                  label: city,
                  color: AppColors.gold,
                ),
              if (season.isNotEmpty)
                _MetaChip(
                  icon: Icons.wb_sunny_outlined,
                  label: season,
                  color: AppColors.terracotta,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDayCard(MapEntry<int, dynamic> entry) {
    final day = entry.value as Map<String, dynamic>;
    final dayNum = entry.key + 1;
    final theme = day['theme'] as String? ?? '';

    final slots = <_TimeSlotData>[];
    if (day['morning'] != null) {
      slots.add(_TimeSlotData('Morning', day['morning'] as Map<String, dynamic>, Icons.wb_sunny_outlined));
    }
    if (day['afternoon'] != null) {
      slots.add(_TimeSlotData('Afternoon', day['afternoon'] as Map<String, dynamic>, Icons.wb_cloudy_outlined));
    }
    if (day['evening'] != null) {
      slots.add(_TimeSlotData('Evening', day['evening'] as Map<String, dynamic>, Icons.nights_stay_outlined));
    }
    final localFood = day['local_food'] as String? ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeader(dayNum: dayNum, theme: theme),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...slots.map((slot) => _TimeSlot(slot: slot)),
                if (localFood.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_outlined, size: 16, color: AppColors.terracotta),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localFood,
                            style: TextStyle(
                              fontFamily: AppTypography.inter,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticalInfo(Map<String, dynamic> info) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lightbulb_outline, size: 16, color: AppColors.terracotta),
                ),
                const SizedBox(width: 10),
                Text(
                  'Practical Information',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info['how_to_reach'] != null)
                  _InfoRow(
                    icon: Icons.flight_outlined,
                    label: 'How to Reach',
                    value: info['how_to_reach'] as String,
                  ),
                if (info['local_transport'] != null)
                  _InfoRow(
                    icon: Icons.directions_bus_outlined,
                    label: 'Local Transport',
                    value: info['local_transport'] as String,
                  ),
                if (info['budget_estimate'] != null)
                  _InfoRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Budget Estimate',
                    value: info['budget_estimate'] as String,
                  ),
                if (info['must_carry'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Must Carry',
                    style: TextStyle(
                      fontFamily: AppTypography.inter,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (info['must_carry'] as List)
                        .map((item) => _CarryChip(label: item as String))
                        .toList(),
                  ),
                ],
                if (info['avoid'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.terracotta),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info['avoid'] as String,
                            style: TextStyle(
                              fontFamily: AppTypography.inter,
                              fontSize: 13,
                              color: AppColors.terracotta,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeritageHighlights(List<dynamic> highlights) {
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
        borderRadius: BorderRadius.circular(20),
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
                  'Heritage Highlights',
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: highlights.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
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
                              fontSize: 11,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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

class _DayOption extends StatelessWidget {
  final String label;
  final int days;
  final bool isActive;
  final VoidCallback onTap;

  const _DayOption({
    required this.label,
    required this.days,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label.split(' ')[0],
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isActive ? AppColors.darkBase : AppColors.textPrimary,
                ),
              ),
              Text(
                label.split(' ')[1],
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  color: isActive
                      ? AppColors.darkBase.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final int dayNum;
  final String theme;

  const _DayHeader({required this.dayNum, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$dayNum',
                style: TextStyle(
                  fontFamily: AppTypography.playfairDisplay,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBase,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayNum',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                if (theme.isNotEmpty)
                  Text(
                    theme,
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
          Icon(Icons.expand_more, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _TimeSlotData {
  final String label;
  final Map<String, dynamic> data;
  final IconData icon;

  const _TimeSlotData(this.label, this.data, this.icon);
}

class _TimeSlot extends StatelessWidget {
  final _TimeSlotData slot;

  const _TimeSlot({required this.slot});

  @override
  Widget build(BuildContext context) {
    final activity = slot.data['activity'] as String? ?? '';
    final tip = slot.data['tip'] as String?;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.gold, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(slot.icon, size: 16, color: AppColors.goldDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.label,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                if (tip != null && tip.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 12, color: AppColors.goldDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.goldDark),
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
                    color: AppColors.textPrimary,
                    height: 1.3,
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

class _CarryChip extends StatelessWidget {
  final String label;

  const _CarryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.jade.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.jade.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: AppColors.jade),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.jade,
            ),
          ),
        ],
      ),
    );
  }
}
