import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/video_content.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';

enum InputMode { image, video }

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen>
    with TickerProviderStateMixin {
  InputMode _inputMode = InputMode.image;
  VideoMode _videoMode = VideoMode.link;
  bool _loading = false;
  final _urlController = TextEditingController();
  final _contextController = TextEditingController();
  final _api = ApiService();
  File? _selectedFile;
  String? _fileName;
  Map<String, dynamic>? _result;
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
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _contextController.dispose();
    _api.dispose();
    _slideController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _result = null;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      if (_inputMode == InputMode.image) {
        if (_selectedFile == null) {
          setState(() {
            _error = 'Please select an image file first';
            _loading = false;
          });
          return;
        }
        _result = await _api.predictImage(
          imageFile: _selectedFile!,
          contextHint: _contextController.text.trim(),
        );
      } else {
        final url = _urlController.text.trim();
        if (url.isEmpty) {
          setState(() {
            _error = 'Please enter a YouTube URL';
            _loading = false;
          });
          return;
        }
        _result = await _api.processYoutube(youtubeUrl: url);
      }
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
      body: LinenBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildModePills(),
                  const SizedBox(height: 20),
                  _buildContent(),
                  _buildSubmitButton(),
                ],
              ),
            ),
            if (_loading) const LoadingOverlay(),
          ],
        ),
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
            child: const Icon(Icons.camera_alt_outlined, color: AppColors.darkBase, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identify', style: AppTypography.screenTitle),
              Text(
                'पहचानें',
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

  Widget _buildModePills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ModeTab(
                icon: Icons.image_outlined,
                label: 'Image',
                devanagari: 'चित्र',
                isActive: _inputMode == InputMode.image,
                onTap: () => setState(() => _inputMode = InputMode.image),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ModeTab(
                icon: Icons.videocam_outlined,
                label: 'Video',
                devanagari: 'वीडियो',
                isActive: _inputMode == InputMode.video,
                onTap: () => setState(() => _inputMode = InputMode.video),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _result != null
            ? _buildResult()
            : (_inputMode == InputMode.image
                ? _buildImageContent()
                : _buildVideoContent()),
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (_result != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GoldButton(label: 'Analyze', onTap: _submit),
    );
  }

  Widget _buildImageContent() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickFile,
          child: _selectedFile != null
              ? _buildFileSelected()
              : _buildUploadPrompt(),
        ),
        const SizedBox(height: 16),
        _buildContextHint(),
        _buildErrorWidget(),
      ],
    );
  }

  Widget _buildFileSelected() {
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.jade.withValues(alpha: 0.04),
              AppColors.jade.withValues(alpha: 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.jade.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.jade.withValues(alpha: 0.06),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.jade.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.jade, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              _fileName ?? 'File selected',
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.jade.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Change file',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.jade,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.08),
            ),
            child: const Icon(Icons.image_outlined, size: 36, color: AppColors.gold),
          ),
          const SizedBox(height: 20),
          Text(
            'Upload an image',
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select or take a photo',
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'Choose File',
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBase,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Supported: JPG, PNG, WEBP',
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextHint() {
    return TextField(
      controller: _contextController,
      decoration: InputDecoration(
        hintText: 'Context hint (optional) — e.g. "This is in Rajasthan"',
        hintStyle: TextStyle(
          fontFamily: AppTypography.inter,
          fontSize: 13,
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
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
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.terracotta.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.terracotta),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(color: AppColors.terracotta, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Column(
      children: [
        VideoContent(
          mode: _videoMode,
          onModeChanged: (m) => setState(() => _videoMode = m),
          urlController: _urlController,
        ),
        _buildErrorWidget(),
      ],
    );
  }

  Widget _buildResult() {
    final r = _result!;
    final monumentName = r['monument_name'] ?? r['primary_monument']?['primary_monument'] ?? 'Unknown';
    final specificMonument = r['specific_monument'] ?? '';
    final confidence = r['confidence'] ?? 0.0;
    final top5 = r['top_5_predictions'] as List<dynamic>? ?? [];
    final videoMetadata = r['video_metadata'] as Map<String, dynamic>?;
    final aiInsights = r['ai_insights'] as Map<String, dynamic>?;
    final similarMonuments = r['similar_monuments'] as List<dynamic>? ?? [];
    final isVideo = _inputMode == InputMode.video;

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
                      Icon(isVideo ? Icons.videocam : Icons.image, size: 14, color: AppColors.darkBase),
                      const SizedBox(width: 6),
                      Text(
                        isVideo ? 'Video Analysis' : 'Analysis Result',
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
            const SizedBox(height: 16),
            if (videoMetadata != null)
              _buildVideoMetadata(videoMetadata),
            _buildMonumentResult(monumentName, specificMonument, confidence),
            if (top5.isNotEmpty)
              _buildTopPredictions(top5),
            if (aiInsights != null)
              _buildAiInsights(aiInsights),
            if (similarMonuments.isNotEmpty)
              _buildSimilarMonuments(similarMonuments),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GoldButton(
                label: 'Analyze Another',
                onTap: () => setState(() {
                  _result = null;
                  _error = null;
                  _selectedFile = null;
                  _fileName = null;
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMetadata(Map<String, dynamic> meta) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta['title'] != null)
            _metaField('Title', meta['title'] as String),
          if (meta['channel'] != null)
            _metaField('Channel', meta['channel'] as String),
          if (meta['duration_str'] != null)
            _metaField('Duration', meta['duration_str'] as String),
        ],
      ),
    );
  }

  Widget _metaField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
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
              value,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonumentResult(dynamic name, dynamic specific, dynamic conf) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  name.toString().toLowerCase().contains('unknown')
                      ? Icons.help_outline
                      : Icons.account_balance_outlined,
                  size: 18,
                  color: AppColors.goldDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identified',
                      style: TextStyle(
                        fontFamily: AppTypography.inter,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specific.isNotEmpty ? specific.toString() : name.toString(),
                      style: TextStyle(
                        fontFamily: AppTypography.playfairDisplay,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (conf is num) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                width: double.infinity,
                color: AppColors.border,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: conf.toDouble().clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldLight],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(conf * 100).toStringAsFixed(1)}% confidence',
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.goldDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopPredictions(List<dynamic> top5) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.format_list_numbered, size: 14, color: AppColors.gold),
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Predictions',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: top5.take(5).toList().asMap().entries.map((entry) {
                final p = entry.value;
                final idx = entry.key;
                final pName = p['monument_name'] ?? '';
                final pConf = p['confidence'] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: idx == 0
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontFamily: AppTypography.inter,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: idx == 0 ? AppColors.darkBase : AppColors.goldDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pName.toString(),
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(pConf * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldDark,
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

  Widget _buildAiInsights(Map<String, dynamic> insights) {
    final summary = insights['video_summary'] as String? ?? '';
    if (summary.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.auto_awesome, size: 14, color: AppColors.gold),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMonuments(List<dynamic> similar) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.terracotta.withValues(alpha: 0.04),
            AppColors.terracotta.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.compare_arrows_outlined, size: 14, color: AppColors.terracotta),
              ),
              const SizedBox(width: 8),
              Text(
                'Similar Monuments',
                style: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...similar.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.terracotta.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.toString(),
                        style: TextStyle(
                          fontFamily: AppTypography.inter,
                          fontSize: 13,
                          color: AppColors.textSecondary,
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
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final String devanagari;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.devanagari,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.darkBase : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.darkBase : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
