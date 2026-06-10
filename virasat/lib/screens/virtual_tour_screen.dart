import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';

enum NarrativeStyle { narrative, documentary, poetic }

class VirtualTourScreen extends StatefulWidget {
  const VirtualTourScreen({super.key});

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen>
    with TickerProviderStateMixin {
  final _monumentController = TextEditingController();
  NarrativeStyle _style = NarrativeStyle.narrative;
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _story;
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

  void _beginTour() async {
    final name = _monumentController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _story = null;
    });

    try {
      _story = await _api.monumentStory(
        monumentName: name,
        style: _style.name,
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
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _story != null
                          ? _buildStory()
                          : _buildSetupForm(),
                    ),
                  ),
                  if (_story == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: GoldButton(
                        label: 'Begin Virtual Tour',
                        onTap: _beginTour,
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
            child: const Icon(Icons.auto_stories_outlined, color: AppColors.darkBase, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Virtual Tour', style: AppTypography.screenTitle),
              Text(
                'आभासी भ्रमण',
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
        const SizedBox(height: 28),
        _buildStyleSelector(),
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
                Icons.auto_stories,
                color: AppColors.darkBase,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Experience Heritage',
              style: AppTypography.sectionHeader.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'AI-narrated virtual tours with rich historical stories',
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

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.style_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Narrative Style',
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
            'कथा शैली',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 12),
        _NarrativeCard(
          icon: Icons.auto_stories_outlined,
          label: 'Narrative',
          devanagari: 'कथा',
          description: 'A storytelling journey through history and culture',
          isSelected: _style == NarrativeStyle.narrative,
          onTap: () => setState(() => _style = NarrativeStyle.narrative),
        ),
        const SizedBox(height: 10),
        _NarrativeCard(
          icon: Icons.document_scanner_outlined,
          label: 'Documentary',
          devanagari: 'वृत्तचित्र',
          description: 'Factual exploration with historical accuracy',
          isSelected: _style == NarrativeStyle.documentary,
          onTap: () => setState(() => _style = NarrativeStyle.documentary),
        ),
        const SizedBox(height: 10),
        _NarrativeCard(
          icon: Icons.auto_awesome,
          label: 'Poetic',
          devanagari: 'काव्यात्मक',
          description: 'Lyrical and evocative descriptions of heritage',
          isSelected: _style == NarrativeStyle.poetic,
          onTap: () => setState(() => _style = NarrativeStyle.poetic),
        ),
      ],
    );
  }

  Widget _buildStory() {
    final title = _story!['title'] as String? ?? '';
    final opening = _story!['opening'] as String? ?? '';
    final chapters = _story!['chapters'] as List<dynamic>? ?? [];
    final closing = _story!['closing'] as String? ?? '';
    final visitorTip = _story!['visitor_tip'] as String? ?? '';
    final bestPhotoSpot = _story!['best_photo_spot'] as String? ?? '';
    final hiddenGem = _story!['hidden_gem'] as String? ?? '';

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
                      Icon(Icons.auto_stories, size: 14, color: AppColors.darkBase),
                      const SizedBox(width: 6),
                      Text(
                        'Virtual Tour',
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
            if (title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'आभासी भ्रमण',
                style: AppTypography.devanagariSubtitle(size: 20),
              ),
              const SizedBox(height: 6),
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
            if (opening.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.06),
                      AppColors.gold.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: AppColors.gold, width: 3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, color: AppColors.gold.withValues(alpha: 0.3), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opening,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          fontFamily: AppTypography.inter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (chapters.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...chapters.asMap().entries.map((entry) => _buildChapter(entry)),
            ],
            if (closing.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        closing,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          fontFamily: AppTypography.inter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildTips(visitorTip, bestPhotoSpot, hiddenGem),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GoldButton(
                label: 'Take Another Tour',
                onTap: () => setState(() => _story = null),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildChapter(MapEntry<int, dynamic> entry) {
    final ch = entry.key;
    final chapter = entry.value as Map<String, dynamic>;
    final hasNote = chapter['historical_note'] != null &&
        (chapter['historical_note'] as String).isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${ch + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBase,
                        fontFamily: AppTypography.inter,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chapter['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: AppTypography.playfairDisplay,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, hasNote ? 8 : 16),
            child: Text(
              chapter['content'] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
                fontFamily: AppTypography.inter,
              ),
            ),
          ),
          if (hasNote)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.terracotta.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.menu_book_outlined, size: 13, color: AppColors.terracotta),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chapter['historical_note'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: AppTypography.inter,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTips(String tip, String photo, String gem) {
    final items = <_TipItem>[];
    if (tip.isNotEmpty) {
      items.add(_TipItem(Icons.lightbulb_outline, 'Tip', tip, AppColors.gold));
    }
    if (photo.isNotEmpty) {
      items.add(_TipItem(Icons.camera_alt_outlined, 'Photo Spot', photo, AppColors.gold));
    }
    if (gem.isNotEmpty) {
      items.add(_TipItem(Icons.diamond_outlined, 'Hidden Gem', gem, AppColors.gold));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((item) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: item.color, width: 3),
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 16, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: AppTypography.inter,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontFamily: AppTypography.inter,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TipItem {
  final IconData icon;
  final String label;
  final String content;
  final Color color;

  const _TipItem(this.icon, this.label, this.content, this.color);
}

class _NarrativeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String devanagari;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _NarrativeCard({
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
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
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
                    ? AppColors.darkBase.withValues(alpha: 0.1)
                    : AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.darkBase : AppColors.gold,
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
                          color: isSelected ? AppColors.darkBase : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        devanagari,
                        style: TextStyle(
                          fontFamily: AppTypography.notoSansDevanagari,
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.darkBase.withValues(alpha: 0.6)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0,
                      color: isSelected
                          ? AppColors.darkBase.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                      fontFamily: AppTypography.inter,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.darkBase.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
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
