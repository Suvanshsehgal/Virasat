import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../widgets/gold_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/api_service.dart';

enum Difficulty { easy, medium, hard }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _monumentController = TextEditingController();
  Difficulty _difficulty = Difficulty.medium;
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _quizData;
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  int _correctCount = 0;
  bool _quizFinished = false;
  String? _error;

  @override
  void dispose() {
    _monumentController.dispose();
    _api.dispose();
    super.dispose();
  }

  void _startQuiz() async {
    final name = _monumentController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _quizData = null;
      _currentQuestion = 0;
      _selectedAnswer = null;
      _showResult = false;
      _correctCount = 0;
      _quizFinished = false;
    });

    try {
      _quizData = await _api.heritageQuiz(
        monumentName: name,
        difficulty: _difficulty.name,
        numQuestions: 5,
      );
    } on ApiException catch (e) {
      _error = '${e.statusCode}: ${e.message}';
    } catch (e) {
      _error = 'Connection failed. Ensure backend is running.';
    }

    if (mounted) setState(() => _loading = false);
  }

  void _answer(int index) {
    if (_showResult) return;
    setState(() {
      _selectedAnswer = index;
      _showResult = true;
      final questions = _quizData!['questions'] as List;
      if (index == questions[_currentQuestion]['correct_answer']) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    final questions = _quizData!['questions'] as List;
    if (_currentQuestion + 1 < questions.length) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      setState(() => _quizFinished = true);
    }
  }

  void _restart() {
    setState(() {
      _quizData = null;
      _currentQuestion = 0;
      _selectedAnswer = null;
      _showResult = false;
      _correctCount = 0;
      _quizFinished = false;
      _error = null;
    });
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
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _quizFinished
                          ? _buildResultScreen()
                          : _quizData != null
                              ? _buildQuizQuestion()
                              : _buildSetupForm(),
                    ),
                  ),
                  if (!_quizFinished && _quizData == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: GoldButton(label: 'Start Quiz', onTap: _startQuiz),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quiz', style: AppTypography.screenTitle),
          const SizedBox(height: 4),
          Text(
            'प्रश्नोत्तरी',
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

  Widget _buildSetupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonumentInput(),
        const SizedBox(height: 32),
        _buildDifficulty(),
        const SizedBox(height: 32),
        _buildFeatures(),
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
            hintText: 'e.g. Taj Mahal, Qutub Minar...',
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

  Widget _buildDifficulty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _DifficultyPill(
              label: 'Easy',
              isActive: _difficulty == Difficulty.easy,
              onTap: () => setState(() => _difficulty = Difficulty.easy),
            ),
            const SizedBox(width: 10),
            _DifficultyPill(
              label: 'Medium',
              isActive: _difficulty == Difficulty.medium,
              onTap: () => setState(() => _difficulty = Difficulty.medium),
            ),
            const SizedBox(width: 10),
            _DifficultyPill(
              label: 'Hard',
              isActive: _difficulty == Difficulty.hard,
              onTap: () => setState(() => _difficulty = Difficulty.hard),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz features',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeatureBox(
              icon: Icons.format_list_numbered,
              label: '5 Questions',
            ),
            _FeatureBox(
              icon: Icons.timer_outlined,
              label: '30s per question',
            ),
            _FeatureBox(
              icon: Icons.auto_awesome,
              label: 'AI-powered',
            ),
            _FeatureBox(
              icon: Icons.bolt,
              label: 'Instant feedback',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizQuestion() {
    final questions = _quizData!['questions'] as List;
    final q = questions[_currentQuestion];
    final options = q['options'] as List;
    final total = questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Question ${_currentQuestion + 1}/$total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.goldDark,
                  fontFamily: AppTypography.inter,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          q['question'] ?? '',
          style: AppTypography.body.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ...options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value as String;
          final isCorrect = _showResult && idx == q['correct_answer'];
          final isWrong = _showResult && _selectedAnswer == idx && idx != q['correct_answer'];

          Color bg = AppColors.cardSurface;
          Color border = AppColors.border;
          Color textColor = AppColors.textPrimary;

          if (isCorrect) {
            bg = AppColors.jade.withValues(alpha: 0.1);
            border = AppColors.jade;
            textColor = AppColors.jade;
          } else if (isWrong) {
            bg = AppColors.terracotta.withValues(alpha: 0.1);
            border = AppColors.terracotta;
            textColor = AppColors.terracotta;
          }

          return GestureDetector(
            onTap: _showResult ? null : () => _answer(idx),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: _showResult ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedAnswer == idx && _showResult
                          ? (isCorrect ? AppColors.jade : AppColors.terracotta)
                          : AppColors.border,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + idx),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedAnswer == idx && _showResult
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontFamily: AppTypography.inter,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: AppColors.jade, size: 20),
                  if (isWrong)
                    const Icon(Icons.cancel, color: AppColors.terracotta, size: 20),
                ],
              ),
            ),
          );
        }),
        if (_showResult) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              q['explanation'] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
                fontFamily: AppTypography.inter,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GoldButton(
            label: _currentQuestion + 1 < (questions.length)
                ? 'Next Question'
                : 'See Results',
            onTap: _nextQuestion,
          ),
        ],
      ],
    );
  }

  Widget _buildResultScreen() {
    final total = (_quizData!['questions'] as List).length;
    final pct = (_correctCount / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pct >= 60
                ? AppColors.jade.withValues(alpha: 0.15)
                : AppColors.terracotta.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              '$pct%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: pct >= 60 ? AppColors.jade : AppColors.terracotta,
                fontFamily: AppTypography.playfairDisplay,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          pct >= 80
              ? 'Excellent!'
              : pct >= 60
                  ? 'Good Job!'
                  : 'Keep Learning!',
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 8),
        Text(
          '$_correctCount of $total correct',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: AppTypography.inter,
          ),
        ),
        const SizedBox(height: 32),
        if (_quizData!['fun_fact'] != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.gold, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fun Fact',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.goldDark,
                    fontFamily: AppTypography.inter,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _quizData!['fun_fact'] as String,
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
          const SizedBox(height: 24),
        ],
        GoldButton(label: 'Try Again', onTap: _restart),
      ],
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DifficultyPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  Color _color() {
    switch (label) {
      case 'Easy':
        return AppColors.jade;
      case 'Medium':
        return AppColors.gold;
      case 'Hard':
        return AppColors.terracotta;
      default:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _FeatureBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 24 * 2 - 10) / 2,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 22, color: AppColors.gold),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
