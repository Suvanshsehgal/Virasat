import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/mode_pill.dart';
import '../widgets/upload_area.dart';
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

class _IdentifyScreenState extends State<IdentifyScreen> {
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

  @override
  void dispose() {
    _urlController.dispose();
    _contextController.dispose();
    _api.dispose();
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
                  const SizedBox(height: 24),
                  _buildModePills(),
                  const SizedBox(height: 24),
                  _buildContent(),
                  _buildButton(),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identify', style: AppTypography.screenTitle),
          const SizedBox(height: 4),
          Text(
            'पहचानें',
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

  Widget _buildModePills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ModePill(
              label: 'Image',
              devanagari: 'चित्र',
              isActive: _inputMode == InputMode.image,
              onTap: () => setState(() => _inputMode = InputMode.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModePill(
              label: 'Video',
              devanagari: 'वीडियो',
              isActive: _inputMode == InputMode.video,
              onTap: () => setState(() => _inputMode = InputMode.video),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _inputMode == InputMode.image
            ? _buildImageContent()
            : _buildVideoContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickFile,
          child: _selectedFile != null
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.jade, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _fileName ?? 'File selected',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickFile,
                        child: const Text('Change file'),
                      ),
                    ],
                  ),
                )
              : const UploadArea.image(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _contextController,
          decoration: const InputDecoration(
            hintText: 'Context hint (optional) — e.g. "This is in Rajasthan"',
            prefixIcon: Icon(Icons.edit_outlined, size: 22, color: AppColors.gold),
          ),
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
        if (_result != null) ...[
          const SizedBox(height: 20),
          _buildResultCard(),
        ],
      ],
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
        if (_result != null) ...[
          const SizedBox(height: 20),
          _buildResultCard(),
        ],
      ],
    );
  }

  Widget _buildResultCard() {
    final r = _result!;
    final monumentName = r['monument_name'] ?? r['primary_monument']?['primary_monument'] ?? 'Unknown';
    final specificMonument = r['specific_monument'] ?? '';
    final confidence = r['confidence'] ?? 0.0;
    final top5 = r['top_5_predictions'] as List<dynamic>? ?? [];
    final videoMetadata = r['video_metadata'] as Map<String, dynamic>?;
    final aiInsights = r['ai_insights'] as Map<String, dynamic>?;

    final isVideo = _inputMode == InputMode.video;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.gold, width: 4)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isVideo ? Icons.videocam : Icons.image,
                  color: AppColors.gold, size: 22),
              const SizedBox(width: 8),
              Text(
                isVideo ? 'Video Analysis' : 'Identification Result',
                style: AppTypography.sectionHeader,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (videoMetadata != null) ...[
            _infoRow('Title', videoMetadata['title'] ?? ''),
            _infoRow('Channel', videoMetadata['channel'] ?? ''),
            _infoRow('Duration', videoMetadata['duration_str'] ?? ''),
          ],
          if (specificMonument.isNotEmpty)
            _infoRow('Monument', specificMonument.toString()),
          if (monumentName != null)
            _infoRow('Category', monumentName.toString()),
          if (confidence is num) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: confidence.toDouble(),
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}% confidence',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFamily: AppTypography.inter,
              ),
            ),
          ],
          if (top5.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Top predictions:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...top5.take(5).map((p) {
              final name = p['monument_name'] ?? '';
              final conf = p['confidence'] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(name.toString(),
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                    Text('${(conf * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              );
            }),
          ],
          if (aiInsights != null) ...[
            const SizedBox(height: 16),
            Text('AI Insights',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              aiInsights['video_summary'] ?? '',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
            ),
          ],
          if (r['similar_monuments'] != null) ...[
            const SizedBox(height: 16),
            Text('Similar monuments:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            ...(r['similar_monuments'] as List)
                .map((m) => Text('• $m',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary))),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style:
                    TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: GoldButton(label: 'Analyze', onTap: _submit),
    );
  }
}
