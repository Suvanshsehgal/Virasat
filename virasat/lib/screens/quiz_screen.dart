import 'dart:math' as math;
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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
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

  late AnimationController _progressController;
  late AnimationController _slideController;
  late AnimationController _breatheController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
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
    _progressController.dispose();
    _slideController.dispose();
    _breatheController.dispose();
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
      _slideController.forward(from: 0);
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
    _progressController.forward(from: 0);
  }

  void _nextQuestion() {
    final questions = _quizData!['questions'] as List;
    if (_currentQuestion + 1 < questions.length) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showResult = false;
      });
      _slideController.forward(from: 0);
    } else {
      setState(() => _quizFinished = true);
      _slideController.forward(from: 0);
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
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _quizFinished
                          ? _buildResultScreen()
                          : _quizData != null
                              ? _buildQuizQuestion()
                              : _buildSetupForm(),
                    ),
                  ),
                  if (!_quizFinished && _quizData == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: _buildStartButton(),
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
            child: const Icon(Icons.quiz_outlined, color: AppColors.darkBase, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quiz', style: AppTypography.screenTitle),
              Text(
                'प्रश्नोत्तरी',
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

  Widget _buildStartButton() {
    return GoldButton(label: 'Start Quiz', onTap: _startQuiz);
  }

  Widget _buildError() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
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
        _buildDifficulty(),
        const SizedBox(height: 28),
        _buildFeatures(),
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
                Icons.auto_awesome,
                color: AppColors.darkBase,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test Your Knowledge',
              style: AppTypography.sectionHeader.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Answer AI-generated questions about India\'s rich heritage',
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
            'कौन सा स्मारक',
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
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: AppColors.textMuted,
            ),
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

  Widget _buildDifficulty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Difficulty Level',
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
            'कठिनाई स्तर',
            style: AppTypography.devanagariSubtitle(size: 15),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DifficultyCard(
                label: 'Easy',
                icon: Icons.eco_outlined,
                description: 'Basic facts',
                isActive: _difficulty == Difficulty.easy,
                color: AppColors.jade,
                onTap: () => setState(() => _difficulty = Difficulty.easy),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DifficultyCard(
                label: 'Medium',
                icon: Icons.auto_awesome_outlined,
                description: 'Moderate',
                isActive: _difficulty == Difficulty.medium,
                color: AppColors.gold,
                onTap: () => setState(() => _difficulty = Difficulty.medium),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DifficultyCard(
                label: 'Hard',
                icon: Icons.local_fire_department_outlined,
                description: 'Expert',
                isActive: _difficulty == Difficulty.hard,
                color: AppColors.terracotta,
                onTap: () => setState(() => _difficulty = Difficulty.hard),
              ),
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
        Row(
          children: [
            Icon(Icons.stars_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 8),
            Text(
              'Quiz Features',
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureTile(
                icon: Icons.format_list_numbered,
                label: '5 Questions',
                subtitle: 'Per quiz',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FeatureTile(
                icon: Icons.psychology_outlined,
                label: 'AI-Powered',
                subtitle: 'Smart questions',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FeatureTile(
                icon: Icons.feedback_outlined,
                label: 'Instant Feedback',
                subtitle: 'With explanations',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FeatureTile(
                icon: Icons.auto_awesome,
                label: 'Fun Facts',
                subtitle: 'Learn something new',
              ),
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
    final progress = (_currentQuestion + 1) / total;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(progress),
            const SizedBox(height: 20),
            _buildQuestionHeader(_currentQuestion + 1, total, q['category'] as String?),
            const SizedBox(height: 20),
            Text(
              q['question'] ?? '',
              style: TextStyle(
                fontFamily: AppTypography.playfairDisplay,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            ...options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value as String;
              final isCorrect = _showResult && idx == q['correct_answer'];
              final isWrong = _showResult && _selectedAnswer == idx && idx != q['correct_answer'];

              return _OptionCard(
                index: idx,
                text: option,
                isCorrect: isCorrect,
                isWrong: isWrong,
                showResult: _showResult,
                onTap: _showResult ? null : () => _answer(idx),
              );
            }),
            const SizedBox(height: 4),
            if (_showResult) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: AppColors.goldDark),
                          const SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: TextStyle(
                              fontFamily: AppTypography.inter,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.goldDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q['explanation'] ?? '',
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
              ),
              const SizedBox(height: 24),
              GoldButton(
                label: _currentQuestion + 1 < total
                    ? 'Next Question'
                    : 'See Results',
                onTap: _nextQuestion,
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question ${_currentQuestion + 1}',
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              _selectedAnswer != null
                  ? (_selectedAnswer == (_quizData!['questions'] as List)[_currentQuestion]['correct_answer'] ? '✓' : '✗')
                  : '',
              style: TextStyle(
                fontSize: 16,
                color: _selectedAnswer != null
                    ? (_selectedAnswer == (_quizData!['questions'] as List)[_currentQuestion]['correct_answer']
                        ? AppColors.jade
                        : AppColors.terracotta)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 6,
            width: double.infinity,
            color: AppColors.border,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldLight],
                  ),
                  borderRadius: BorderRadius.circular(6),
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
      ],
    );
  }

  Widget _buildQuestionHeader(int current, int total, String? category) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
          child: Text(
          '$current / $total',
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.darkBase,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (category != null && category.isNotEmpty) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.15)),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: AppColors.terracotta,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultScreen() {
    final total = (_quizData!['questions'] as List).length;
    final pct = _correctCount / total;
    final percent = (pct * 100).round();

    String grade;
    IconData gradeIcon;
    Color gradeColor;
    String gradeSubtitle;

    if (percent >= 80) {
      grade = 'Scholarship!';
      gradeIcon = Icons.emoji_events;
      gradeColor = AppColors.gold;
      gradeSubtitle = 'You know your heritage well!';
    } else if (percent >= 60) {
      grade = 'Well Read!';
      gradeIcon = Icons.auto_awesome;
      gradeColor = AppColors.jade;
      gradeSubtitle = 'You have a solid foundation.';
    } else if (percent >= 40) {
      grade = 'Enthusiast!';
      gradeIcon = Icons.menu_book_outlined;
      gradeColor = AppColors.gold;
      gradeSubtitle = 'There\'s more to explore.';
    } else {
      grade = 'Explorer!';
      gradeIcon = Icons.explore_outlined;
      gradeColor = AppColors.terracotta;
      gradeSubtitle = 'Every expert was once a beginner.';
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildResultRing(percent, gradeColor, gradeIcon),
            const SizedBox(height: 20),
            Text(
              grade,
              style: TextStyle(
                fontFamily: AppTypography.playfairDisplay,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: gradeColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gradeSubtitle,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreBreakdown(_correctCount, total),
            const SizedBox(height: 24),
            if (_quizData!['fun_fact'] != null)
              _buildFunFact(_quizData!['fun_fact'] as String),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GoldButton(label: 'Try Again', onTap: _restart),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _restart,
                child: Text(
                  'Choose a different monument',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRing(int percent, Color color, IconData icon) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _RingPainter(
                    progress: value,
                    color: color,
                    trackColor: AppColors.border,
                    strokeWidth: 10,
                  ),
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 2),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: percent),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, _) {
                  return Text(
                    '$value%',
                    style: TextStyle(
                      fontFamily: AppTypography.playfairDisplay,
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(int correct, int total) {
    final incorrect = total - correct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          _ScoreDot(
            icon: Icons.check_circle,
            label: 'Correct',
            value: correct,
            color: AppColors.jade,
          ),
          Container(
            height: 32,
            width: 1,
            color: AppColors.border,
          ),
          _ScoreDot(
            icon: Icons.cancel,
            label: 'Incorrect',
            value: incorrect,
            color: AppColors.terracotta,
          ),
          Container(
            height: 32,
            width: 1,
            color: AppColors.border,
          ),
          _ScoreDot(
            icon: Icons.help_outline,
            label: 'Total',
            value: total,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildFunFact(String fact) {
    return Container(
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fun Fact',
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.goldDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fact,
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

class _OptionCard extends StatefulWidget {
  final int index;
  final String text;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.index,
    required this.text,
    required this.isCorrect,
    required this.isWrong,
    required this.showResult,
    this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + widget.index);

    Color borderColor;
    Color bgColor;
    Color indicatorBg;
    Color indicatorText;
    Color textColor;
    Widget? trailing;

    if (widget.showResult) {
      if (widget.isCorrect) {
        borderColor = AppColors.jade;
        bgColor = AppColors.jade.withValues(alpha: 0.06);
        indicatorBg = AppColors.jade;
        indicatorText = Colors.white;
        textColor = AppColors.jade;
        trailing = const Icon(Icons.check_circle_rounded, color: AppColors.jade, size: 22);
      } else if (widget.isWrong) {
        borderColor = AppColors.terracotta;
        bgColor = AppColors.terracotta.withValues(alpha: 0.06);
        indicatorBg = AppColors.terracotta;
        indicatorText = Colors.white;
        textColor = AppColors.terracotta;
        trailing = const Icon(Icons.cancel_rounded, color: AppColors.terracotta, size: 22);
      } else {
        borderColor = AppColors.border;
        bgColor = AppColors.cardSurface;
        indicatorBg = AppColors.border;
        indicatorText = AppColors.textMuted;
        textColor = AppColors.textMuted;
        trailing = null;
      }
    } else {
      borderColor = AppColors.border;
      bgColor = AppColors.cardSurface;
      indicatorBg = AppColors.deepSurface;
      indicatorText = AppColors.textMuted;
      textColor = AppColors.textPrimary;
      trailing = null;
    }

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _pressController.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _pressController.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: widget.showResult && (widget.isCorrect || widget.isWrong) ? 2 : 1,
            ),
            boxShadow: widget.showResult && widget.isCorrect
                ? [
                    BoxShadow(
                      color: AppColors.jade.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : (widget.showResult && widget.isWrong
                    ? [
                        BoxShadow(
                          color: AppColors.terracotta.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : AppColors.cardShadow),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorBg,
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontFamily: AppTypography.inter,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: indicatorText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontSize: 14,
                    fontWeight: widget.showResult && (widget.isCorrect || widget.isWrong)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? color : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 0 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? Colors.white : color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontFamily: AppTypography.inter,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.gold),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppTypography.inter,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: AppColors.textMuted,
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

class _ScoreDot extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _ScoreDot({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: AppTypography.playfairDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
