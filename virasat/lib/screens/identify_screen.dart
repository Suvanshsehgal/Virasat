import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/mode_pill.dart';
import '../widgets/upload_area.dart';
import '../widgets/video_content.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';

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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _loading = false);
    });
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
            ? const UploadArea.image()
            : VideoContent(
                mode: _videoMode,
                onModeChanged: (m) => setState(() => _videoMode = m),
                urlController: _urlController,
              ),
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
